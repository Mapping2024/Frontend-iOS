//
//  ContentView.swift
//  Mapping
//
//  Created by 김민정 on 11/2/24.
//

import SwiftUI
import MapKit
import CoreLocationUI

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

import CoreLocationUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .ignoresSafeArea()
            .onAppear {
                locationManager.requestLocation()
            }
            .onChange(of: locationManager.userLocation) { oldLocation, newLocation in
                if let newLocation = newLocation {
                    region.center = newLocation.coordinate
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserManager())
}
