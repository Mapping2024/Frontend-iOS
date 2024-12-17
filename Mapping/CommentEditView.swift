import SwiftUI

struct CommentEditView: View {
    @EnvironmentObject var userManager: UserManager
    
    @Binding var editingCommentId: Int
    @State var editingComment: String
    @State var editingRating: Int
    @Binding var update: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            TextField("댓글을 입력하세요", text: $editingComment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= editingRating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(star <= editingRating ? .yellow : .gray)
                        .onTapGesture {
                            editingRating = star // 선택한 별점으로 설정
                        }
                }
                
                Spacer()
                
                HStack {
                    Button("취소") {
                        editingCommentId = 0 // 수정 모드 종료
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("저장") {
                        updateComment(id: editingCommentId)
                    }
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
    
    private func updateComment(id: Int) {
        let urlString = "https://api.mapping.kro.kr/api/v2/comment/\(id)"
        guard let url = URL(string: urlString) else { return }
        
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
                editingCommentId = 0
                update = true
            } catch {
                print("Error updating comment: \(error)")
            }
        }
    }
    
}

#Preview {
    CommentEditView(editingCommentId: .constant(1), editingComment: .init("DFasf"), editingRating: 2, update: .constant(false)).environmentObject(UserManager())
}
