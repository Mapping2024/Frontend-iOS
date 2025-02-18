import Foundation
import SwiftUI
import Alamofire

final class MyMemoEditViewModel: ObservableObject {
    @Published var title: String
    @Published var content: String
    @Published var category: String
    @Published var images: [String]?
    @Published var newImages: [UIImage] = []
    @Published var deleteImageUrls: [String] = []
    @Published var isPickerPresented = false
    @Published var isCameraPresented = false
    @Published var isPresented = false
    @Published var uploadSuccess = false
    @Published var uploadSuccessText: String? = nil
    @Published var isSaving = false // 추가: 저장 중인지 여부
    
    private let memo: MemoDetail
    
    init(memo: MemoDetail) {
        self.memo = memo
        self.title = memo.title
        self.content = memo.content
        self.category = memo.category
        self.images = memo.images
    }
    
    var isSaveDisabled: Bool {
            title.trimmingCharacters(in: .whitespaces).isEmpty ||
            content.trimmingCharacters(in: .whitespaces).isEmpty ||
            isSaving // 저장 중이면 버튼 비활성화
        }
    
    func deleteImage(at index: Int) {
        if let removedImage = images?.remove(at: index) {
            deleteImageUrls.append(removedImage)
        }
    }
    
    func updateMemo(userManager: UserManager) {
        guard !isSaving else { return } // 중복 요청 방지
        isSaving = true // 요청 시작
        
        userManager.fetchUserInfo()
        let url = "https://api.mapping.kro.kr/api/v2/memo/update/\(memo.id)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(userManager.accessToken)",
            "Content-Type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { formData in
            formData.append(self.title.data(using: .utf8)!, withName: "title")
            formData.append(self.content.data(using: .utf8)!, withName: "content")
            formData.append(self.category.data(using: .utf8)!, withName: "category")
            
            for url in self.deleteImageUrls {
                formData.append(url.data(using: .utf8)!, withName: "deleteImageUrls[]")
            }
            
            for image in self.newImages {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    formData.append(imageData, withName: "images", fileName: "\(image)new_image.jpg", mimeType: "image/jpeg")
                }
            }
        }, to: url, method: .put, headers: headers).response { [weak self] response in
            switch response.result {
            case .success(let data):
                if let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = jsonResponse["status"] as? Int, status == 200 {
                    DispatchQueue.main.async {
                        self?.uploadSuccessText = "메모 수정 완료."
                        self?.uploadSuccess = true
                    }
                } else {
                    print("오류 발생: 서버 응답 오류")
                }
            case .failure(let error):
                print("오류 발생: \(error)")
            }
        }
    }
}

