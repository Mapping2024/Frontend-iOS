//
//  MapView.swift
//  Mapping
//
//  Created by 김민정 on 11/2/24.
//

import SwiftUI
import MapKit
import Alamofire

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

struct MapView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var locationManager = LocationManager()
    @State private var showModal = false
    @State private var pinCoordinate: CLLocationCoordinate2D? = nil
    @State private var isPinActive: Bool = false  // 핀 활성화 여부
    @State private var mapView = MKMapView()  // MKMapView 인스턴스 추가
    @State private var memoLocations: [MemoLocation] = [] // API로 받은 위치 데이터 배열

    var body: some View {
        ZStack {
            CustomMapView(mapView: $mapView, region: $locationManager.region, pinCoordinate: $pinCoordinate, isPinActive: $isPinActive)
                .edgesIgnoringSafeArea(.top)
                .onAppear {
                    locationManager.requestLocationPermission()
                    locationManager.startUpdatingLocation()
                    fetchMemoLocations() // 위치 데이터를 가져오는 메서드 호출
                    //print("Latitude: \(locationManager.region.center.latitude), Longitude: \(locationManager.region.center.longitude)")

                }
            
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if isPinActive {
                        VStack{
                            Button(action: removePin) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                            }
                            .padding(.bottom)
                            Button(action: {
                                showModal = true
                            }) {
                                Image(systemName: "mappin.and.ellipse.circle.fill")
                                    .font(.title)
                            }
                            .sheet(isPresented: $showModal, onDismiss: removePin) {
                                if let coordinate = pinCoordinate {
                                    PinMakeModal(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                }
                            }
                        }
                    } else {
                        Button(action: {
                        }) {
                            Image(systemName: "mappin.and.ellipse.circle.fill")
                                .font(.title)
                        }.disabled(true)
                    }
                }
                .padding()
            }
            
            if let coordinate = pinCoordinate {
                VStack {
                    Spacer()
                    Text("오른쪽 버튼을 눌러 핀 생성")
                        .font(.caption)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                        .padding()
                }
            } else {
                VStack {
                    Spacer()
                    Text("지도를 꾹 눌러 핀 찍기")
                        .font(.caption)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                        .padding()
                }
            }
        }
    }
    
    private func fetchMemoLocations() {
        // GET 요청을 보내어 위치 데이터를 가져오는 메서드
        let accessToken = userManager.accessToken
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        let url = "https://api.mapping.kro.kr/api/v2/memo/total?lat=\(locationManager.region.center.latitude)&lng=\(locationManager.region.center.longitude)&km=5"
        
        AF.request(url, method: .get, headers: headers).responseDecodable(of: MemoResponse.self) { response in
            switch response.result {
            case .success(let memoResponse):
                if memoResponse.success {
                    self.memoLocations = memoResponse.data
                    addAnnotations() // 응답을 받은 후 핀을 추가
                } else {
                    print("Failed to fetch memo locations: \(memoResponse.message)")
                }
            case .failure(let error):
                print("Error fetching memo locations: \(error)")
            }
        }
    }
    
    private func addAnnotations() {
        // 가져온 위치 데이터를 기반으로 지도에 핀을 추가
        for location in memoLocations {
            let annotation = MKPointAnnotation()
            annotation.title = location.title
            annotation.subtitle = location.category
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
            mapView.addAnnotation(annotation)
        }
    }

    private func removePin() {
        pinCoordinate = nil
        isPinActive = false
        mapView.removeAnnotations(mapView.annotations) // 실제로 화면에 표시된 핀 제거
    }
}

#Preview {
    MapView()
        .environmentObject(UserManager())
}
