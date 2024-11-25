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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userManager: UserManager
    @State private var selectedImage: [UIImage] = []
    @State private var isPickerPresented = false
    @State private var uploadSuccessText: String? = nil
    @State private var uploadSuccess = false
    @State private var newNickname: String = ""
    
    var body: some View {
        
        VStack {
            Text("프로필 변경")
                .font(.title)
                .padding()
            Divider()
            
            // 프로필 사진 영역
            GroupBox{
                HStack{
                    Group {
                        if let selectedImage = selectedImage.first {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                        } else {
                            ProfileImageView()
                                .frame(width: 150, height: 150)
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                        }
                    }
                    Spacer()
                    Button(action: {
                        isPickerPresented = true
                    }) {
                        Text("사진 선택")
                            .padding(7)
                            .background(Color.blue) // 원하는 백그라운드 색상 지정
                            .cornerRadius(10)// 백그라운드에 모서리 곡선 적용
                            .foregroundStyle(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                    .padding(.leading)
                }
                .padding()
                
                // 프로필 사진 업데이트 버튼
                if selectedImage.first != nil {
                    Button(action: {
                        uploadProfileImage()
                    }) {
                        Text("프로필 사진 업데이트")
                            .padding(7)
                            .background(Color("cWhite")) // 원하는 백그라운드 색상 지정
                            .cornerRadius(10) // 백그라운드에 모서리 곡선 적용
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                }
            }
            .padding()
            
            // 닉네임 변경 입력 필드 및 버튼
            GroupBox{
                HStack{
                    if let nickname = userManager.userInfo?.nickname {
                        TextField("\(nickname)", text: $newNickname)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 2) // 테두리 색상과 두께
                            )
                    } else {
                        TextField("", text: $newNickname)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 2) // 테두리 색상과 두께
                            )
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        updateNickname()
                    }) {
                        Text("닉네임 변경")
                            .padding(7)
                            .background(Color.green) // 원하는 백그라운드 색상 지정
                            .cornerRadius(10) // 백그라운드에 모서리 곡선 적용
                            .foregroundStyle(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                    }.padding(.leading)
                }
                .padding(.vertical)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $isPickerPresented) {
            PhotoPicker(selectedImages: $selectedImage, selectionLimit: 1)
        }
        .alert(isPresented: $uploadSuccess) {
            Alert(
                title: Text("\(uploadSuccessText!)"),
                message: nil,
                dismissButton: .default(Text("확인")){
                    userManager.fetchUserInfo()
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
        }
        Spacer()
    }
    
    func uploadProfileImage() {
        userManager.fetchUserInfo() // 토큰 유효성 확인 및 재발급
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
                    print("응답 JSON: \(jsonResponse)")
                    if let status = jsonResponse["status"] as? Int, status == 200 {
                        uploadSuccess = true
                        uploadSuccessText = "프로필 사진 변경 완료"
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
        userManager.fetchUserInfo() // 토큰 유효성 확인 및 재발급
        let url = "https://api.mapping.kro.kr/api/v2/member/modify-nickname?nickname=\(newNickname)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(userManager.accessToken)"
        ]
        
        AF.request(url, method: .patch, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                if let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("응답 JSON: \(jsonResponse)")
                    if let status = jsonResponse["status"] as? Int, status == 200 {
                        uploadSuccess = true
                        uploadSuccessText = "프로필 닉네임 변경 완료"
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
