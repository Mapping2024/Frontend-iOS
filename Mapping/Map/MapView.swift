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
    @State private var selectedPinID: Int? = nil
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
                            if (memo.category == "쓰레기통") {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(Color.black)
                                    .background(Circle().fill(Color.white))
                            } else if(memo.category == "공용 화장실") {
                                Image(systemName: "toilet.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(Color.blue)
                                    .background(Circle().fill(Color.white))
                            } else if (memo.category == "흡연장") {
                                Image(systemName: "smoke.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(Color.gray)
                                    .background(Circle().fill(Color.white))
                            } else {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(Color.yellow)
                                    .background(Circle().fill(Color.white))
                            }
                            Text(memo.title) // 메모 제목 표시
                                .font(.caption)
                        }
                        .onTapGesture {
                            selectedPinID = memo.id
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
                .sheet(isPresented: Binding<Bool>(
                    get: { selectedPinID != nil }, // selectedPinID가 nil이 아니면 시트를 열어야 함
                    set: { newValue in
                        if !newValue {
                            selectedPinID = nil // 시트가 닫힐 때 selectedPinID를 nil로 설정하여 상태 초기화
                        }
                    })
                ) {
                    if let pinId = selectedPinID {
                        MemoDetailView(id: pinId)
                            .presentationDetents([.medium, .large])
                    }
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
                                        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
                                }
                            } else {
                                Button(action: {}) {
                                    Image(systemName: "mappin.and.ellipse.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50)
                                        .background(Circle().fill(Color.gray))
                                        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
                                }.disabled(true)
                            }
                            ProfileImageView()
                                .frame(width:50, height:50)
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
