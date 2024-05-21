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
                withAnimation { dismissSearch() }

                viewModel.onDismissSearch()

                handleSelection(place)
            }
            .foregroundStyle(.foreground)
        }
    }

    private func handleSelection(_ place: Place) {
        guard let placeID = place.placeID else { return }
        
        viewModel.fetchPlace(placeID: placeID) { place in
            if let coordinate = place?.coordinate {
                viewModel.updateCameraPosition(forCoordinate: coordinate, withSpan: .init(latitudeDelta: CLLocationDegrees(0.005), longitudeDelta: CLLocationDegrees(0.005)))
                viewModel.fetchStationsFromGooglePlaces(in: coordinate, radius: CLLocationDistance(300)) { _ in }
            }
        }
    }
}

#Preview {
    SuggestionsListView(viewModel: MapViewModel())
}
