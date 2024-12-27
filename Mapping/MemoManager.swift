import Foundation
import MapKit
import Alamofire

func MemoMatching(location: CLLocationCoordinate2D, accessToken: String) async throws -> [Item] {
    
    let lat = location.latitude
    let lng = location.longitude

    let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
    let url = "https://api.mapping.kro.kr/api/v2/memo/total?lat=\(lat)&lng=\(lng)&km=1"

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

// MemoData와 MemoResponse 정의
struct MemoData: Identifiable, Decodable {
    let id: Int
    let title: String
    let category: String
    let lat: Double
    let lng: Double
    let certified: Bool
    let secret: Bool
}

struct MemoResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: [MemoData]
}

struct Item: Identifiable, Hashable, Equatable {
    let id: Int
    let title: String
    let category: String
    let location: CLLocationCoordinate2D
    let secret: Bool
    
    static func == (lhs: Item, rhs: Item) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.title == rhs.title &&
                   lhs.category == rhs.category &&
                   lhs.location.latitude == rhs.location.latitude &&
                   lhs.location.longitude == rhs.location.longitude &&
                   lhs.secret == rhs.secret
        }
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(title)
            hasher.combine(category)
            hasher.combine(location.latitude)
            hasher.combine(location.longitude)
            hasher.combine(secret)
        }
}
