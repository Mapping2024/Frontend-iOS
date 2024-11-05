////
////  MapView.swift
////  Mapping
////
////  Created by 김민정 on 11/2/24.
////
//
//import SwiftUI
//import MapKit
//import Alamofire
//
//struct MemoLocation: Identifiable, Decodable {
//    let id: Int
//    let title: String
//    let category: String
//    let lat: Double
//    let lng: Double
//}
//
//struct MemoResponse: Decodable {
//    let status: Int
//    let success: Bool
//    let message: String
//    let data: [MemoLocation]
//}
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
//    private func removePin() {
//        pinCoordinate = nil
//        isPinActive = false
//        mapView.removeAnnotations(mapView.annotations)
//        addAnnotations()
//    }
//}
//
//#Preview {
//    MapView()
//        .environmentObject(UserManager())
//}
