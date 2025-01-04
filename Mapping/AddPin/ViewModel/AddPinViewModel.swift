import SwiftUI
import MapKit

class AddPinViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var pinCoordinate: CLLocationCoordinate2D? = nil
    @Published var isPinActive: Bool = false
    @Published var mapView = MKMapView()

    private let locationManager = LocationManager.shared

    init() {
        self.region = locationManager.region
    }

    /// 핀 제거 로직
    func removePin() {
        pinCoordinate = nil
        isPinActive = false
        mapView.removeAnnotations(mapView.annotations)
    }

    /// 현재 위치 갱신
    func updateCurrentLocation() {
        region = locationManager.region
    }
}
