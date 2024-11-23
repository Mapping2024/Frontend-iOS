//
//  AddPinView.swift
//  Mapping
//
//  Created by 김민정 on 11/6/24.
//

import SwiftUI
import MapKit

struct AddPinView: View {
    @State private var locationManager = LocationManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var pinCoordinate: CLLocationCoordinate2D? = nil
    @State private var isPinActive: Bool = false
    @State private var showModal = false
    @State private var mapView = MKMapView()
    
    var body: some View {
        NavigationView{
            ZStack {
                CustomMapView(
                    mapView: $mapView,
                    region: $region,
                    pinCoordinate: $pinCoordinate,
                    isPinActive: $isPinActive
                )
                .edgesIgnoringSafeArea(.bottom)
                
                VStack {
                    Spacer()
                    if let coordinate = pinCoordinate {
                        Text("Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                            .padding()
                    } else {
                        Text("지도를 길게 눌러 핀을 생성하세요.")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                            .padding()
                    }
                }
            }
        }
        .navigationTitle("핀 생성하기")
        .navigationBarItems(
            trailing:
                Button(action: {
                    showModal = true
                }) {
                    Image(systemName: "plus")
                }
                .disabled(!isPinActive)
                .sheet(isPresented: $showModal, onDismiss: {
                    removePin()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    if let coordinate = pinCoordinate {
                        AddPinModal(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            .presentationDetents([.medium, .large])
                    }
                }
        )
    }
    
    private func removePin() {
        pinCoordinate = nil
        isPinActive = false
        mapView.removeAnnotations(mapView.annotations)
    }
}

#Preview {
    AddPinView()
}
