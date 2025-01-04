import SwiftUI
import Alamofire
import CoreLocation

class AddPinDetailViewModel: ObservableObject {
    
    @Published var pinName: String = ""
    @Published var pinDescription: String = ""
    @Published var selectedCategory: PinCategory = .other
    @Published var selectedImages: [UIImage] = []
    @Published var secret: Bool = false
    @Published var uploadSuccessText: String? = nil
    @Published var uploadSuccess: Bool = false
    @Published var isPickerPresented: Bool = false

    private var latitude: Double
    private var longitude: Double
    private var currentLocation: CLLocationCoordinate2D
    

    init(latitude: Double, longitude: Double, currentLocation: CLLocationCoordinate2D) {
        self.latitude = latitude
        self.longitude = longitude
        self.currentLocation = currentLocation
    }

    func createPin(accessToken: String) {
        let url = "https://api.mapping.kro.kr/api/v2/memo/new"

        let parameters: [String: String] = [
            "title": pinName,
            "content": pinDescription,
            "lat": "\(latitude)",
            "lng": "\(longitude)",
            "category": selectedCategory.rawValue,
            "secret": "\(secret)",
            "currentLat": "\(currentLocation.latitude)",
            "currentLng": "\(currentLocation.longitude)"
        ]

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "multipart/form-data"
        ]

        let query = parameters.map { "\($0)=\($1)" }.joined(separator: "&")
        let fullURL = "\(url)?\(query)"

        AF.upload(multipartFormData: { multipartFormData in
            for (index, image) in self.selectedImages.enumerated() {
                if let compressedImageData = image.jpegData(compressionQuality: 0.5) {
                    multipartFormData.append(compressedImageData, withName: "images", fileName: "image\(index).jpg", mimeType: "image/jpeg")
                }
            }
        }, to: fullURL, headers: headers).response { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success:
                    self.uploadSuccess = true
                    self.uploadSuccessText = "핀 생성 완료"
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print("요청 성공: \(responseString)")
                    } else {
                        print("요청 성공: 데이터 없음")
                    }
                case .failure(let error):
                    self.uploadSuccess = true
                    self.uploadSuccessText = "핀 생성 오류 다시 한번 시도해 주세요"
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print("요청 실패: \(error)\n응답 내용: \(responseString)")
                    } else {
                        print("요청 실패: \(error)")
                    }
                }
            }
        }
    }
}
