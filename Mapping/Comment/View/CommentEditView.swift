import SwiftUI

struct CommentEditView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = CommentEditViewModel()
    
    @Binding var editingComment: Bool
    @Binding var updateComment: Bool
    var editingCommentId: Int
    var editingCommentString: String
    var editingRating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            TextField("댓글을 입력하세요", text: $viewModel.editingComment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= viewModel.editingRating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(star <= viewModel.editingRating ? .yellow : .gray)
                        .onTapGesture {
                            viewModel.editingRating = star
                        }
                }
                
                Spacer()
                
                HStack {
                    Button("취소") {
                        editingComment = false // 수정 모드 종료
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("저장") {
                        viewModel.updateComment(id: editingCommentId, userManager: userManager) {
                            editingComment = false
                            updateComment = true
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            viewModel.setup(editingComment: self.editingCommentString, editingRating: self.editingRating)
        }
    }
}

//#Preview {
//    CommentEditView(editingCommentId: .constant(1), update: .constant(false), editingCommentString: "adsfadsf", editingRating: 5)
//        .environmentObject(UserManager())
//}
