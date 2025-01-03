import SwiftUI

class CommentEditViewModel: ObservableObject {
    @Published var editingComment: String = ""
    @Published var editingRating: Int = 5
    
    func setup(editingComment: String, editingRating: Int) {
        self.editingComment = editingComment
        self.editingRating = editingRating
    }
    
    func updateComment(id: Int, userManager: UserManager, completion: @escaping () -> Void) {
        let urlString = "https://api.mapping.kro.kr/api/v2/comment/\(id)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("Bearer \(userManager.accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "comment": editingComment,
            "rating": editingRating
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                print("Comment updated successfully.")
                completion()
            } catch {
                print("Error updating comment: \(error)")
            }
        }
    }
}
