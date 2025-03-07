import SwiftUI

struct MyMemoEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel: MyMemoEditViewModel
    
    @FocusState private var isTextFieldFocused: Bool

    init(memo: MemoDetail) {
        _viewModel = StateObject(wrappedValue: MyMemoEditViewModel(memo: memo))
    }
    
    var body: some View {
        Group {
            Form {
                Section(header: Text("제목"), footer: Text("* 제목은 최대 20자까지 입력 가능합니다.").font(.caption)) {
                    TextField("제목을 입력하세요", text: $viewModel.title)
                        .focused($isTextFieldFocused)
                        .onChange(of: viewModel.title) { newValue, oldValue in
                            if newValue.count > 20 {
                                viewModel.title = String(newValue.prefix(20)) // 20자 제한
                            }
                        }
                }
                
                Section(header: Text("내용"), footer: Text("* 부적절하거나 불쾌감을 줄 수 있는 컨텐츠는 제재를 받을 수 있습니다.").font(.caption)) {
                    TextEditor(text: $viewModel.content)
                        .focused($isTextFieldFocused)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("카테고리")) {
                    Picker("카테고리 선택", selection: $viewModel.category) {
                        Text("기타").tag("기타")
                        Text("흡연장").tag("흡연장")
                        Text("쓰레기통").tag("쓰레기통")
                        Text("공용 화장실").tag("공용 화장실")
                        Text("주차장").tag("주차장")
//                        Text("붕어빵").tag("붕어빵")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("기존 이미지")) {
                    if let images = viewModel.images, !images.isEmpty {
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
                                        Image(systemName: "trash.fill")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .highPriorityGesture(
                                            TapGesture().onEnded {
                                                viewModel.deleteImage(at: index)
                                                print("delete image")
                                            }
                                        )
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
                            ForEach(viewModel.newImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                            
                            Menu {
                                Button("사진 보관함") {
                                    viewModel.isPickerPresented = true
                                }
                                Button("카메라") {
                                    viewModel.isCameraPresented = true
                                }
                            } label: {
                                Text("사진 선택")
                            }
                            
//                            Text("사진 선택")
//                                .foregroundStyle(Color.pastelAqua)
//                                .onTapGesture {
//                                    viewModel.isPresented = true
//                                }
//                            .confirmationDialog("사진 선택",
//                                                isPresented: $viewModel.isPresented,
//                                                actions: {
//                                Button(action: {
//                                    viewModel.isPickerPresented = true
//                                }) {
//                                    Text("사진 보관함")
//                                }
//                                
//                                Button(action: {
//                                    viewModel.isCameraPresented = true
//                                }) {
//                                    Text("카메라")
//                                }
//                                
//                                Button("취소", role: .cancel) {
//                                    }
//                            },
//                                                message: {
//                                Text("불러올 사진 위치를 선택해주세요.")
//                            }
//                            )
                        }
                    }
                }
            }
            .onTapGesture {
                isTextFieldFocused = false
            }
            .navigationBarTitle("메모 수정하기", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("저장") {
                    userManager.fetchUserInfo() // 토큰 유효성 확인 및 재발급
                    viewModel.updateMemo(userManager: userManager)
                }
                    .disabled(viewModel.isSaveDisabled)
            )
            .sheet(isPresented: $viewModel.isPickerPresented) {
                PhotoPicker(selectedImages: $viewModel.newImages, selectionLimit: 5)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .sheet(isPresented: $viewModel.isCameraPresented) {
                CameraPicker(selectedImages: $viewModel.newImages)
                    .edgesIgnoringSafeArea(.bottom)
            }
        }
        .alert(isPresented: $viewModel.uploadSuccess) {
            Alert(
                title: Text(viewModel.uploadSuccessText ?? ""),
                dismissButton: .default(Text("확인")) {
                    dismiss()
                }
            )
        }
    }
}
