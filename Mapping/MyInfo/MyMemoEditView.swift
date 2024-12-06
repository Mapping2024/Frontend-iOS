import SwiftUI
import Alamofire
//import PhotosUI

struct MyMemoEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    @State private var title: String
    @State private var content: String
    @State private var category: String
    @State private var images: [String]?
    @State private var deleteImageUrls: [String] = []
    @State private var newImages: [UIImage] = []
    @State private var isPickerPresented = false
    @State private var uploadSuccess = false
    @State private var uploadSuccessText: String? = nil
    
    var memo: MemoDetail
    
    init(memo: MemoDetail) {
        self.memo = memo
        _title = State(initialValue: memo.title)
        _content = State(initialValue: memo.content)
        _category = State(initialValue: memo.category)
        _images = State(initialValue: memo.images)
    }
    
    var body: some View {
        Group {
            Form {
                Section(header: Text("제목")) {
                    TextField("제목을 입력하세요", text: $title)
                }
                
                Section(header: Text("내용")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("카테고리")) {
                    Picker("카테고리 선택", selection: $category) {
                        Text("기타").tag("기타")
                        Text("흡연장").tag("흡연장")
                        Text("쓰레기통").tag("쓰레기통")
                        Text("공용 화장실").tag("공용 화장실")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("기존 이미지")) {
                    if let images = images, !images.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(images.enumerated()), id: \.offset) { index, url in
                                    VStack {
                                        AsyncImage(url: URL(string: url)) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(10)
                                            default:
                                                ProgressView()
                                            }
                                        }
                                        Button("삭제") {
                                            self.images?.remove(at: index) // 인덱스를 사용하여 삭제
                                            deleteImageUrls.append(url) // 삭제된 URL 추가
                                        }
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    } else {
                        Text("첨부된 이미지가 없습니다.")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("새로운 이미지 추가")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(newImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                            Button("사진 선택") {
                                isPickerPresented = true
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("메모 수정하기", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("저장") {
                    updateMemo()
                }.disabled(title.isEmpty || content.isEmpty)
            )
            .sheet(isPresented: $isPickerPresented) {
                PhotoPicker(selectedImages: $newImages, selectionLimit: 5)
            }
        }
        .alert(isPresented: $uploadSuccess) {
            Alert(
                title: Text(uploadSuccessText ?? ""),
                dismissButton: .default(Text("확인")) {
                    dismiss()
                }
            )
        }
    }
    
    func updateMemo() {
        userManager.fetchUserInfo()
        let url = "https://api.mapping.kro.kr/api/v2/memo/update/\(memo.id)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(userManager.accessToken)",
            "Content-Type": "multipart/form-data"
        ]
        
        AF.upload(multipartFormData: { formData in
            formData.append(title.data(using: .utf8)!, withName: "title")
            formData.append(content.data(using: .utf8)!, withName: "content")
            formData.append(category.data(using: .utf8)!, withName: "category")
            
            for url in deleteImageUrls {
                formData.append(url.data(using: .utf8)!, withName: "deleteImageUrls[]")
            }
            
            for image in newImages {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    formData.append(imageData, withName: "images", fileName: "new_image.jpg", mimeType: "image/jpeg")
                }
            }
        }, to: url, method: .put, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                if let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = jsonResponse["status"] as? Int, status == 200 {
                    uploadSuccessText = "메모 수정 완료."
                    uploadSuccess = true
                } else {
                    print("오류 발생: 서버 응답 오류")
                }
            case .failure(let error):
                print("오류 발생: \(error)")
            }
        }
    }
}
