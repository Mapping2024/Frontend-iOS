import Foundation
import MapKit
import Alamofire

func MemoMatching(location: CLLocationCoordinate2D, accessToken: String) async throws -> [Item] {
    
    let lat = location.latitude
    let lng = location.longitude

    let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
    let url = "https://api.mapping.kro.kr/api/v2/memo/total?lat=\(lat)&lng=\(lng)&km=5"

    return try await withCheckedThrowingContinuation { continuation in
        AF.request(url, method: .get, headers: headers).responseDecodable(of: MemoResponse.self) { response in
            switch response.result {
            case .success(let memoResponse):
                if memoResponse.success {
                    let mapItems = memoResponse.data.map { memoData -> Item in
                        
                        let mapItem: Item = Item(
                            id: memoData.id,
                            title: memoData.title,
                            category: memoData.category,
                            location: CLLocationCoordinate2D(latitude: memoData.lat, longitude: memoData.lng),
                            secret: memoData.secret
                        )
                        return mapItem
                    }
                    continuation.resume(returning: mapItems)
                } else {
                    continuation.resume(throwing: NSError(
                        domain: "",
                        code: memoResponse.status,
                        userInfo: [NSLocalizedDescriptionKey: memoResponse.message]
                    ))
                }
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}
