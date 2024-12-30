import SwiftUI

struct MyMemoEditView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel: MyMemoEditViewModel

    init(memo: MemoDetail) {
        _viewModel = StateObject(wrappedValue: MyMemoEditViewModel(memo: memo))
    }
    
    var body: some View {
        Group {
            Form {
                Section(header: Text("제목")) {
                    TextField("제목을 입력하세요", text: $viewModel.title)
                }
                
                Section(header: Text("내용")) {
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("카테고리")) {
                    Picker("카테고리 선택", selection: $viewModel.category) {
                        Text("기타").tag("기타")
                        Text("흡연장").tag("흡연장")
                        Text("쓰레기통").tag("쓰레기통")
                        Text("공용 화장실").tag("공용 화장실")
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
                                        Button("삭제") {
                                            viewModel.deleteImage(at: index)
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
                            ForEach(viewModel.newImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                            Button("사진 선택") {
                                viewModel.isPickerPresented = true
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("메모 수정하기", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("저장") {
                    viewModel.updateMemo(userManager: userManager)
                }.disabled(viewModel.isSaveDisabled)
            )
            .sheet(isPresented: $viewModel.isPickerPresented) {
                PhotoPicker(selectedImages: $viewModel.newImages, selectionLimit: 5)
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
