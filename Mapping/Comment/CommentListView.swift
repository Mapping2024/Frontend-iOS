import SwiftUI

struct CommentListView: View {
    @EnvironmentObject var userManager: UserManager
    let memoId: Int
    
    @State private var comments: [Comment] = []
    @State private var isLoading: Bool = true
    @State var update: Bool = false
    
    @State var editingCommentId: Int = 0 // 수정 중인 댓글의 ID
    
    var body: some View {
        VStack(alignment: .leading) {
            if isLoading {
                ProgressView("Loading comments...")
                    .padding()
            } else {
                if comments.isEmpty {
                    Text("댓글이 없습니다.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding()
                    if userManager.isLoggedIn && editingCommentId == 0 {
                        Divider()
                        CommentInputView(memoId: memoId, update: $update)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(comments) { comment in
                                VStack(spacing: 8) {
                                    if editingCommentId == comment.id { // 수정시 해당 위치에서 수정 뷰 출력
                                        CommentEditView(
                                            editingCommentId: $editingCommentId,
                                            update: $update,
                                            editingCommentString: comment.comment,
                                            editingRating: comment.rating
                                        )
                                    } else {
                                        // 일반 댓글 UI
                                        CommentView(comment: comment, editingCommentId: $editingCommentId, update: $update)
                                    }
                                    
                                    Divider()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if userManager.isLoggedIn && editingCommentId == 0 {
                            CommentInputView(memoId: memoId, update: $update)
                        }
                    }
                }
            }
        }
        .onAppear(perform: fetchComments)
        .onChange(of: update, { oldValue, newValue in
            if update {
                fetchComments()
                update = false
            }
        })
    }
    
    private func fetchComments() {
        guard let url = URL(string: "https://api.mapping.kro.kr/api/v2/comment?memoId=\(memoId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch comments: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(CommentResponse.self, from: data)
                if decodedResponse.success, let fetchedComments = decodedResponse.data {
                    DispatchQueue.main.async {
                        self.comments = fetchedComments
                        self.isLoading = false
                    }
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
}

#Preview {
    CommentListView(memoId: 1)
        .environmentObject(UserManager())
}
