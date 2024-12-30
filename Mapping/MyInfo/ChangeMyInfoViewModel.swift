import SwiftUI
import Alamofire

class ChangeMyInfoViewModel: ObservableObject {
    @Published var selectedImage: [UIImage] = []
    @Published var isPickerPresented = false
    @Published var uploadSuccessText: String? = nil
    @Published var uploadSuccess = false
    @Published var newNickname: String = ""
    
    func uploadProfileImage(userManager: UserManager) {
        userManager.fetchUserInfo()
        guard let selectedImage = selectedImage.first else { return }
        
        let url = "https://api.mapping.kro.kr/api/v2/member/modify-profile-image"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(userManager.accessToken)",
            "Content-Type": "multipart/form-data"
        ]
        let uniqueFileName = "profile_\(UUID().uuidString).png"
        
        AF.upload(multipartFormData: { multipartFormData in
            if let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
                multipartFormData.append(imageData, withName: "image", fileName: uniqueFileName, mimeType: "image/png")
            }
        }, to: url, method: .patch, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                if let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let status = jsonResponse["status"] as? Int, status == 200 {
                        DispatchQueue.main.async {
                            self.uploadSuccess = true
                            self.uploadSuccessText = "프로필 사진 변경 완료"
                        }
                    }
                }
            case .failure:
                break
            }
        }
    }

    func updateNickname(userManager: UserManager) {
        userManager.fetchUserInfo()
        let url = "https://api.mapping.kro.kr/api/v2/member/modify-nickname?nickname=\(newNickname)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(userManager.accessToken)"
        ]
        
        AF.request(url, method: .patch, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                if let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let status = jsonResponse["status"] as? Int, status == 200 {
                        DispatchQueue.main.async {
                            self.uploadSuccess = true
                            self.uploadSuccessText = "프로필 닉네임 변경 완료"
                        }
                    }
                }
            case .failure:
                break
            }
        }
    }
}
