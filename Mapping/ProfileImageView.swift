import SwiftUI

struct ProfileImageView: View {
    var imageURL: String? // 이미지 URL을 문자열로 받는 매개변수
    
    // 프로필 이미지 URL 생성 로직
    private var profileImageURL: URL? {
        guard let imageURL = imageURL, !imageURL.isEmpty, let url = URL(string: imageURL) else {
            return nil
        }
        return url
    }

    var body: some View {
        VStack {
            if let url = profileImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // 로딩 중 표시
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
                        
                    case .failure:
                        defaultImageView() // 기본 이미지 출력
                    @unknown default:
                        EmptyView()
                    }
                }
            } else { // URL이 없거나 잘못된 경우
                defaultImageView()
            }
        }
    }
    
    // 기본 이미지 뷰를 반환하는 함수
    @ViewBuilder
    private func defaultImageView() -> some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color.gray)
            .background(Circle().fill(Color.white))
            .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProfileImageView(imageURL: "https://example.com/profile.jpg")
            .frame(width: 70, height: 70)
        
        ProfileImageView(imageURL: nil) // URL이 없는 경우
            .frame(width: 70, height: 70)
        
        ProfileImageView(imageURL: "") // 빈 문자열인 경우
            .frame(width: 70, height: 70)
    }
}
