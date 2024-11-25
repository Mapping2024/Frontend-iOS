import SwiftUI

struct ProfileImageView: View {
    @EnvironmentObject var userManager: UserManager
    
    // 프로필 이미지 URL 추출 로직을 외부로 분리
    private var profileImageURL: URL? {
        guard let profileImage = userManager.userInfo?.profileImage,
              let url = URL(string: profileImage) else {
            return nil
        }
        return url
    }

    var body: some View {
        VStack {
            if userManager.isLoggedIn == false { // 비로그인 상태
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.gray)
                    .background(Circle().fill(Color.white))
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
            } else {
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
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else { // 프로필 이미지 URL이 없을 경우
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.skyBlue)
                        .background(Circle().fill(Color.white))
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
                }
            }
        }
    }
}

#Preview {
    ProfileImageView()
        .environmentObject(UserManager())
        .frame(width: 70, height: 70)
}

