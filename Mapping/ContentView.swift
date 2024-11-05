//
//  ContentView.swift
//  Mapping
//
//  Created by 김민정 on 11/2/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    enum Tab {
        case map, myInfo
    }
    
    @State private var selected: Tab = .map
    
    var body: some View {
        ZStack{
            TabView(selection: $selected) {
                Group{
                    MapView()
                        .tag(Tab.map)
                    MyInfo()
                        .tag(Tab.myInfo)
                }
            }
            .toolbar(.hidden, for: .tabBar)
            VStack{
                Spacer()
                tabBar
            }
        }
        
    }
    
    var tabBar: some View {
        HStack {
            Spacer()
            Button {
                selected = .map
            } label: {
                VStack(alignment: .center) {
                    Image(systemName: "map.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22)
                    if selected == .map {
                        Text("지도")
                            .font(.system(size: 11))
                    }
                }
            }
            .foregroundStyle(selected == .map ? Color.accentColor : Color.gray)
            Spacer()
            Button {
                selected = .myInfo
            } label: {
                VStack(alignment: .center) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22)
                    if selected == .myInfo {
                        Text("내 정보")
                            .font(.system(size: 11))
                    }
                }
            }
            .foregroundStyle(selected == .myInfo ? Color.accentColor : Color.gray)
            Spacer()
        }
        //.padding()
        .frame(height: 63)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager())
}

//struct ContentView: View {
//    @EnvironmentObject var userManager: UserManager
//
//    var body: some View {
//        TabView {
//            MapView()
//                .tabItem {
//                    Image(systemName: "map.fill")
//                    Text("지도")
//                }
//
//            MyInfo()
//                .tabItem {
//                    Image(systemName: "person.fill")
//                    Text("내 정보")
//                }
//        }
//        .font(.headline)
//    }
//}

//struct ContentView: View {
//
//    var body: some View {
//        Map {
//            Marker("San Francisco City Hall", coordinate: CLLocationCoordinate2D(latitude: 37.33403809906777, longitude: -122.00932605416199))
//                .tint(.orange)
//            Annotation("San Francisco Public Library", coordinate: CLLocationCoordinate2D(latitude: 37.3359148165279, longitude: -122.00987322477263)) {
//                ZStack {
//                    Button(action: {//여기 상세보기 하는 모달창 로직
//                    }) {
//                        Image(systemName: "trash.fill")
//                    }
//                }
//            }
//            Annotation("Diller Civic Center Playground",  coordinate: CLLocationCoordinate2D(latitude: 37.33512148259535, longitude: -122.00750215212648)) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 5)
//                        .fill(Color.yellow)
//                    Text("🛝")
//                        .padding(5)
//                }
//            }
//        }
//        .mapControlVisibility(.hidden)
//    }
//}

//struct ContentView: View {
//    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic) // 마커 결과에 따른 처음 카메라 조정 Map에 매개변수 넣야함
//    @StateObject private var locationManager = LocationManager()
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
//        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
//    )
//
//    var body: some View {
//        Map(position: $position) {
//            Marker("San Francisco City Hall", systemImage: "trash.fill", coordinate: CLLocationCoordinate2D(latitude: 37.33403809906777, longitude: -122.00932605416199)).tint(.gray)
//            Marker("Diller Civic Center Playground", systemImage: "trash.fill", coordinate: CLLocationCoordinate2D(latitude: 37.33512148259535, longitude: -122.00750215212648)).tint(.black)
//        }
//        .onAppear {
//            locationManager.requestLocation()
//        }
//        .onChange(of: locationManager.userLocation) { oldLocation, newLocation in
//                    // 새로운 위치 정보를 받아올 때마다 지도 중심을 업데이트합니다.
//                    if let newLocation = newLocation {
//                        region.center = newLocation.coordinate
//                    }
//                }
//        .mapControls {
//            MapUserLocationButton()
//            MapCompass()
//            MapScaleView()
//        }
//        //.mapStyle(.standard(elevation: .realistic))
//    }
//}
