//
//  ChangeMyInfoView.swift
//  Mapping
//
//  Created by 김민정 on 11/7/24.
//
import SwiftUI
import Alamofire
import PhotosUI

struct ChangeMyInfoView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedImage: [UIImage] = []
    @State private var isPickerPresented = false
    @State private var isUploading = false
    @State private var uploadSuccess = false
    @State private var newNickname: String = ""
    @State private var nicknameUpdateSuccess = false

    var body: some View {
        VStack {
            Text("프로필 사진 및 닉네임 변경")
                .font(.title)
                .padding()
            
            // 프로필 사진 영역
            if let selectedImage = selectedImage.first {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    .padding()
            } else {
                ProfileImageView()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    .padding()
            }
            
            Button(action: {
                isPickerPresented = true
            }) {
                Text("사진 선택")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // 프로필 사진 업데이트 버튼
            if selectedImage.first != nil {
                Button(action: {
                    uploadProfileImage()
                }) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Text("프로필 사진 업데이트")
                    }
                }
                .padding()
                .disabled(isUploading)
            }
            
            // 닉네임 변경 입력 필드 및 버튼
            TextField("새 닉네임 입력", text: $newNickname)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                updateNickname()
            }) {
                Text("닉네임 변경")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $isPickerPresented) {
            PhotoPicker(selectedImages: $selectedImage, selectionLimit: 1)
        }
        .alert(isPresented: $uploadSuccess) {
            Alert(
                title: Text("프로필 사진 업데이트 완료"),
                message: Text("프로필 사진이 성공적으로 업데이트되었습니다."),
                dismissButton: .default(Text("확인"))
            )
        }
        .alert(isPresented: $nicknameUpdateSuccess) {
            Alert(
                title: Text("닉네임 변경 완료"),
                message: Text("닉네임이 성공적으로 변경되었습니다."),
                dismissButton: .default(Text("확인"))
            )
        }
    }
    
    func uploadProfileImage() {
        guard let selectedImage = selectedImage.first else { return }
        
        isUploading = true
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
        }, to: url, method: .patch, headers: headers).responseJSON { response in
            isUploading = false
            
            switch response.result {
            case .success(let data):
                if let jsonResponse = data as? [String: Any] {
                    print("응답 JSON: \(jsonResponse)")
                    if let status = jsonResponse["status"] as? Int, status == 200 {
                        uploadSuccess = true
                    } else {
                        print("서버 응답 오류: \(jsonResponse["message"] ?? "알 수 없는 오류")")
                    }
                }
            case .failure(let error):
                print("요청 실패: \(error)")
                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                    print("응답 내용: \(responseString)")
                }
            }
        }
    }
    
    func updateNickname() {
        let url = "https://api.mapping.kro.kr/api/v2/member/modify-nickname?nickname=\(newNickname)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(userManager.accessToken)"
        ]
        
        AF.request(url, method: .patch, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                if let jsonResponse = data as? [String: Any] {
                    print("응답 JSON: \(jsonResponse)")
                    if let status = jsonResponse["status"] as? Int, status == 200 {
                        nicknameUpdateSuccess = true
                    } else {
                        print("서버 응답 오류: \(jsonResponse["message"] ?? "알 수 없는 오류")")
                    }
                }
            case .failure(let error):
                print("요청 실패: \(error)")
                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                    print("응답 내용: \(responseString)")
                }
            }
        }
    }
}

#Preview {
    ChangeMyInfoView()
        .environmentObject(UserManager())
}
