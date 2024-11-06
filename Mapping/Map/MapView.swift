//
//  MapView.swift
//  Mapping
//
//  Created by 김민정 on 11/2/24.
//

import SwiftUI
import MapKit
import Alamofire
//import CoreLocationUI

struct MapView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var locationManager = LocationManager()
    @State private var memoLocations: [MemoLocation] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // 현재 위치 출력용
    @State private var currentLatitude: Double?
    @State private var currentLongitude: Double?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $region, interactionModes: .all ,showsUserLocation: true, annotationItems: memoLocations) {memo in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: memo.lat, longitude: memo.lng)) {
                        VStack {
                            Image(systemName: "star.fill") // 예시: 별 모양 아이콘
                                .foregroundColor(.yellow)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(Color.white))
                            Text(memo.title) // 메모 제목 표시
                                .font(.caption)
                        }
                        .onTapGesture {
                            // 클릭 시 동작 예시 (메모 상세 보기)
                            print("Tapped on \(memo.title)")
                        }
                    }
                }
                .ignoresSafeArea(.all)
                .onAppear {
                    locationManager.requestLocation()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        fetchMemoLocations()
                    }
                }
                .onChange(of: locationManager.userLocation) { oldLocation, newLocation in
                    if let newLocation = newLocation {
                        region.center = newLocation.coordinate
                        currentLatitude = newLocation.coordinate.latitude
                        currentLongitude = newLocation.coordinate.longitude
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            if userManager.isLoggedIn {
                                NavigationLink(destination: AddPinView()) {
                                    Image(systemName: "mappin.and.ellipse.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50)
                                        .background(Circle().fill(Color.white))
                                        .foregroundStyle(Color.skyBlue)
                                }
                            } else {
                                Button(action: {}) {
                                    Image(systemName: "mappin.and.ellipse.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50)
                                        .background(Circle().fill(Color.white))
                                }.disabled(true)
                            }
                            ProfileImageView()
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            if userManager.isLoggedIn && userManager.userInfo == nil {
                userManager.fetchUserInfo()
            }
        }
    }
    private func fetchMemoLocations() {
        guard let lat = currentLatitude, let lng = currentLongitude else {
            print("위치 정보가 아직 없습니다.")
            return
        }
        let accessToken = userManager.accessToken
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        let url = "https://api.mapping.kro.kr/api/v2/memo/total?lat=\(lat)&lng=\(lng)&km=5"
        
        AF.request(url, method: .get, headers: headers).responseDecodable(of: MemoResponse.self) { response in
            switch response.result {
            case .success(let memoResponse):
                if memoResponse.success {
                    self.memoLocations = memoResponse.data
                    //print("Successfully fetched memo locations: \(memoResponse.data)")
                    //addAnnotations()
                } else {
                    print("Failed to fetch memo locations: \(memoResponse.message)")
                }
            case .failure(let error):
                print("Error fetching memo locations: \(error)")
            }
        }
    }
    
}

#Preview {
    MapView()
        .environmentObject(UserManager())
}

struct MemoLocation: Identifiable, Decodable {
    let id: Int
    let title: String
    let category: String
    let lat: Double
    let lng: Double
}

struct MemoResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: [MemoLocation]
}
//
//struct MapView: View {
//    @EnvironmentObject var userManager: UserManager
//    @StateObject private var locationManager = LocationManager()
//    @State private var showModal = false
//    @State private var pinCoordinate: CLLocationCoordinate2D? = nil
//    @State private var isPinActive: Bool = false
//    @State private var mapView = MKMapView()
//    @State private var memoLocations: [MemoLocation] = []
//
//    // 선택한 핀의 ID만 저장
//    @State private var selectedLocationID: Int? = nil
//    @State private var showDetailModal = false
//
//    var body: some View {
//        ZStack {
//            CustomMapView(mapView: $mapView, region: $locationManager.region, pinCoordinate: $pinCoordinate, isPinActive: $isPinActive, memoLocations: $memoLocations, selectedLocationID: $selectedLocationID, showDetailModal: $showDetailModal)
//                .edgesIgnoringSafeArea(.top)
//                .onAppear {
//                    locationManager.requestLocationPermission()
//                    locationManager.startUpdatingLocation()
//                    fetchMemoLocations()
//                    addAnnotations()
//                }
//                .sheet(isPresented: $showDetailModal) {
//                    if let id = selectedLocationID {
//                        MemoDetailView(id: id)
//                            .presentationDetents([.medium, .large])
//                    }
//                }
//
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    if isPinActive {
//                        VStack{
//                            Button(action: removePin) {
//                                Image(systemName: "mappin.slash.circle.fill")
//                                    .font(.largeTitle)
//                            }
//                            .padding(.bottom)
//                            Button(action: {
//                                showModal = true
//                            }) {
//                                Image(systemName: "mappin.and.ellipse.circle.fill")
//                                    .font(.largeTitle)
//                            }
//                            .sheet(isPresented: $showModal, onDismiss: removePin) {
//                                if let coordinate = pinCoordinate {
//                                    PinMakeModal(latitude: coordinate.latitude, longitude: coordinate.longitude)
//                                        .presentationDetents([.medium, .large])
//                                }
//                            }
//                        }
//                    } else {
//                        Button(action: {}) {
//                            Image(systemName: "mappin.and.ellipse.circle.fill")
//                                .font(.largeTitle)
//                        }.disabled(true)
//                    }
//                }
//                .padding()
//            }
//
//            if let coordinate = pinCoordinate {
//                VStack {
//                    Spacer()
//                    Text("오른쪽 버튼을 눌러 핀 생성")
//                        .font(.caption)
//                        .padding()
//                        .background(Color.white.opacity(0.8))
//                        .cornerRadius(8)
//                        .padding()
//                }
//            } else {
//                VStack {
//                    Spacer()
//                    Text("지도를 꾹 눌러 핀 찍기")
//                        .font(.caption)
//                        .padding()
//                        .background(Color.white.opacity(0.8))
//                        .cornerRadius(8)
//                        .padding()
//                }
//            }
//        }
//    }
//
//    private func fetchMemoLocations() {
//        let accessToken = userManager.accessToken
//        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
//        let url = "https://api.mapping.kro.kr/api/v2/memo/total?lat=\(locationManager.region.center.latitude)&lng=\(locationManager.region.center.longitude)&km=5"
//
//        AF.request(url, method: .get, headers: headers).responseDecodable(of: MemoResponse.self) { response in
//            switch response.result {
//            case .success(let memoResponse):
//                if memoResponse.success {
//                    self.memoLocations = memoResponse.data
//                    addAnnotations()
//                } else {
//                    print("Failed to fetch memo locations: \(memoResponse.message)")
//                }
//            case .failure(let error):
//                print("Error fetching memo locations: \(error)")
//            }
//        }
//    }
//
//    private func addAnnotations() {
//        for location in memoLocations {
//            let annotation = MKPointAnnotation()
//            annotation.title = location.title
//            annotation.subtitle = location.category
//            annotation.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
//            mapView.addAnnotation(annotation)
//        }
//    }
//

//}

