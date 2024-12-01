import SwiftUI
import Alamofire
import PhotosUI

enum PinCategory: String, CaseIterable, Identifiable {
    case smokingArea = "흡연장"
    case trashBin = "쓰레기통"
    case publicRestroom = "공용 화장실"
    case other = "기타"
    
    var id: String { self.rawValue }
}

struct AddPinDetailView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    @Binding var backFlag: Bool
    @State private var pinName: String = ""
    @State private var pinDescription: String = ""
    @State private var selectedCategory: PinCategory = .other
    @State private var selectedImages: [UIImage] = []
    @State private var isPickerPresented = false
    @State private var uploadSuccessText: String? = nil
    @State private var uploadSuccess = false
    
    var latitude: Double
    var longitude: Double
    
    var body: some View {
        Group{
            Form {
                Section(header: Text("제목")) {
                    TextField("핀 이름", text: $pinName)
                }
                
                Section(header: Text("내용")) {
                    TextEditor( text: $pinDescription)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("카테고리")) {
                    Picker("카테고리 선택", selection: $selectedCategory) {
                        ForEach(PinCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("사진")) {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    }
                    
                    Button("사진 선택") {
                        isPickerPresented = true
                    }
                }
            }
            .navigationBarTitle(Text("핀 생성하기"), displayMode: .inline)
            .navigationBarItems(
                trailing: Button("생성") {
                    createPin()
                }.disabled(pinName.isEmpty || pinDescription.isEmpty)
            )
            .sheet(isPresented: $isPickerPresented) {
                PhotoPicker(selectedImages: $selectedImages, selectionLimit: 5)
            }
        }
        .alert(isPresented: $uploadSuccess) {
            Alert(
                title: Text("\(uploadSuccessText!)"),
                message: nil,
                dismissButton: .default(Text("확인")){
                    dismiss()
                    backFlag = true
                }
            )
            
        }
    }
    
    func createPin() {
        userManager.fetchUserInfo() // 토큰 유효성 확인 및 재발급
        let url = "https://api.mapping.kro.kr/api/v2/memo/new"
        
        let parameters: [String: String] = [
            "title": pinName,
            "content": pinDescription,
            "lat": "\(latitude)",
            "lng": "\(longitude)",
            "category": selectedCategory.rawValue
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(userManager.accessToken)",
            "Content-Type": "multipart/form-data"
        ]
        
        let query = parameters.map { "\($0)=\($1)" }.joined(separator: "&")
        let fullURL = "\(url)?\(query)"
        
        AF.upload(multipartFormData: { multipartFormData in
            // 이미지 추가 (선택된 경우)
            for (index, image) in selectedImages.enumerated() {
                if let compressedImageData = image.jpegData(compressionQuality: 0.5) {  // 압축 품질 조절 (0.5)
                    multipartFormData.append(compressedImageData, withName: "images", fileName: "image\(index).jpg", mimeType: "image/jpeg")
                }
            }
            
        }, to: fullURL, headers: headers).response { response in
            switch response.result {
            case .success:
                uploadSuccess = true
                uploadSuccessText = "핀 생성 완료"
                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                    print("요청 성공: \(responseString)")
                } else {
                    print("요청 성공: 데이터 없음")
                }
                
            case .failure(let error):
                uploadSuccess = true
                uploadSuccessText = "핀 생성 오류 다시 한번 시도해 주세요"
                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                    print("요청 실패: \(error)\n응답 내용: \(responseString)")
                } else {
                    print("요청 실패: \(error)")
                }
            }
        }
    }
}

#Preview {
    AddPinDetailView(backFlag: .constant(false), latitude: 37.7749, longitude: -122.4194) // 예시 위도와 경도 값
        .environmentObject(UserManager())
}
