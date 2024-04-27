//
//  SearchListView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 21/04/24.
//

import SwiftUI
import CoreLocation

struct SearchListView: View {

    @State private var selectionFromSearch: UUID?
    @ObservedObject var viewModel: MapViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.isSearching) var isSearching
    @Environment(\.searchSuggestionsPlacement) var placement
    @Environment(\.dismissSearch) var dismissSearch

    var body: some View {
        if isSearching {
            List(viewModel.placesFromSearch, id: \.id, selection: $selectionFromSearch) { placeFromSearch in
                Text(placeFromSearch.name ?? "deu ruim")
                    .font(.custom("RobotoCondensed-Light", size: 15))
                    .multilineTextAlignment(.leading)
                    .searchCompletion(placeFromSearch.name ?? "")

            }.onChange(of: selectionFromSearch) {
                withAnimation {
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
}

#Preview {
    SearchListView(viewModel: MapViewModel())
}
