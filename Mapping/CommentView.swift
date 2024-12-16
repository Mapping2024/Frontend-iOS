import SwiftUI

struct CommentView: View {
    @EnvironmentObject var userManager: UserManager
    let memoId: Int
    
    @State private var comments: [Comment] = []
    @State private var newComment: String = ""
    @State private var rating: Int = 5 // 기본 별점 값
    @State private var isLoading: Bool = true
    
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
                        VStack(alignment: .leading, spacing: 8) {
                            HStack{
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
                            
                            HStack {
                                Text("별점 설정:")
                                Picker("별점", selection: $rating) {
                                    ForEach(1...5, id: \.self) { star in
                                        HStack {
                                            Text("\(star)점")
                                        }.tag(star)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                        .padding(.horizontal)
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
                            VStack(alignment: .leading, spacing: 8) {
                                HStack{
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
                                HStack {
                                    Text("별점 설정:")
                                    Picker("별점", selection: $rating) {
                                        ForEach(1...5, id: \.self) { star in
                                            HStack {
                                                Text("\(star)점")
                                            }.tag(star)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                
                            }
                            .padding(.horizontal)
                        }
                    }
                }
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
        // 필수 입력 확인
        guard !newComment.isEmpty else {
            print("댓글 내용이 비어 있습니다.")
            return
        }
        
        // URL에 쿼리 파라미터 추가
        let queryComment = newComment.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.mapping.kro.kr/api/v2/comment/new?comment=\(queryComment)&memoId=\(memoId)&rating=\(rating)"
        
        guard let url = URL(string: urlString) else {
            print("잘못된 URL입니다.")
            return
        }
        
        // URL Request 설정
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(userManager.accessToken)", forHTTPHeaderField: "Authorization")

        // URLSession으로 요청 전송
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to post comment: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // 서버 응답 처리
            do {
                let decodedResponse = try JSONDecoder().decode(CommentResponse.self, from: data)
                DispatchQueue.main.async {
                    if decodedResponse.success {
                        print("댓글이 성공적으로 추가되었습니다.")
                        fetchComments()
                        newComment = ""
                        rating = 5
                    } else {
                        print("댓글 추가 실패: \(decodedResponse.message)")
                    }
                }
            } catch {
                print("Failed to decode response: \(error)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Server Response: \(responseString)")
                }
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
}

// Preview
struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(memoId: 1)
            .environmentObject(UserManager())
    }
}

