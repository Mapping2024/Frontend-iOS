import SwiftUI
import MapKit
struct MyMemoDetailView: View {
    let id: Int
    @State private var memoDetail: MemoDetail?
    @State private var isLoading = true
    @State private var isDeleting = false
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss // 삭제 후 화면 닫기용
    
    @State private var isPhotoViewerPresented = false
    @State private var selectedImageURL: String?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                if isLoading {
                    ProgressView("Loading...")
                } else if let detail = memoDetail {
                    // 제목과 작성자 정보
                    HStack(spacing: 10) {
                        VStack(alignment: .leading){
                            Text(detail.title)
                                .font(.title)
                                .fontWeight(.bold)
                            if let datePart = detail.date.split(separator: ":").first {
                                Text(datePart)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        
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
                            Text(detail.nickname)
                                .font(.subheadline)
                        }
                    }
                    
                    Divider()
                    
                    // 본문 내용
                    ScrollView(.vertical, showsIndicators: true){
                        VStack(alignment: .leading){
                            Text(detail.content)
                                .font(.body)
                            Map {
                                Marker("",coordinate: CLLocationCoordinate2D(latitude: detail.lat, longitude: detail.lng))
                            }
                            .frame(height: 200)
                            .cornerRadius(10)
                            
                            if let images = detail.images, !images.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(images, id: \.self) { url in
                                            VStack {
                                                if let image = URL(string: url){
                                                    AsyncImage(url: image) { phase in
                                                        switch phase {
                                                        case .empty:
                                                            ProgressView() // 로딩 중 표시
                                                        case .success(let image):
                                                            image
                                                                .resizable()
                                                                .frame(width: 150, height: 150)
                                                                .cornerRadius(8)
                                                                .onTapGesture {
                                                                    selectedImageURL = nil // 초기화
                                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                                        selectedImageURL = url
                                                                    }
                                                                }
                                                        case .failure:
                                                            ProgressView()
                                                        @unknown default:
                                                            EmptyView()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    Text("Failed to load memo details.")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationBarTitle(Text("상세보기"), displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if let memo = memoDetail {
                            NavigationLink(destination: MyMemoEditView(memo: memo)) {
                                Label("수정", systemImage: "pencil")
                            }
                        }
                        Button(action: {deleteMemo()}) {
                            Label("핀 삭제", systemImage: "trash")
                        }
                    } label: {
                        Label("edit", systemImage: "ellipsis.circle")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
            .onAppear(perform: fetchMemoDetail)
            Spacer()
        }
        .fullScreenCover(isPresented: $isPhotoViewerPresented) {
                    if let selectedImageURL = selectedImageURL {
                        PhotoView(imageURL: selectedImageURL, isPresented: $isPhotoViewerPresented)
                    }
                }
        .onChange(of: selectedImageURL) { oldValue, newValue in
            if newValue != nil {
                isPhotoViewerPresented = true
            }
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
