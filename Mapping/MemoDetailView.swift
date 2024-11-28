import SwiftUI

struct MemoDetailView: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var id: Int?
    @Binding var size: PresentationDetent
    @State private var memoDetail: MemoDetail?
    @State private var isLoading = true
    
    var body: some View {
        Spacer().frame(minHeight: 15, maxHeight: 15)

        VStack(alignment: .leading) {
            if let detail = memoDetail {
                HStack {
                    VStack(alignment: .leading){
                        Text(detail.title)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("날짜").font(.caption2)
                    }
                    Spacer()
                    if let profileImageUrl = detail.profileImage {
                        AsyncImage(url: URL(string: profileImageUrl)) { image in
                            image
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                    }
                    
                    Text("\(detail.nickname)님")
                        .font(.headline)
                }
                
                Divider()
                
                Text(detail.content)
                    .font(.body)
                
                if let images = detail.images, !images.isEmpty {
                    Group{
                        if images.count == 1 {
                            AsyncImage(url: URL(string: images[0])) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(8)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack(spacing: 10) {
                                    ForEach(images, id: \.self) { imageUrl in
                                        AsyncImage(url: URL(string: imageUrl)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .frame(width: 200, height: 150)
                                                    .cornerRadius(8)
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .foregroundColor(.gray)
                                            @unknown default:
                                                EmptyView()
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: size == .small ? 0 : nil, height: size == .small ? 0 : nil)
                }
                
                HStack {
                    Text("👍 \(detail.likeCnt)")
                    Text("👎 \(detail.hateCnt)")
                }
                .font(.caption)
                
                Spacer()
            } else if isLoading {
                ProgressView("Loading...")
            } else {
                Text("Failed to load data.")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
        .onAppear {
            Task {
                await fetchMemoDetail()
            }
        }.onChange(of: id) { oldId, newId in
            id = newId
            Task {
                await fetchMemoDetail()
            }
        }
    }
    
    private func fetchMemoDetail() async {
        guard let id = id else { return }
        let urlString = "https://api.mapping.kro.kr/api/v2/memo/detail?memoId=\(id)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(userManager.accessToken)", forHTTPHeaderField: "Authorization")
        
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

// 응답 전체 구조체
struct MemoDetailResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: MemoDetail
}

struct MemoDetail: Decodable {
    let id: Int
    let title: String
    let content: String
    let likeCnt: Int
    let hateCnt: Int
    let images: [String]?
    let myMemo: Bool
    let authorId: Int
    let nickname: String
    let profileImage: String?
}

#Preview {
    MemoDetailView(id: .constant(2), size: .constant(.medium))
        .environmentObject(UserManager())
}
