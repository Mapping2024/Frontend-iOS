import SwiftUI
import MapKit

struct MyMemoDetailView: View {
    let id: Int
    @StateObject private var viewModel = MyMemoDetailViewModel()
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss // 삭제 후 화면 닫기용
    
    @State private var isPhotoViewerPresented = false
    @State private var selectedImageURL: String?
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let detail = viewModel.memoDetail {
                    // 제목과 작성자 정보
                    HStack(spacing: 10) {
                        VStack(alignment: .leading) {
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
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading) {
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
                            .frame(height: 200)
                            .cornerRadius(10)
                        }
                    }
                } else {
                    Text("Failed to load memo details.")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationBarTitle(Text("상세보기"), displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if let memo = viewModel.memoDetail {
                            NavigationLink(destination: MyMemoEditView(memo: memo)) {
                                Label("수정", systemImage: "pencil")
                            }
                        }
                        Button(action: {
                            viewModel.deleteMemo(id: id, token: userManager.accessToken) {
                                dismiss()
                            }
                        }) {
                            Label("핀 삭제", systemImage: "trash")
                        }
                    } label: {
                        Label("edit", systemImage: "ellipsis.circle")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
            .onAppear {
                viewModel.fetchMemoDetail(id: id, token: userManager.accessToken)
            }
        }
        .fullScreenCover(isPresented: $isPhotoViewerPresented) {
            if let selectedImageURL = selectedImageURL {
                PhotoView(imageURL: selectedImageURL, isPresented: $isPhotoViewerPresented)
            }
        }
        .onChange(of: selectedImageURL) { _, newValue in
            if newValue != nil {
                isPhotoViewerPresented = true
            }
        }
    }
}
