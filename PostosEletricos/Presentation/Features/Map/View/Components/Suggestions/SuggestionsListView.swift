//
//  SuggestionsListView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 21/04/24.
//

import SwiftUI
import CoreLocation

struct SuggestionsListView: View {

    @ObservedObject var viewModel: MapViewModel
    @Environment(\.isSearching) var isSearching
    @Environment(\.dismissSearch) var dismissSearch
    @State private var selection: UUID?

    var body: some View {
        ForEach(viewModel.placesFromSearch, id: \.id) { place in
            Button(place.name) {
                withAnimation {
                    dismissSearch()
                }

                viewModel.deselectPlace()

                handleSelection(place)
            }
            .foregroundStyle(.foreground)
        }
    }

    private func handleSelection(_ place: Place) {
        DispatchQueue.main.async {

            viewModel.getPlace(id: place.placeID) { placeDetail in
                guard let lat = placeDetail?.geometry?.location?.lat,
                      let lng = placeDetail?.geometry?.location?.lng else { return }

                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)

                viewModel.updateCameraPosition(forCoordinate: coordinate)

                viewModel.fetchStationsFromGooglePlaces(in: coordinate) { items in
                    guard let items else { return }
                    viewModel.getMapItemsRegion(places: items) { region in
                        viewModel.updateCameraPosition(forRegion: region)
                        let _ = printLog(.critical, "caiu aqui")
                    }
                }
            }
        }
    }
}

#Preview {
    SuggestionsListView(viewModel: MapViewModel())
}
