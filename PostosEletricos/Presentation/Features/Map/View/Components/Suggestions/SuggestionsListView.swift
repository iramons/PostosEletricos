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
                onSuggestionSelected(place)
            }
            .foregroundStyle(.foreground)
        }
    }

    private func onSuggestionSelected(_ place: Place) {
        guard let placeID = place.placeID else { return }
        
        viewModel.fetchPlace(placeID: placeID) { place in
            if let coordinate = place?.coordinate {
                viewModel.updateCameraPosition(forCoordinate: coordinate, withSpan: .init(latitudeDelta: CLLocationDegrees(0.03), longitudeDelta: CLLocationDegrees(0.03)))

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    viewModel.fetchStationsFromGooglePlaces(in: coordinate, radius: CLLocationDistance(4000)) { _ in }
                }
            }
        }
    }
}

#Preview {
    SuggestionsListView(viewModel: MapViewModel())
}
