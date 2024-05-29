//
//  BottomSheetMapView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 12/03/24.
//

import Foundation
import SwiftUI
import MapKit

struct BottomSheetMapView: View {

    enum BottomMapDetailsViewActionType {
        case close
        case route
    }

    private enum Constants {
        static let middleTitleDetailsSpacing: CGFloat = 2
    }

    var place: Place
    var isRoutePresenting: Bool
    var travelTime: String?
    var showBannerAds: Bool
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
                    .padding(16)
            })
            .zIndex(1)

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: .zero) {
                    HStack {
                        Text(place.opened ? "Aberto agora" : "Fechado")
                            .font(.custom("Roboto-Black", size: 13))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(place.opened ? .accent : .red)
                            .foregroundStyle(.white)
                            .clipShape(.capsule)
                            .padding(.bottom, 2)

                        if isRoutePresenting, let travelTime {
                            Text("Tempo estimado: ∼\(travelTime)")
                                .multilineTextAlignment(.leading)
                                .minimumScaleFactor(0.5)
                                .font(.custom("Roboto-Bold", size: 14))
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.trailing, 60)

                    Text(place.name)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.5)
                        .font(.custom("Roboto-Bold", size: 18))
                        .foregroundStyle(.primary)

                    HStack(alignment: .bottom, spacing: 6) {
                        if let fullAddress = place.fullAddress {
                            Text(fullAddress)
                                .multilineTextAlignment(.leading)
                                .font(.custom("Roboto-Medium", size: 14))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

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
                                    .padding(.vertical, 6)

                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                    .foregroundStyle(.yellow)
                                    .padding(.vertical, 6)
                                    .padding(.trailing, 12)
                            }
                        )
                        .background(isRoutePresenting ? .red : .indigo)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                    }

                    Divider()
                        .foregroundStyle(.gray)
                        .padding(.vertical, 6)

                    HStack(alignment: .top, spacing: 4) {
                        VStack(alignment: .leading, spacing: 4) {
                            /// phoneNumber
                            if let phoneNumber = place.phoneNumber {
                                VStack(alignment: .leading, spacing: Constants.middleTitleDetailsSpacing) {
                                    HStack {
                                        Image(systemName: "phone")

                                        Text("Telefones")
                                            .font(.custom("Roboto-Medium", size: 14))
                                    }

                                    Link(phoneNumber, destination: URL(string: "tel:\(phoneNumber)")!)
                                        .font(.custom("Roboto-Medium", size: 15))
                                        .foregroundColor(.blue)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .background()
                                .clipShape(.rect(cornerRadius: 12))
                            }

                            /// website
                            if let website = place.website {
                                VStack(alignment: .leading, spacing: Constants.middleTitleDetailsSpacing) {
                                    HStack {
                                        Image(systemName: "globe")

                                        Text("Website")
                                            .multilineTextAlignment(.leading)
                                            .font(.custom("Roboto-Medium", size: 14))
                                            .minimumScaleFactor(0.8)
                                            .lineLimit(1)
                                    }

                                    Link(website, destination: URL(string: website)!)
                                        .font(.custom("Roboto-Medium", size: 15))
                                        .multilineTextAlignment(.leading)
                                        .minimumScaleFactor(0.8)
                                        .lineLimit(1)
                                        .foregroundColor(.blue)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background()
                                .clipShape(.rect(cornerRadius: 12))
                            }
                        }

                        /// schedules
                        if let periods = place.openingHours?.periods {
                            VStack(alignment: .leading, spacing: Constants.middleTitleDetailsSpacing) {
                                HStack {
                                    Image(systemName: "clock")

                                    Text("Horários")
                                        .font(.custom("Roboto-Medium", size: 14))
                                }

                                let columns = [GridItem(.fixed(100)), GridItem(.fixed(50)), GridItem(.fixed(50))]

                                LazyVGrid(columns: columns, alignment: .leading, spacing: .zero) {
                                    ForEach(periods, id: \.self) { period in
                                        Text(period.dayOfWeek())
                                            .multilineTextAlignment(.leading)
                                            .font(.custom("Roboto-Medium", size: 15))
                                            .minimumScaleFactor(0.8)
                                            .foregroundStyle(.secondary)

                                        Text(period.formattedOpenTime())
                                            .multilineTextAlignment(.leading)
                                            .font(.custom("Roboto-Medium", size: 15))
                                            .minimumScaleFactor(0.8)
                                            .foregroundStyle(.secondary)

                                        Text(period.formattedCloseTime())
                                            .multilineTextAlignment(.leading)
                                            .font(.custom("Roboto-Medium", size: 15))
                                            .minimumScaleFactor(0.8)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(8)
                            .background()
                            .clipShape(.rect(cornerRadius: 12))
                        }
                    }
                    .padding(.top, 4)

                    if lookAroundScene != nil {
                        LookAroundPreview(
                            initialScene: lookAroundScene,
                            badgePosition: .bottomTrailing
                        )
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.top, 16)
                        .shadow(radius: 4)
                    }

                    if showBannerAds {
                        BannerAdsView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 60)
                            .clipShape(.rect(cornerRadius: 12))
                            .padding(.top, 16)
                    }

                }
                .padding(.horizontal, 8)
                .padding(.vertical, 16)
            }
        }
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
        name: "Posto elétrico com nome muito grande e estrondoso",
        vicinity: "Rua das Pedras de São Pedro de Rio, número 1245, cep 22343445. Brasil,Mundo",
        geometry: Geometry(location: Location(lat: 48.856788, lng: 2.351077)),
        openingHours: OpeningHours(
            openNow: true,
            periods: [
                Period(
                    open: PeriodDayAndTime(day: 1, time: "0600"),
                    close: PeriodDayAndTime(day: 1, time: "2300")
                ),
                Period(
                    open: PeriodDayAndTime(day: 2, time: "0800"),
                    close: PeriodDayAndTime(day: 2, time: "1800")
                ),
                Period(
                    open: PeriodDayAndTime(day: 3, time: "0900"),
                    close: PeriodDayAndTime(day: 3, time: "2000")
                )
            ]
        ),
        currentOpeningHours: OpeningHours(
            openNow: true,
            weekdayText: [
                "segunda-feira: 07:00 – 22:00",
                "terça-feira: 07:00 – 22:00",
                "quarta-feira: 07:00 – 22:00",
                "quinta-feira: 07:00 – 22:00",
                "sexta-feira: 07:00 – 22:00",
                "sábado: 07:00 – 22:00",
                "domingo: Fechado"
            ]
        ),
        phoneNumber: "(21) 9999-9999",
        website: "https://github.com/iramons.comfddfdf"
    )

    return ZStack {
//        MapView(viewModel: MapViewModel())

        VStack {
            Spacer()

            BottomSheetMapView(
                place: place,
                isRoutePresenting: false,
                showBannerAds: true,
                action: { _ in }
            )
        }
    }
}
