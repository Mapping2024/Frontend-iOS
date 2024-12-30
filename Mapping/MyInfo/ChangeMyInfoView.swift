import SwiftUI
import PhotosUI

struct ChangeMyInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = ChangeMyInfoViewModel()
    
    var body: some View {
        VStack {
            Text("프로필 변경")
                .font(.title)
                .padding()
            Divider()
            
            // 프로필 사진 영역
            GroupBox {
                HStack {
                    Group {
                        if let selectedImage = viewModel.selectedImage.first {
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
                        viewModel.isPickerPresented = true
                    }) {
                        Text("사진 선택")
                            .padding(7)
                            .background(Color.blue)
                            .cornerRadius(10)
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
                if viewModel.selectedImage.first != nil {
                    Button(action: {
                        viewModel.uploadProfileImage(userManager: userManager)
                    }) {
                        Text("프로필 사진 업데이트")
                            .padding(7)
                            .background(Color("cWhite"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                }
            }
            .padding()
            
            // 닉네임 변경 입력 필드 및 버튼
            GroupBox {
                HStack {
                    TextField(userManager.userInfo?.nickname ?? "", text: $viewModel.newNickname)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.updateNickname(userManager: userManager)
                    }) {
                        Text("닉네임 변경")
                            .padding(7)
                            .background(Color.green)
                            .cornerRadius(10)
                            .foregroundStyle(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                    }
                    .padding(.leading)
                }
                .padding(.vertical)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $viewModel.isPickerPresented) {
            PhotoPicker(selectedImages: $viewModel.selectedImage, selectionLimit: 1)
        }
        .alert(isPresented: $viewModel.uploadSuccess) {
            Alert(
                title: Text(viewModel.uploadSuccessText ?? ""),
                message: nil,
                dismissButton: .default(Text("확인")) {
                    userManager.fetchUserInfo()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        Spacer()
    }
}

