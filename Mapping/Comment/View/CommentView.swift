import SwiftUI

struct CommentView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var comment: Comment = Comment()
    @State private var updateComment: Bool = false
    
    @Binding var editingComment: Int
    @State var commentID: Int
    @Binding var update: Bool
    
    var body: some View {
        Group{
            if editingComment != commentID {
                HStack(alignment: .top) {
                    ProfileImageView(imageURL: comment.profileImageUrl)
                        .frame(width: 25, height: 25)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(comment.nickname)
                                .font(.headline)
                            
                            HStack(spacing: 1) {
                                ForEach(0..<comment.rating, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption2)
                                }
                            }
                            
                            Spacer()
                            
                            if comment.nickname == userManager.userInfo?.nickname { // 내가 작성한 댓글
                                Menu {
                                    Button("수정") {
                                        editingComment = commentID
                                    }
                                    Button("삭제") {
                                        deleteComment(id: comment.id)
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                        .padding(6)
                                }
                            } else if (userManager.isLoggedIn && comment.nickname != userManager.userInfo?.nickname) {
                                UserActionMenuView(accesstoken: userManager.accessToken, id: comment.id, userId: comment.writerId, nickname: comment.nickname, type: "댓글")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Text(comment.comment)
                            .font(.body)
                        
                        HStack {
                            Text(comment.updatedAt)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            if comment.modify == true {
                                Text("(수정됨)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            // 좋아요 버튼
                            Button(action: {
                                LikeHateService.likeComment(id: comment.id, accessToken: userManager.accessToken) { result in
                                    switch result {
                                    case .success:
                                        print("Successfully liked the post.")
                                        updateComment = true
                                    case .failure(let error):
                                        print("Failed to like the post: \(error)")
                                    }
                                }
                            }) {
                                Image(systemName: comment.myLike ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .foregroundStyle(.yellow)
                                Text("\(comment.likeCnt)")
                                    .font(.caption)
                                    .foregroundColor(.cBlack)
                                
                            }
                        }
                    }
                }
                .onAppear(perform: fetchComment)
            } else if (commentID == editingComment){
                CommentEditView(editingComment: $editingComment, updateComment: $updateComment, editingCommentId: commentID, editingCommentString: comment.comment, editingRating: comment.rating, editingTime: comment.updatedAt)
            }
        }
        .onChange(of: updateComment, { oldValue, newValue in
            if updateComment {
                fetchComment()
                updateComment = false
            }
        })
    }
    
    private func fetchComment() {
        guard let url = URL(string: "https://api.mapping.kro.kr/api/v2/comment/\(commentID)") else { return }
        
        var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("*/*", forHTTPHeaderField: "accept")
            request.addValue("Bearer \(userManager.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch comments: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(CommentResponse.self, from: data)
                if decodedResponse.success, let fetchedComment = decodedResponse.data {
                    DispatchQueue.main.async {
                        self.comment = fetchedComment
                    }
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    
    private func deleteComment(id: Int) {
        
        let urlString = "https://api.mapping.kro.kr/api/v2/comment/\(id)"
        guard let url = URL(string: urlString) else { return }
        print(userManager.accessToken)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(userManager.accessToken)", forHTTPHeaderField: "Authorization")
        
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                print("Comment deleted successfully.")
                update = true
            } catch {
                print("Error deleting comment: \(error)")
            }
        }
    }
}
