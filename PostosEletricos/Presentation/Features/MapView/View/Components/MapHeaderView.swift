//
//  MapHeaderView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import SwiftUI
import Lottie
import MapKit

struct MapHeaderView: View {

    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }

    @State var canShowProgress: Bool = false
    @State private var selectionFromSearch: UUID?
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                LottieView(animation: .named("splash-anim"))
                    .looping()
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(.bottom, 4)

                Text("Postos Elétricos")
                    .font(.title)

                Spacer()

                Button {
                    withAnimation {
                        viewModel.isSearchBarVisible.toggle()
                    }

                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 24)
                        .frame(height: 24)
                        .foregroundStyle(.accent)
                        .padding(.trailing, 6)
                }
            }
            .padding(8)

            if viewModel.isSearchBarVisible {
                TextField("Buscar...", text: $viewModel.searchText)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                    .transition(.scale)
                    .animation(.default, value: viewModel.isSearchBarVisible)
            }

            HProgressView(show: viewModel.isLoading)
                .opacity(canShowProgress ? 1 : 0)

            if viewModel.shouldShowPlacesFromSearch {
                List(viewModel.placesFromSearch, id: \.id, selection: $selectionFromSearch) { placeFromSearch in
                    Text(placeFromSearch.name ?? "deu ruim")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }.onChange(of: selectionFromSearch) {
                    withAnimation {
                        viewModel.isSearchBarVisible = false
                        viewModel.searchText = ""
                    }

                    let placesFromSearch = viewModel.placesFromSearch.first(where: { 
                       return $0.id == selectionFromSearch
                    })

                    viewModel.getPlace(id: placesFromSearch?.placeID) { place in
                        guard let lat = place?.geometry?.location?.lat,
                              let lng = place?.geometry?.location?.lng
                        else { return }

                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        viewModel.updateCameraPosition(forCoordinate: coordinate)

                        viewModel.fetchStationsFromGooglePlaces(in: coordinate) { items in
                            guard let items else { return }
                            viewModel.getMapItemsRegion(items: items) { region in
                                viewModel.updateCameraPosition(forRegion: region)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(
            Color
                .white
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 8)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    canShowProgress.toggle()
                }
            }
        }
    }
}

#Preview {
    @Namespace var animation

    return VStack(spacing: 0) {
        MapHeaderView(viewModel: MapViewModel())
        Rectangle().fill(.gray.opacity(0.2)).frame(maxHeight: .infinity)
    }
}
