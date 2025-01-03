import SwiftUI

struct CommentInputView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = CommentInputViewModel()
    let memoId: Int
    @Binding var update: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            TextField("댓글을 입력하세요", text: $viewModel.newComment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= viewModel.rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(star <= viewModel.rating ? .yellow : .gray)
                        .onTapGesture {
                            viewModel.rating = star
                        }
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.addComment(memoId: memoId, userManager: userManager) {
                        update = true
                    }
                }) {
                    Text("등록")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
        }
        .padding(.horizontal)
    }
}

#Preview {
    CommentInputView(memoId: 1, update: .constant(false))
}

