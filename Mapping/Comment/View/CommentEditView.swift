import SwiftUI

struct CommentEditView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = CommentEditViewModel()
    
    @Binding var editingComment: Int
    @Binding var updateComment: Bool
    var editingCommentId: Int
    var editingCommentString: String
    var editingRating: Int
    var editingTime: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            TextField("댓글을 입력하세요", text: $viewModel.editingComment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Text("\(editingTime) (수정됨)")
                    .font(.body)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button("취소") {
                    editingComment = 0 // 수정 모드 종료
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .foregroundColor(.gray)
                
                Button("저장") {
                    viewModel.updateComment(id: editingCommentId, userManager: userManager) {
                        editingComment = 0
                        updateComment = true
                    }
                }
                .disabled(viewModel.editingComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(
                    viewModel.editingComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.pastelAqua
                )
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .onAppear {
            viewModel.setup(editingComment: self.editingCommentString, editingRating: self.editingRating)
        }
    }
}

#Preview {
    CommentEditView(editingComment: .constant(0), updateComment: .constant(false),editingCommentId: 2, editingCommentString: "adsfadsf", editingRating: 0, editingTime: "2024-11-22 20:31:11")
        .environmentObject(UserManager())
}


// 별점 수정
//                ForEach(1...5, id: \.self) { star in
//                    Image(systemName: star <= viewModel.editingRating ? "star.fill" : "star")
//                        .resizable()
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(star <= viewModel.editingRating ? .yellow : .gray)
//                        .onTapGesture {
//                            viewModel.editingRating = star
//                        }
//                }
