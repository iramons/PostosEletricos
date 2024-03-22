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
    
    @State private var lookAroundScene: MKLookAroundScene?
    
    var selectedResult: MKMapItem
    
    var body: some View {
        VStack {
            LookAroundPreview(initialScene: lookAroundScene)
                .overlay(alignment: .bottomTrailing) {
                    HStack {
                        Text(selectedResult.placemark.name ?? "SEMNOME")
                    }
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(18)
                }
                .onAppear {
                    getLookAroundScene()
                }
                .onChange(of: selectedResult) {
                    getLookAroundScene()
                }
        }
    }
    
    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(coordinate: selectedResult.placemark.coordinate)
            lookAroundScene = try? await request.scene
        }
    }
}

#Preview {
    LocationPreviewLookAroundView(selectedResult: MKMapItem(placemark: .init(coordinate: .init(latitude: -20.4844352, longitude: -69.3907158))))
}
