//
//  MapHeaderView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/11/23.
//

import SwiftUI
import Lottie

struct MapHeaderView: View {

    init(
        withAnimation animation: Namespace.ID,
        viewModel: MapViewModel
    ) {
        self.animation = animation
        self.viewModel = viewModel
    }

    let animation: Namespace.ID
    @State var canShowProgress: Bool = false
    @ObservedObject var viewModel: MapViewModel

    var body: some View {


        VStack(spacing: .zero) {
            HStack {
                LottieView(animation: .named("splash-anim"))
                    .looping()
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(.bottom, 4)
                    .matchedGeometryEffect(id: "splashLogoAnimId", in: animation)

                Text("Postos Elétricos")
                    .font(.title)

                Spacer()

                Button {
                    withAnimation {
                        viewModel.isSearchBarVisible.toggle()
                        viewModel.showFindInAreaButton = false
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

            if !viewModel.placesFromSearch.isEmpty {
                List(viewModel.placesFromSearch, id: \.placeID) { place in
                    VStack(alignment: .leading) {
                        Text(place.name ?? "")
                            .font(.headline)
                        Text(place.vicinity ?? "")
                            .font(.subheadline)
                    }
                }
            }
        }
        .background(
            Color
                .white
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 8)
                .matchedGeometryEffect(id: "splashBackgroundAnimId", in: animation)
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
        MapHeaderView(withAnimation: animation, viewModel: MapViewModel())
        Rectangle().fill(.gray.opacity(0.2)).frame(maxHeight: .infinity)
    }
}
