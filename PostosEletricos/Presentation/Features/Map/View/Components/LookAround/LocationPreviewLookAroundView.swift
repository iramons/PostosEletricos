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

    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        VStack {
            LookAroundPreview(initialScene: viewModel.lookAroundScene)
                .overlay(alignment: .bottomTrailing) {
                    HStack {
                        Text(viewModel.selectedItem?.placemark.name ?? "SEMNOME")
                    }
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(18)
                }
                .onAppear {
                    viewModel.getLookAroundScene()
                }
                .onChange(of: viewModel.selectedItem) {
                    viewModel.getLookAroundScene()
                }
        }
    }
}

#Preview {
    LocationPreviewLookAroundView(viewModel: MapViewModel())
}
