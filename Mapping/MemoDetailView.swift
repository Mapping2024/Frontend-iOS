import SwiftUI

struct MemoDetailView: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var id: Int?
    @Binding var size: PresentationDetent
    @State private var memoDetail: MemoDetail?
    @State private var isLoading = true
    @State private var isRefresh: Bool = false
    // 좋아요 버튼 애니메이션 상태
    @State private var isAnimatingLike: Bool = false
    @State private var isAnimatingHate: Bool = false
    
    @State private var cachedImages: [String: Image] = [:]
    @State private var isPhotoViewerPresented = false
    @State private var selectedImageURL: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let detail = memoDetail {
                HStack {
                    VStack(alignment: .leading){
                        Text(detail.title)
                            .font(.title)
                            .fontWeight(.bold)
                        if let datePart = detail.date.split(separator: ":").first {
                            HStack{
                                Text(datePart).font(.caption2).foregroundStyle(.secondary)
                                if detail.certified {
                                    Image(systemName: "checkmark.seal.fill").font(.caption2).foregroundStyle(.secondary)
                                }
                            }
                        }
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
                                .resizable() // 크기 조정을 가능하게 만듦
                                .aspectRatio(contentMode: .fit) // 비율 유지
                                .frame(width: 40, height: 40) // 원하는 크기로 설정
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable() // 크기 조정을 가능하게 만듦
                            .aspectRatio(contentMode: .fit) // 비율 유지
                            .frame(width: 40, height: 40) // 원하는 크기로 설정
                    }
                    
                    Text("\(detail.nickname)")
                        .font(.subheadline)
                }
                
                Divider()
                
                if size != .small {
                    ScrollView(.vertical, showsIndicators: true){
                        Text(detail.content)
                            .font(.body)
                    }
                } else {
                    Text(detail.content)
                        .font(.body)
                }
                
                if size != .small, let images = detail.images, !images.isEmpty {
                    if images.count > 1 {
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack(alignment: .center, spacing: 10) {
                                ForEach(images, id: \.self) { url in
                                    if let cachedImage = cachedImages[url] {
                                        cachedImage
                                            .resizable()
                                            .frame(width: 200, height: 150)
                                            .cornerRadius(8)
                                            .onTapGesture {
                                                selectedImageURL = nil // 초기화
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        selectedImageURL = url // 새 URL로 설정
                                                    }
                                            }
                                    }
                                }
                            }
                        }
                    } else {
                        HStack(alignment: .center, spacing: 10) {
                            Spacer()
                            ForEach(images, id: \.self) { url in
                                if let cachedImage = cachedImages[url] {
                                    cachedImage
                                        .resizable()
                                        .frame(width: 200, height: 150)
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            selectedImageURL = nil // 초기화
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    selectedImageURL = url // 새 URL로 설정
                                                }
                                        }
                                }
                            }
                            Spacer()
                        }
                    }
                }
                
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isAnimatingLike = true
                        }
                        LikeHateService.likePost(postId: detail.id, accessToken: userManager.accessToken) { result in
                            switch result {
                            case .success:
                                print("Successfully liked the post.")
                                isRefresh = true
                            case .failure(let error):
                                print("Failed to like the post: \(error)")
                            }
                            // 애니메이션 복구
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isAnimatingLike = false
                            }
                        }
                    }) {
                        Text("👍 \(detail.likeCnt)")
                            .scaleEffect(isAnimatingLike ? 1.5 : 1.0) // 크기 애니메이션
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isAnimatingHate = true
                        }
                        LikeHateService.hatePost(postId: detail.id, accessToken: userManager.accessToken) { result in
                            switch result {
                            case .success:
                                print("Successfully hated the post.")
                                isRefresh = true
                            case .failure(let error):
                                print("Failed to hate the post: \(error)")
                            }
                            // 애니메이션 복구
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isAnimatingHate = false
                            }
                        }
                    }) {
                        Text("👎 \(detail.hateCnt)")
                            .scaleEffect(isAnimatingHate ? 1.5 : 1.0) // 크기 애니메이션
                    }
                }
                .font(.subheadline)
                .foregroundStyle(Color.cBlack)
                
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
        .onChange(of: isRefresh){ oldValue, newValue in
            if newValue {
                Task {
                    await fetchMemoDetail()
                }
                isRefresh = false
            }
        }
        .fullScreenCover(isPresented: $isPhotoViewerPresented) {
            if let selectedImageURL {
                PhotoView(imageURL: selectedImageURL, isPresented: $isPhotoViewerPresented)
            }
        }
        .onChange(of: selectedImageURL) { oldValue, newValue in
            if newValue != nil {
                isPhotoViewerPresented = true
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
                
                // 이미지 미리 로드
                if let images = decodedResponse.data.images {
                    for imageUrl in images {
                        loadImage(from: imageUrl)
                    }
                }
            } else {
                print("Failed to fetch memo detail: \(decodedResponse.message)")
            }
        } catch {
            print("Error fetching memo detail: \(error)")
        }
        isLoading = false
    }
    
    private func loadImage(from url: String) {
        guard cachedImages[url] == nil else { return } // 이미 캐싱된 경우 로드하지 않음
        
        Task {
            do {
                guard let imageUrl = URL(string: url) else { return }
                let (data, _) = try await URLSession.shared.data(from: imageUrl)
                if let uiImage = UIImage(data: data) {
                    let image = Image(uiImage: uiImage)
                    cachedImages[url] = image
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
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
    let date: String
    let lat: Double
    let lng: Double
    let category: String
    let likeCnt: Int
    let hateCnt: Int
    let images: [String]?
    let myMemo: Bool
    let myLike: Bool
    let myHate: Bool
    let certified: Bool
    let authorId: Int
    let nickname: String
    let profileImage: String?
}

#Preview {
    MemoDetailView(id: .constant(3), size: .constant(.medium))
        .environmentObject(UserManager())
}
