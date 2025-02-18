import SwiftUI
import Alamofire
import CoreLocation

class AddPinDetailViewModel: ObservableObject {
    @Published var isUploading: Bool = false // 중복 생성 방지
    
    @Published var pinName: String = ""
    @Published var pinDescription: String = ""
    @Published var selectedCategory: PinCategory = .other
    @Published var selectedImages: [UIImage] = []
    @Published var secret: Bool = false
    @Published var uploadSuccessText: String? = nil
    @Published var uploadSuccess: Bool = false
    @Published var isPickerPresented: Bool = false
    @Published var isCameraPresented = false
    @Published var isPresented = false
    
    private var latitude: Double
    private var longitude: Double
    private var currentLocation: CLLocationCoordinate2D
    
    
    init(latitude: Double, longitude: Double, currentLocation: CLLocationCoordinate2D) {
        self.latitude = latitude
        self.longitude = longitude
        self.currentLocation = currentLocation
    }
    
    func createPin(accessToken: String) {
        guard !isUploading else { return } // 중복 요청 방지
        isUploading = true
        
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
                self.isUploading = false // 요청 완료 후 다시 활성화
                switch response.result {
                case .success:
                    self.uploadSuccess = true
                    self.uploadSuccessText = "메모 생성 완료"
                case .failure:
                    self.uploadSuccess = true
                    self.uploadSuccessText = "메모 생성 오류 다시 시도해 주세요"
                }
            }
        }
    }
}
