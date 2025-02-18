import SwiftUI
import PhotosUI

enum PinCategory: String, CaseIterable, Identifiable {
    case smokingArea = "흡연장"
    case trashBin = "쓰레기통"
    case publicRestroom = "공용 화장실"
    //    case bungeobbang = "붕어빵"
    case parkingLot = "주차장"
    case other = "기타"
    
    var id: String { self.rawValue }
}

struct AddPinDetailView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    @Binding var backFlag: Bool
    
    @StateObject private var viewModel: AddPinDetailViewModel
    
    init(backFlag: Binding<Bool>, latitude: Double, longitude: Double, currentLocation: CLLocationCoordinate2D) {
        self._backFlag = backFlag
        self._viewModel = StateObject(
            wrappedValue: AddPinDetailViewModel(latitude: latitude, longitude: longitude, currentLocation: currentLocation)
        )
    }
    
    var body: some View {
        Group {
            Form {
                Section(header: Text("제목"), footer: Text("* 제목은 최대 20자까지 입력 가능합니다.").font(.caption)) {
                    TextField("메모 이름", text: $viewModel.pinName)
                        .onChange(of: viewModel.pinName) { newValue, oldValue in
                            if newValue.count > 20 {
                                viewModel.pinName = String(newValue.prefix(20)) // 20자 제한
                            }
                        }
                }
                
                Section(header: Text("내용"), footer: Text("* 부적절하거나 불쾌감을 줄 수 있는 컨텐츠는 제재를 받을 수 있습니다.").font(.caption)) {
                    TextEditor(text: $viewModel.pinDescription)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("카테고리")) {
                    Picker("카테고리 선택", selection: $viewModel.selectedCategory) {
                        ForEach(PinCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("개인 메모")) {
                    Toggle("프라이빗 설정", isOn: $viewModel.secret)
                }
                
                Section(header: Text("사진")) {
                    ForEach(viewModel.selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    }
                    
                    Button("사진 선택") {
                        viewModel.isPresented = true
                    }
                    .confirmationDialog("사진 선택",
                                        isPresented: $viewModel.isPresented,
                                        actions: {
                        Button(action: {
                            viewModel.isPickerPresented = true
                        }) {
                            Text("사진 보관함")
                        }
                        
                        Button(action: {
                            viewModel.isCameraPresented = true
                        }) {
                            Text("카메라")
                        }
                        
                        Button("취소", role: .cancel) {
                        }
                    },
                                        message: {
                        Text("불러올 사진 위치를 선택해주세요.")
                    }
                    )
                }
            }
            .navigationBarTitle(Text("핀 생성하기"), displayMode: .inline)
            .navigationBarItems(
                trailing: Button("생성") {
                    userManager.fetchUserInfo()
                    viewModel.createPin(accessToken: userManager.accessToken)
                }
                    .disabled(viewModel.pinName.trimmingCharacters(in: .whitespaces).isEmpty ||
                              viewModel.pinDescription.trimmingCharacters(in: .whitespaces).isEmpty ||
                              viewModel.isUploading) // 요청 중이면 비활성화
            )
            .sheet(isPresented: $viewModel.isPickerPresented) {
                PhotoPicker(selectedImages: $viewModel.selectedImages, selectionLimit: 5)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .sheet(isPresented: $viewModel.isCameraPresented) {
                CameraPicker(selectedImages: $viewModel.selectedImages)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .alert(isPresented: $viewModel.uploadSuccess) {
                Alert(
                    title: Text("\(viewModel.uploadSuccessText ?? "알림")"),
                    message: nil,
                    dismissButton: .default(Text("확인")) {
                        dismiss()
                        backFlag = true
                    }
                )
            }
        }
    }
}
