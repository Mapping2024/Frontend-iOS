import SwiftUI

struct CommentInputView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var newComment: String = ""
    @State private var rating: Int = 5
    let memoId: Int
    @Binding var update: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            TextField("댓글을 입력하세요", text: $newComment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(star <= rating ? .yellow : .gray)
                        .onTapGesture {
                            rating = star // 선택한 별점으로 설정
                        }
                }
                
                Spacer()
                
                Button(action: addComment) {
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
                        newComment = ""
                        rating = 5
                        update = true
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

#Preview {
    CommentInputView(memoId: 1, update: .constant(false))
}
