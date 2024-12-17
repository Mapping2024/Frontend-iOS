import SwiftUI

struct CommentView: View {
    @EnvironmentObject var userManager: UserManager
    let memoId: Int
    
    @State private var comments: [Comment] = []
    @State private var isLoading: Bool = true
    @State var update: Bool = false
    
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
                    if userManager.isLoggedIn {
                        Divider()
                        CommentInputView(memoId: memoId, update: $update)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(comments) { comment in
                                VStack(spacing: 8) {
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
                                        } else {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(comment.nickname)
                                                    .font(.headline)
                                                
                                                ForEach(0..<comment.rating, id: \.self) { _ in
                                                    Image(systemName: "star.fill")
                                                        .foregroundColor(.yellow)
                                                    .font(.caption2)                       }
                                                
                                                Spacer()
                                                
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
                                                    HStack {
                                                        Text("👍 \(comment.likeCnt)")
                                                            .scaleEffect(comment.isAnimatingLike == true ? 1.5 : 1.0) // 크기 애니메이션
                                                            .animation(.easeInOut(duration: 0.2), value: comment.isAnimatingLike)
                                                    }
                                                }

                                            }
                                            Text(comment.comment)
                                                .font(.body)
                                            
                                            Text(comment.updatedAt)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                    }
                                    
                                    Divider()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if userManager.isLoggedIn {
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

