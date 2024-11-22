//
//  LocationManager.swift
//  Mapping
//
//  Created by 김민정 on 11/3/24.
//
import SwiftUI
import MapKit

enum LocationError: LocalizedError {
    case authorizationDenied
    case authorizationRestricted
    case unknownLocation
    case accessDenied
    case network
    case operationFailed
    
    var errorDescription: String? {
        switch self {
            case .authorizationDenied:
                return NSLocalizedString("위치 접근 거부", comment: "")
            case .authorizationRestricted:
                return NSLocalizedString("위치 접근 금지", comment: "")
            case .unknownLocation:
                return NSLocalizedString("위치 알 수 없음", comment: "")
            case .accessDenied:
                return NSLocalizedString("접근 불가", comment: "")
            case .network:
                return NSLocalizedString("네트워크 에러", comment: "")
            case .operationFailed:
                return NSLocalizedString("실행 실패", comment: "")
        }
    }
}

@Observable // 이 코드를 사용하면 클래스를 Observable로 만들겠다는 메크로
class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager() // 싱글톤이다.
    var manager: CLLocationManager = CLLocationManager() // 이게 진짜 LoactionManager이고 위치 권한에 대한 것들을 담당한다.
    var region: MKCoordinateRegion = MKCoordinateRegion() // @Observation으로 메크로를 설정해놔서 @Published를 설정하지 않아도 이미 Published 되어 있다.
    var error: LocationError? = nil
    
    override init() {
        super.init()
        self.manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // locationManagerDidChangeAuthorization의 좋은점은 LocationManager가 실행될때마다 자동으로 실행된다.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization() // 앱을 사용중일때 물어본다.
        case .authorizedAlways, .authorizedWhenInUse: // 항상 허용, 앱을 실행중일때만 허용
            manager.requestLocation() // 위치를 한번 요청한다.
        case .denied:
            error = .authorizationDenied
        case .restricted:
            error = .authorizationRestricted
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            // span = 확대 정도
            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
                case .locationUnknown:
                    self.error = .unknownLocation
                case .denied:
                    self.error = .authorizationRestricted
                default:
                    break
            }
        }
    }
}


