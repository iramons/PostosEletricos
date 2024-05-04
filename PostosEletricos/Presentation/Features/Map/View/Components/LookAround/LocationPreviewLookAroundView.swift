//
//  LocationPreviewLookAroundView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 11/03/24.
//

import Foundation
import SwiftUI
import MapKit

struct LocationPreviewLookAroundView: View {

    @State var lookAroundScene: MKLookAroundScene?

    var place: Place

    var body: some View {
        VStack {
            LookAroundPreview(initialScene: lookAroundScene)
                .overlay(alignment: .bottomTrailing) {
                    HStack {
                        Text(place.name ?? "SEMNOME")
                    }
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(18)
                }
                .onChange(of: place) {
                    getLookAroundScene()
                }
                .onAppear {
                    getLookAroundScene()
                }
        }
    }

    private func getLookAroundScene() {
        lookAroundScene = nil

            _Concurrency.Task {
                let coordinate = CLLocationCoordinate2D(latitude: place.geometry?.location?.lat ?? 0, longitude: place.geometry?.location?.lng ?? 0)
                let request = MKLookAroundSceneRequest(coordinate: coordinate)
                lookAroundScene = try? await request.scene
            }
    }
}

#Preview {
    LocationPreviewLookAroundView(place: Place())
}
