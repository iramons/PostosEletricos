//
//  MapViewModel.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 09/03/24.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI
import Moya
import Combine

@MainActor
class MapViewModel: ObservableObject {
    
    // MARK: Lifecycle
    
    init() {
        showLocationServicesAlert = locationService.showLocationServicesAlert
        
        bind()
    }

    // MARK: Public

    @State var state: FetchState = .none

    @Published var location: CLLocation?
    @Published var items: [MKMapItem] = [MKMapItem]()
    @Published var selectedItem: MKMapItem?
    @Published var travelTime: String?
    @Published var isRoutePresenting: Bool = false
    @Published var showRouteButtonTitle: String = "Mostrar rota"
    @Published var showToast: Bool = false
    @Published var showSplash: Bool = true
    @Published var showFindInAreaButton: Bool = true
    @Published var showLocationServicesAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var distance: CLLocationDistance = CLLocationDistance(3000)
    @Published var lastRegion: MKCoordinateRegion?

    @Published var cameraPosition: MapCameraPosition = .region(
        .init(
            center: .init(latitude: -20.4844352, longitude: -69.3907158),
            latitudinalMeters: CLLocationDistance(Constants.defaultRadius),
            longitudinalMeters: CLLocationDistance(Constants.defaultRadius)
        )
    )

    @Published var route: MKRoute? {
        didSet {
            let hasRoute = route != nil
            isRoutePresenting = hasRoute
            showRouteButtonTitle = hasRoute ? "Remover rota" : "Mostrar rota"
        }
    }

    let toastMessage: String = "Nenhum posto de recarga elétrica encontrado nesta área."

    func startCurrentLocationUpdates() async throws {
        try? await locationService.startCurrentLocationUpdates()
    }
    
    func updateCameraPosition(to location: CLLocation) {
        guard let span = cameraPosition.region?.span else {
            printLog(.critical, "span is null")
            return
        }

        withAnimation(.easeInOut) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: span
                )
            )
        }

        updateLastRegion()
    }
    
    func updateCameraPosition(with context: MapCameraUpdateContext) {
        cameraPosition = .region(.init(center: context.region.center, span: context.region.span))

        updateLastRegion()

        if showToast {
            setShowToast(false)
        }
    }

    func updateDistance(with context: MapCameraUpdateContext) {
        distance = context.camera.distance / 3.8
    }

    // MARK: Private

    private enum Constants {
        static let defaultRadius: Float = 3000
        static let defaultCoordinate: CLLocationCoordinate2D = .init(latitude: -22.904232, longitude: -43.104371)
        static let defaultSpan: MKCoordinateSpan = .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
    }
    
    @Injected var locationService: LocationService

    private var provider = MoyaProvider<GoogleMapsAPI>(plugins: [NetworkConfig.networkLogger])
    
    private var cancellables = Set<AnyCancellable>()
    
    /// indicates if app should send camera update to map or not
    private var shouldUpdateCamera: Bool = true
    
    /// indicates when need fetch data from API, when it's false should stop fetching.
    private var shouldFetchStations: Bool = true

    private func bind() {
        locationService.$location
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self, let location else { return }
                self.location = location
                performUpdateCamera()
                performFetchData(in: location.coordinate)
            }
            .store(in: &cancellables)
    }
    
    private func updateCameraPosition() {
        guard let location else { return }
        updateCameraPosition(to: location)
    }
    
    private func performUpdateCamera() {
        if shouldUpdateCamera {
            shouldUpdateCamera = false
            updateCameraPosition()
        }
    }
    
    private func performFetchData(in coordinate: CLLocationCoordinate2D) {
        if shouldFetchStations {
            shouldFetchStations = false
            fetchStations(in: coordinate)
        }
    }
    
    private func getTravelTime() {
        guard let route else { return }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        travelTime = formatter.string(from: route.expectedTravelTime)
    }

    private func setShowToast(_ bool: Bool) {
        withAnimation {
            showToast = bool
        }
    }

    private func updateLastRegion() {
        lastRegion = cameraPosition.region
    }
}

// MARK: Request

extension MapViewModel {
    func fetchStations(in location: CLLocationCoordinate2D) {
        isLoading = true

        provider.request(
            .eletricalChargingStations(
                latitude: location.latitude,
                longitude: location.longitude,
                radius: distance
            )
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(response):
                do {
                    let response = try response.map(GooglePlacesResponse.self, failsOnEmptyData: false)

                    if response.results.isEmpty {
                        printLog(.warning, "No results found in this area.")
                        setShowToast(true)
                    }

                    for place in response.results {
                        guard let lat = place.geometry?.location?.lat,
                              let lng = place.geometry?.location?.lng
                        else { return }
                        
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        let item = MKMapItem(placemark: .init(coordinate: coordinate))
                        item.name = place.name

                        items.append(item)
                    }
                }
                catch {
                    printLog(.error, "error in success response: \(error)")
                }
                isLoading = false

            case let .failure(error):
                printLog(.error, "failure request: \(error)")
                isLoading = false
            }
        }
    }
    
    func fetchRouteFrom(_ source: CLLocation, to destination: CLLocation) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
        request.transportType = .automobile
        
        _Concurrency.Task {
            let result = try? await MKDirections(request: request).calculate()
            route = result?.routes.first
            getTravelTime()
        }
    }
}
