import SwiftUI
import Alamofire

struct MyMemoEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    @State private var title: String
    @State private var content: String
    @State private var category: String
    @State private var deleteImageUrls: [String] = []
    @State private var newImages: [UIImage] = []
    @State private var isPickerPresented = false
    @State private var uploadSuccess = false
    @State private var uploadSuccessText: String? = nil
    
    @State private var isPhotoViewerPresented = false
    @State private var selectedImageURL: String?
    
    var memo: MemoDetail
    
    init(memo: MemoDetail) {
        self.memo = memo
        _title = State(initialValue: memo.title)
        _content = State(initialValue: memo.content)
        _category = State(initialValue: "기타")
    }
    
    var body: some View {
        NavigationStack{
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    // 제목 입력
                    GroupBox {
                        VStack(alignment: .leading) {
                            Text("제목")
                                .font(.headline)
                            TextField("제목을 입력하세요", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                        .padding()
                        
                        // 내용 입력
                        VStack(alignment: .leading) {
                            Text("내용")
                                .font(.headline)
                            TextEditor(text: $content)
                                .frame(minHeight: 100, maxHeight: 250)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                        .padding()
                    }
                    
                    // 카테고리 입력
                    GroupBox {
                        VStack(alignment: .leading) {
                            Text("카테고리")
                                .font(.headline)
                            Picker("카테고리",selection: $category) {
                                Text("기타").tag("기타")
                                Text("흡연장").tag("흡연장")
                                Text("쓰레기통").tag("쓰레기통")
                                Text("공용 화장실").tag("공용 화장실")
                            }
                            .frame(maxWidth: .infinity)
                            .pickerStyle(.menu)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                        .padding()
                    }
                    // 기존 이미지와 삭제 버튼
                    GroupBox {
                        VStack(alignment: .leading) {
                            Text("기존 이미지")
                                .font(.headline)
                            if let images = memo.images, !images.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(images, id: \.self) { url in
                                            VStack {
                                                if let image = URL(string: url){
                                                    AsyncImage(url: image) { phase in
                                                        switch phase {
                                                        case .empty:
                                                            ProgressView() // 로딩 중 표시
                                                        case .success(let image):
                                                            image
                                                                .resizable()
                                                                .frame(width: 150, height: 150)
                                                                .cornerRadius(8)
                                                                .onTapGesture {
                                                                    selectedImageURL = url
                                                                }
                                                        case .failure:
                                                            ProgressView()
                                                        @unknown default:
                                                            EmptyView()
                                                        }
                                                    }
                                                }
                                                Button(action: {
                                                    deleteImageUrls.append(url)
                                                    print(deleteImageUrls)
                                                }) {
                                                    Text("삭제")
                                                        .font(.caption)
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    Text("첨부된 이미지가 없습니다.")
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding()
                        
                        VStack(alignment: .leading) {
                            Text("새로운 이미지 추가")
                                .font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(newImages, id: \.self) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                    }
                                    Button(action: {
                                        isPickerPresented = true
                                    }) {
                                        Image(systemName: "plus.circle")
                                            .font(.largeTitle)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        .padding()
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
                .fullScreenCover(isPresented: $isPhotoViewerPresented) {
                            if let selectedImageURL = selectedImageURL {
                                PhotoView(imageURL: selectedImageURL, isPresented: $isPhotoViewerPresented)
                            }
                        }
                .onChange(of: selectedImageURL) { oldValue, newValue in
                    if newValue != nil {
                        isPhotoViewerPresented = true
                    }
                }
                .sheet(isPresented: $isPickerPresented) {
                    PhotoPicker(selectedImages: $newImages, selectionLimit: 5)
                }
                .padding()
            }
        }
        .navigationBarTitle(Text("메모 수정하기"), displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    updateMemo()
                }) {
                    Text("저장")
                }
            }
        }
    }
    
    func updateMemo() {
        userManager.fetchUserInfo() // 토큰 유효성 확인
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
                    uploadSuccessText = "메모 수정 완료!"
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
