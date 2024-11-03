//
//  CustomMapView.swift
//  Mapping
//
//  Created by 김민정 on 11/3/24.
//

import SwiftUI
import MapKit

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


//#Preview {
//    CustomMapView()
//}
