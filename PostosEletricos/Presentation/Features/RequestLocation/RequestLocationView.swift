//
//  RequestLocationView.swift
//  PostosEletricos
//
//  Created by Sportheca Brasil on 15/05/24.
//

import SwiftUI
import Resolver

struct RequestLocationView: View {

//    @Injected var locationService: LocationService
    @ObservedObject var locationManager = LocationManager.shared

    @Environment(\.dismiss) var dismiss
    @State var origin: OriginFlow = .none
    @State var showLaunchView: Bool = false
    @State var showMapView: Bool = false

    var body: some View {
        ZStack {
            GeometryReader { geo in
                Image("nature-orange")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)

                VStack(spacing: 32) {
                    Text("Serviços de localização")
                        .foregroundStyle(.black)
                        .font(.custom("Roboto-Bold", size: 28))
                        .multilineTextAlignment(.center)
                        .shadow(color: .red, radius: 4)
                        .padding(.horizontal, 36)

                    Image("request-location-app-representation")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geo.size.width)
                        .padding(.horizontal, 60)
                        .clipShape(.circle)
                        .opacity(0.8)
                        .shadow(radius: 10)

                    Text("Precisamos de sua localização para mostrar os postos elétricos mais próximos de você.")
                        .foregroundStyle(.white)
                        .font(.custom("Roboto-Bold", size: 22))
                        .multilineTextAlignment(.center)
                        .shadow(radius: 4)
                        .padding(.horizontal, 36)
                }
                .frame(maxWidth: geo.size.width, maxHeight: geo.size.height, alignment: .center)

                VStack {
                    Spacer()

                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        locationManager.requestAuthorization()
                    }, label: {
                        Text("Continuar".uppercased())
                            .font(.custom("Roboto-Bold", size: 17))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(.accent.opacity(0.9))
                            .foregroundStyle(.white)
                    })
                    .clipShape(.rect(cornerRadii: .init(topLeading: 32, bottomLeading: 0, bottomTrailing: 0, topTrailing: 32)))
                    .shadow(radius: 4)
                }
                .frame(maxWidth: geo.size.width)
                .zIndex(1)
            }
        }
        .ignoresSafeArea()
        .onChange(of: locationManager.isAuthorized) {
            withAnimation { showMapView.toggle() }
        }
        .onChange(of: locationManager.isDenied) {
            withAnimation { showMapView.toggle() }
        }
        .fullScreenCover(isPresented: $showMapView) {
            MapView()
        }
    }
}

// MARK: - Preview

#Preview {
    RequestLocationView()
}
