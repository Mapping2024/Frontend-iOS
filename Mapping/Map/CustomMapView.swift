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
    @Binding var isPinActive: Bool

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        // Long-press gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.addPin(gesture:)))
        mapView.addGestureRecognizer(longPressGesture)
        mapView.showsUserTrackingButton = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 사용자가 핀을 찍은 경우에는 setRegion을 호출하지 않음
        if !isPinActive {
            uiView.setRegion(region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView

        init(_ parent: CustomMapView) {
            self.parent = parent
        }
        
        @objc func addPin(gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                let location = gesture.location(in: parent.mapView)
                let coordinate = parent.mapView.convert(location, toCoordinateFrom: parent.mapView)
                
                // Set the pin coordinate and activate the pin
                parent.pinCoordinate = coordinate
                parent.isPinActive = true
                
                // Remove previous annotations and add new one
                parent.mapView.removeAnnotations(parent.mapView.annotations)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                parent.mapView.addAnnotation(annotation)
            }
        }
    }
}

//struct CustomMapView: UIViewRepresentable {
//    @Binding var mapView: MKMapView
//    @Binding var region: MKCoordinateRegion
//    @Binding var pinCoordinate: CLLocationCoordinate2D?
//    @Binding var isPinActive: Bool
//    @Binding var memoLocations: [MemoLocation]
//    @Binding var selectedLocationID: Int? // ID만 저장하도록 변경
//    @Binding var showDetailModal: Bool
//
//    func makeUIView(context: Context) -> MKMapView {
//        mapView.showsUserLocation = true
//        mapView.setRegion(region, animated: true)
//        mapView.delegate = context.coordinator
//
//        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
//        mapView.addGestureRecognizer(longPressGesture)
//
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//        uiView.setRegion(region, animated: true)
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, MKMapViewDelegate {
//        var parent: CustomMapView
//
//        init(_ parent: CustomMapView) {
//            self.parent = parent
//        }
//
//        @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
//            if gestureRecognizer.state == .began {
//                let locationInView = gestureRecognizer.location(in: gestureRecognizer.view)
//                let coordinate = (gestureRecognizer.view as! MKMapView).convert(locationInView, toCoordinateFrom: gestureRecognizer.view)
//
//                parent.pinCoordinate = coordinate
//                parent.isPinActive = true
//
//                (gestureRecognizer.view as! MKMapView).removeAnnotations((gestureRecognizer.view as! MKMapView).annotations)
//
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = coordinate
//                annotation.title = "핀 위치"
//                (gestureRecognizer.view as! MKMapView).addAnnotation(annotation)
//            }
//        }
//
//        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//            guard let annotation = view.annotation else { return }
//
//            if let location = parent.memoLocations.first(where: {
//                $0.lat == annotation.coordinate.latitude && $0.lng == annotation.coordinate.longitude
//            }) {
//                parent.selectedLocationID = location.id
//                parent.showDetailModal = true
//            }
//        }
//    }
//}
