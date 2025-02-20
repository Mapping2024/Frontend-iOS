import SwiftUI

class CommentInputViewModel: ObservableObject {
    @Published var newComment: String = ""
    @Published var rating: Int = 0
    
    var isCommentValid: Bool {
        return !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func addComment(memoId: Int, userManager: UserManager, completion: @escaping () -> Void) {
        // 필수 입력 확인
        guard isCommentValid else {
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
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
                        self?.newComment = ""
                        self?.rating = 0
                        completion()
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
