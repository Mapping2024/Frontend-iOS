import SwiftUI

struct CommentView: View {
    @EnvironmentObject var userManager: UserManager
    let memoId: Int
    
    @State private var comments: [Comment] = []
    @State private var isLoading: Bool = true
    @State var update: Bool = false
    
    @State var editingCommentId: Int = 0 // 수정 중인 댓글의 ID
    @State var updatedCommentText: String = "" // 수정할 댓글 내용
    @State var updatedRating: Int = 1 // 수정할 별점
    
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
                                    if editingCommentId == comment.id {
                                        CommentEditView(editingCommentId: $editingCommentId, editingComment: updatedCommentText, editingRating: updatedRating, update: $update)
                                    } else {
                                        // 일반 댓글 UI
                                        HStack(alignment: .top) {
                                            if let profileImageUrl = comment.profileImageUrl {
                                                AsyncImage(url: URL(string: profileImageUrl)) { image in
                                                    image
                                                        .resizable()
                                                        .frame(width: 40, height: 40)
                                                        .clipShape(Circle())
                                                } placeholder: {
                                                    Image(systemName: "person.circle.fill")
                                                        .resizable()
                                                        .frame(width: 40, height: 40)
                                                }
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Text(comment.nickname)
                                                        .font(.headline)
                                                    
                                                    ForEach(0..<comment.rating, id: \.self) { _ in
                                                        Image(systemName: "star.fill")
                                                            .foregroundColor(.yellow)
                                                            .font(.caption2)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    // 수정 및 삭제 메뉴
                                                    Menu {
                                                        Button("수정") {
                                                            // 수정 모드 진입
                                                            editingCommentId = comment.id
                                                            updatedCommentText = comment.comment
                                                            updatedRating = comment.rating
                                                        }
                                                        Button("삭제") {
                                                            deleteComment(id: comment.id)
                                                        }
                                                    } label: {
                                                        Image(systemName: "ellipsis")
                                                            .foregroundColor(.cBlack)
                                                    }
                                                }
                                                
                                                Text(comment.comment)
                                                    .font(.body)
                                                
                                                HStack{
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
                                                        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
                                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                                comments[index].isAnimatingLike = true
                                                            }
                                                            // 서버로 좋아요 요청
                                                            LikeHateService.likeComment(id: comment.id, accessToken: userManager.accessToken) { result in
                                                                DispatchQueue.main.async {
                                                                    switch result {
                                                                    case .success:
                                                                        print("Successfully liked the post.")
                                                                        fetchComments() // 데이터 새로고침
                                                                    case .failure(let error):
                                                                        print("Failed to like the post: \(error)")
                                                                    }
                                                                    // 애니메이션 복구
                                                                    withAnimation(.easeInOut(duration: 0.2)) {
                                                                        comments[index].isAnimatingLike = false
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }) {
                                                        HStack(alignment: .bottom) {
                                                            Text("👍 \(comment.likeCnt)")
                                                                .scaleEffect(comment.isAnimatingLike == true ? 1.5 : 1.0) // 크기 애니메이션
                                                                .animation(.easeInOut(duration: 0.2), value: comment.isAnimatingLike)
                                                                .font(.caption)
                                                                .foregroundColor(.cBlack)
                                                        }
                                                    }
                                                }
                                            }
                                        }
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
        .onChange(of: update, { oldValue, newValue in // 핀 추가후 지도 업데이트
            if update {
                fetchComments()
                update = false
            }
        })
    }
    
    private func deleteComment(id: Int) {
        let urlString = "https://api.mapping.kro.kr/api/v2/comment/\(id)"
        guard let url = URL(string: urlString) else { return }
        
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
                fetchComments()
            } catch {
                print("Error deleting comment: \(error)")
            }
        }
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


struct CommentResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: [Comment]?
}

struct Comment: Identifiable, Decodable {
    let id: Int
    let comment: String
    let rating: Int
    let likeCnt: Int
    let modify: Bool
    let nickname: String
    let profileImageUrl: String?
    let updatedAt: String
    let myLike: Bool
    
    var isAnimatingLike: Bool? = nil
}

// Preview
struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(memoId: 1)
            .environmentObject(UserManager())
    }
}

