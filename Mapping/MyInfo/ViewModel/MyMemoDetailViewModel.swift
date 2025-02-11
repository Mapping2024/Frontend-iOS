import Foundation
import SwiftUI

@MainActor
class MyMemoDetailViewModel: ObservableObject {
    @Published var memoDetail: MemoDetail?
    @Published var isLoading = true
    @Published var isDeleting = false
    
    func fetchMemoDetail(id: Int, token: String) {
        isLoading = true
        let urlString = "https://api.mapping.kro.kr/api/v2/memo/detail?memoId=\(id)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                let decodedResponse = try JSONDecoder().decode(MemoDetailResponse.self, from: data)
                if decodedResponse.success {
                    DispatchQueue.main.async {
                        self.memoDetail = decodedResponse.data
                        self.isLoading = false
                    }
                } else {
                    print("Failed to fetch memo detail: \(decodedResponse.message)")
                }
            } catch {
                print("Error fetching memo detail: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    func deleteMemo(id: Int, token: String, completion: @escaping () -> Void) {
        guard !isDeleting else { return }
        isDeleting = true
        let urlString = "https://api.mapping.kro.kr/api/v2/memo/delete/\(id)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                print("Memo deleted successfully.")
                DispatchQueue.main.async {
                    completion()
                    self.isDeleting = false
                }
            } catch {
                print("Error deleting memo: \(error)")
                DispatchQueue.main.async {
                    self.isDeleting = false
                }
            }
        }
    }
}
