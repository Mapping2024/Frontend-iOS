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
    @Environment(\.dismiss) private var dismiss
    @Binding var update: Bool
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var pinCoordinate: CLLocationCoordinate2D? = nil
    @State private var isPinActive: Bool = false
    @State private var dataInput = false
    @State var backFlag: Bool = false
    @State private var mapView = MKMapView()
    
    var body: some View {
        NavigationStack{
            ZStack {
                CustomMapView(
                    mapView: $mapView,
                    region: $locationManager.region,
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
        .navigationBarItems(
            leading: Text("핀 생성").font(.headline),
            trailing: Group {
                if let coordinate = pinCoordinate {
                    NavigationLink(destination: AddPinDetailView(backFlag: $backFlag, latitude: coordinate.latitude, longitude: coordinate.longitude)
                        .onDisappear {
                            removePin()
                            if backFlag {
                                update = true
                                dismiss()
                            }
                        }) {
                            Image(systemName: "plus")
                        }
                } else {
                    Image(systemName: "plus")
                        .disabled(true)
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
    AddPinView(update: .constant(false))
}
