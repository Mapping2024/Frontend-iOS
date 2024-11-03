//
//  MapView.swift
//  Mapping
//
//  Created by 김민정 on 11/2/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var showModal = false
    @State private var pinCoordinate: CLLocationCoordinate2D? = nil
    @State private var isPinActive: Bool = false  // 핀 활성화 여부
    @State private var mapView = MKMapView()  // MKMapView 인스턴스 추가
    
    var body: some View {
        ZStack {
            CustomMapView(mapView: $mapView, region: $locationManager.region, pinCoordinate: $pinCoordinate, isPinActive: $isPinActive)
                .edgesIgnoringSafeArea(.top)
                .onAppear {
                    locationManager.requestLocationPermission()
                    locationManager.startUpdatingLocation()
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
    
    private func removePin() {
        pinCoordinate = nil
        isPinActive = false
        mapView.removeAnnotations(mapView.annotations) // 실제로 화면에 표시된 핀 제거
    }
}

struct CustomMapView: UIViewRepresentable {
    @Binding var mapView: MKMapView
    @Binding var region: MKCoordinateRegion
    @Binding var pinCoordinate: CLLocationCoordinate2D?
    @Binding var isPinActive: Bool  // 핀 활성화 여부
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.showsUserLocation = true  // 사용자 위치 표시
        mapView.setRegion(region, animated: true)
        mapView.delegate = context.coordinator
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        
        init(_ parent: CustomMapView) {
            self.parent = parent
        }
        
        @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                let locationInView = gestureRecognizer.location(in: gestureRecognizer.view)
                let coordinate = (gestureRecognizer.view as! MKMapView).convert(locationInView, toCoordinateFrom: gestureRecognizer.view)
                
                parent.pinCoordinate = coordinate
                parent.isPinActive = true
                
                // 기존 핀 제거
                (gestureRecognizer.view as! MKMapView).removeAnnotations((gestureRecognizer.view as! MKMapView).annotations)
                
                // 새 핀 추가
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "핀 위치"
                (gestureRecognizer.view as! MKMapView).addAnnotation(annotation)
            }
        }
    }
}

#Preview {
    MapView()
}
