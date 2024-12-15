import SwiftUI

struct CommentView: View {
    @EnvironmentObject var userManager: UserManager
    let memoId: Int

    @State private var comments: [Comment] = []
    @State private var newComment: String = ""
    @State private var isLoading: Bool = true

    var body: some View {
        VStack(alignment: .leading) {
            if isLoading {
                ProgressView("Loading comments...")
                    .padding()
            } else {
                if comments.isEmpty {
                    Text("댓글을 달아주세요")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding()
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
                                            Text(comment.nickname)
                                                .font(.headline)

                                            Text(comment.comment)
                                                .font(.body)

                                            Text(comment.updatedAt)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)

                                    Divider()
                                        .background(Color.gray.opacity(0.5))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            if userManager.isLoggedIn {
                HStack {
                    TextField("댓글을 입력하세요", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: addComment) {
                        Text("등록")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .onAppear(perform: fetchComments)
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

    private func addComment() {
        // Implement the logic to post a new comment.
        // This will depend on the API endpoint and requirements.
        print("Adding comment: \(newComment)")
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
}

// Preview
struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(memoId: 1)
            .environmentObject(UserManager())
    }
}

