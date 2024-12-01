import SwiftUI

struct MyMemoDetailView: View {
    let id: Int
    @State private var memoDetail: MemoDetail?
    @State private var isLoading = true
    @State private var isDeleting = false
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss // 삭제 후 화면 닫기용
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                if isLoading {
                    ProgressView("Loading...")
                } else if let detail = memoDetail {
                    // 제목과 작성자 정보
                    VStack(alignment: .leading, spacing: 10) {
                        Text(detail.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            AsyncImage(url: URL(string: detail.profileImage ?? "")) { image in
                                image
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(detail.nickname)
                                    .font(.headline)
                                if let datePart = detail.date.split(separator: ":").first {
                                    Text(datePart)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // 본문 내용
                    Text(detail.content)
                        .font(.body)
                    
                    Divider()
                    
                    // 지도 표시 (예: 사각형 플레이스홀더)
                    ZStack {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(height: 200)
                            .cornerRadius(10)
                        Text("지도 정보 표시 예정")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    
                    // 삭제 버튼
                    Button(action: deleteMemo) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Memo")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .padding(.top)
                    .disabled(isDeleting)
                } else {
                    Text("Failed to load memo details.")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationTitle("Memo Detail")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: fetchMemoDetail)
            Spacer()
        }
    }
    
    private func fetchMemoDetail() {
        isLoading = true
        let urlString = "https://api.mapping.kro.kr/api/v2/memo/detail?memoId=\(id)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(userManager.accessToken)", forHTTPHeaderField: "Authorization")
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                let decodedResponse = try JSONDecoder().decode(MemoDetailResponse.self, from: data)
                if decodedResponse.success {
                    memoDetail = decodedResponse.data
                } else {
                    print("Failed to fetch memo detail: \(decodedResponse.message)")
                }
            } catch {
                print("Error fetching memo detail: \(error)")
            }
            isLoading = false
        }
    }
    
    private func deleteMemo() {
        guard !isDeleting else { return }
        isDeleting = true
        let urlString = "https://api.mapping.kro.kr/api/v2/memo/delete/\(id)"
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
                print("Memo deleted successfully.")
                dismiss() // 삭제 후 화면 닫기
            } catch {
                print("Error deleting memo: \(error)")
            }
            isDeleting = false
        }
    }
}

#Preview {
    MyMemoDetailView(id: 1)
        .environmentObject(UserManager())
}
