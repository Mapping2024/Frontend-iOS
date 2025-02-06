import SwiftUI

struct CommentListView: View {
    @EnvironmentObject var userManager: UserManager
    let memoId: Int
    
    @State private var comments: [Int] = []
    @State private var isLoading: Bool = true
    @State var update: Bool = false
    @State var editingComment: Int = 0
    
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
                    Divider()
                    
                } else {
                    ScrollView {
                        ForEach(comments, id: \.self) { comment in
                            VStack(spacing: 8) {
                                CommentView(editingComment: $editingComment, commentID: comment, update: $update)
                            }
                            Divider()
                                .padding(.horizontal)
                        }
                        
                    }
                }
                
                if userManager.isLoggedIn && editingComment == 0 {
                    CommentInputView(memoId: memoId, update: $update)
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
        guard let url = URL(string: "https://api.mapping.kro.kr/api/v2/comment/ids?memoId=\(memoId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch comments: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(CommentsResponse.self, from: data)
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
