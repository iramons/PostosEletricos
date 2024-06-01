//
//  LaunchView.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 29/03/24.
//

import SwiftUI
import Lottie
import Resolver

struct LaunchView: View {

    @EnvironmentObject var navigationManager: NavigationManager
    @ObservedObject var locationManager = LocationManager.shared
    @State private var showAppName: Bool = false

    var body: some View {
        ZStack {
            Text(Bundle.main.appName)
                .font(.custom("CairoPlay-Regular", size: 36))
                .foregroundStyle(.darknessGreen)
                .offset(y: showAppName ? -60 : 0)
                .opacity(showAppName ? 1 : 0)
                .scaleEffect(showAppName ? 1.1 : 1)
                .animation(.easeIn(duration: 0.6), value: showAppName)
                .zIndex(1)

            GeometryReader { geo in
                VStack(spacing: .zero) {
                    Image("launch-night")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: geo.size.width)

                    Rectangle()
                        .fill(.gray)
                        .frame(height: heightForStreetRectangle)
                }
            }

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    LottieView(animation: .named("car-charging-station-anim"))
                        .playbackMode(.playing(.fromFrame(0, toFrame: 100, loopMode: .autoReverse)))
                        .resizable()
                        .padding(.top, 300)
                        .padding(.leading, UIScreen.main.bounds.height > 932 ? 300 : 100)
                        .padding(.trailing)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                Spacer()

                HStack {
                    LottieView(animation: .named("launch-dog-anim"))
                        .looping()
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom)
                        .padding(.trailing, UIScreen.main.bounds.height > 932 ? 720 : 300)

                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
        .background(.darknessGreen)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn) {
                    showAppName.toggle()
                }
            }
        }
        .onChange(of: showAppName) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    navigationManager.currentView = .map
                }
            }
        }
    }

    private var heightForStreetRectangle: CGFloat {
        switch UIScreen.main.bounds.height {
        case 0...667: return 100 // iphone SE 3G
        case 668...852: return 190 // iphone 15 Pro
        case 853...896: return 200 // iphone 11
        case 896...932: return 220 // iphone 15 pro MAX
        case 932...1366: return 310 // ipad Pro - 12.9 inch
        default: return 200 // iphone 11
        }
    }
}

#Preview {
    @StateObject var navigationManager = NavigationManager()

    return LaunchView()
        .environmentObject(navigationManager)
}
