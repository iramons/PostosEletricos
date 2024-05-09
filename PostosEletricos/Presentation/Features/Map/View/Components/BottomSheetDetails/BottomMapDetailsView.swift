//
//  BottomMapDetailsView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/03/24.
//

import Foundation
import SwiftUI
import MapKit

struct BottomMapDetailsView: View {

    enum BottomMapDetailsViewActionType {
        case close
        case route
    }

    var place: Place
    var isRoutePresenting: Bool
    @State var lookAroundScene: MKLookAroundScene?
    var action: ((BottomMapDetailsViewActionType) -> Void)

    var placeCoordinate: CLLocationCoordinate2D? {
        guard let lat = place.geometry?.location?.lat,
              let lng = place.geometry?.location?.lng
        else { return nil }

        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                action(.close)
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.gray.opacity(0.6))
                    .padding(12)
            })
            .zIndex(1)

            VStack(alignment: .trailing) {
                Text(place.name)
                    .multilineTextAlignment(.leading)
                    .font(.custom("Roboto-Bold", size: 18))
                    .foregroundStyle(.primary)
                    .padding(.top, 12)
                    .padding(.leading, 16)
                    .padding(.trailing, 40)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let vicinity = place.vicinity {
                    Text(vicinity)
                        .multilineTextAlignment(.leading)
                        .font(.custom("Roboto-Medium", size: 14))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 17)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                let opened = place.openingHours?.openNow ?? false
                let openedTitle = opened ? "Aberto" : "Fechado"
                Text(openedTitle)
                    .multilineTextAlignment(.leading)
                    .font(.custom("Roboto-Medium", size: 14))
                    .foregroundStyle(opened ? .accent : .orange)
                    .padding(.horizontal, 17)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(
                    action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        action(.route)
                    },
                    label: {
                        Text(isRoutePresenting ? "Remover rota" : "Mostrar rota")
                            .multilineTextAlignment(.center)
                            .font(.custom("RobotoCondensed-Bold", size: 15))
                            .foregroundStyle(.white)
                            .padding(.leading, 12)
                            .padding(.vertical, 4)

                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .foregroundStyle(.yellow)
                            .padding(.vertical, 6)
                            .padding(.trailing, 12)
                    }
                )
                .opensMap(at: placeCoordinate)
                .background(isRoutePresenting ? .red : .indigo)
                .cornerRadius(10)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, alignment: .trailing)

                HStack(alignment: .bottom) {
                    if lookAroundScene != nil {
                        LookAroundPreview(
                            initialScene: lookAroundScene,
                            badgePosition: .topTrailing
                        )
                        .frame(width: 100, height: 100, alignment: .trailing)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 10)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .background(.thinMaterial)
        .cornerRadius(20)
        .shadow(radius: 4)
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
        .onChange(of: place) {
            getLookAroundScene()
        }
        .onAppear {
            getLookAroundScene()
        }
    }

    private func getLookAroundScene() {
        withAnimation {
            lookAroundScene = nil
        }

        guard let location = place.geometry?.location else { return }
        let coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
        let request = MKLookAroundSceneRequest(coordinate: coordinate)

        Task { 
            let scene = try? await request.scene

            withAnimation {
                lookAroundScene = scene
            }
        }
    }
}

#Preview {
    let place = Place(
        name: "BYD Posto elétrico",
        vicinity: "Rua das Pedras, 1",
        geometry: Geometry(location: Location(lat: 48.856788, lng: 2.351077))
    )

    return BottomMapDetailsView(
        place: place,
        isRoutePresenting: false,
        action: { _ in }
    )
}
