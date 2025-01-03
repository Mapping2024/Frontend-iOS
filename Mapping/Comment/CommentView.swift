import SwiftUI

struct CommentView: View {
    @EnvironmentObject var userManager: UserManager

    @State var comment: Comment
    @Binding var editingCommentId: Int
    @Binding var update: Bool
    
    // 애니메이션 상태 변수 추가
    @State private var isShaking: Bool = false

    var body: some View {
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
                    
                    if comment.nickname == userManager.userInfo?.nickname {
                        Menu {
                            Button("수정") {
                                // 수정 모드 진입
                                editingCommentId = comment.id
                            }
                            Button("삭제") {
                                deleteComment(id: comment.id)
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.cBlack)
                        }
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
                        // 흔들림 애니메이션 트리거
                        isShaking = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isShaking = false
                        }

                        LikeHateService.likeComment(id: comment.id, accessToken: userManager.accessToken) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success:
                                    print("Successfully liked the post.")
                                    update = true
                                    
                                case .failure(let error):
                                    print("Failed to like the post: \(error)")
                                }
                            }
                        }
                    }) {
                        HStack(alignment: .bottom) {
                            Text("👍 \(comment.likeCnt)")
                                .font(.caption)
                                .foregroundColor(.cBlack)
                        }
                        .rotationEffect(isShaking ? Angle(degrees: -15) : Angle(degrees: 0))
                        .animation(isShaking ? Animation.easeInOut(duration: 0.1).repeatCount(5, autoreverses: true) : .default, value: isShaking)
                    }
                }
            }
        }
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
                update = true
            } catch {
                print("Error deleting comment: \(error)")
            }
        }
    }
}
