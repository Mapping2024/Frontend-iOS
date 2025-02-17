import SwiftUI
import MapKit

struct MemoListDetailView: View {
    @EnvironmentObject var userManager: UserManager
    var id: Int?
    @State private var memoDetail: MemoDetail?
    @State private var isLoading = true
    @State private var isRefresh: Bool = false //좋아요 싫어요 관여
    // 좋아요 버튼 애니메이션 상태
    @State private var isAnimatingLike: Bool = false
    @State private var isAnimatingHate: Bool = false
    
    @State private var isPhotoViewerPresented = false
    @State private var selectedImageURL: String?
    
    @State private var position: MapCameraPosition = .automatic
    
    @State var editingComment: Int = 0
    @State var update: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if let detail = memoDetail {
                HStack(spacing: 10) {
                    VStack(alignment: .leading) {
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
                    
                    HStack {
                        ProfileImageView(imageURL: detail.profileImage)
                            .frame(width: 40, height: 40)
                        Text(detail.nickname)
                            .font(.subheadline)
                    }
                }
                
                Divider()
                
                ScrollView {
                    LazyVStack(alignment: .leading){
                        Text(detail.content)
                            .font(.body)
                        
                        if let images = detail.images, !images.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(images, id: \.self) { urlString in
                                        if let url = URL(string: urlString) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                case .success(let image):
                                                    image.resizable()
                                                        .scaledToFill()
                                                        .onTapGesture {
                                                            selectedImageURL = nil
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                                selectedImageURL = urlString
                                                            }
                                                        }
                                                case .failure:
                                                    Image(systemName: "photo")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(.gray)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .frame(width: 150, height: 150)
                                            .clipped()
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding(.top)
                            }
                        }
                        Map(position: $position) {
                            Marker("", coordinate: CLLocationCoordinate2D(latitude: detail.lat, longitude: detail.lng))
                        }
                        .frame(height: 300)
                        .cornerRadius(10)
                        
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isAnimatingLike = true
                                }
                                LikeHateService.likePost(id: detail.id, accessToken: userManager.accessToken) { result in
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
                                LikeHateService.hatePost(id: detail.id, accessToken: userManager.accessToken) { result in
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
                            Spacer()
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.cBlack)
                        .padding(.top)
                        
                        Group{
                            Divider()
                            CommentListView(memoId: detail.id, editingComment: $editingComment, update: $update)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                
                if userManager.isLoggedIn && editingComment == 0 {
                    CommentInputView(memoId: detail.id, update: $update)
                }
            } else if isLoading {
                ProgressView("Loading...")
            } else {
                Text("Failed to load data.")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
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
        } // 사진 뷰어
        .onChange(of: selectedImageURL) { oldValue, newValue in
            if newValue != nil {
                isPhotoViewerPresented = true
            }
        }
    }
    
    private func fetchMemoDetail() async {
        userManager.fetchUserInfo()
        
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
                if let detail = memoDetail {
                    position = .region(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: detail.lat, longitude: detail.lng),
                            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001) // 원하는 줌 레벨 설정
                        )
                    )
                }
            } else {
                print("Failed to fetch memo detail: \(decodedResponse.message)")
            }
        } catch {
            print("Error fetching memo detail: \(error)")
        }
        isLoading = false
    }
}

