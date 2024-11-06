//
//  ProfileImageView.swift
//  Mapping
//
//  Created by 김민정 on 11/6/24.
//

import SwiftUI

struct ProfileImageView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var navigateToMyInfo = false  // 화면 전환을 위한 상태 변수
    
    // 프로필 이미지 URL 추출 로직을 외부로 분리
    private var profileImageURL: URL? {
        guard let profileImage = userManager.userInfo?.profileImage,
              let url = URL(string: profileImage) else {
            return nil
        }
        return url
    }
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                if userManager.isLoggedIn == false { // 비로그인
                    Button(action: {
                        navigateToMyInfo = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                            .foregroundStyle(Color.gray)
                            .background(Circle().fill(Color.white))
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
                    }
                } else {
                    Button(action: {
                        navigateToMyInfo = true
                    }) {
                        if let url = profileImageURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView() // 로딩 중 표시
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
                                    
                                case .failure:
                                    Image(systemName: "person.circle.fill") // 실패 시 기본 아이콘 표시
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50)
                                        .foregroundStyle(Color.skyBlue)
                                        .background(Circle().fill(Color.black))
                                        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
                                    
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else { // 프로필 이미지 URL이 없을 경우
                            Button(action: {
                                navigateToMyInfo = true
                            }) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                    .foregroundStyle(Color.skyBlue)
                                    .background(Circle().fill(Color.white))
                                    .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToMyInfo) {
                MyInfoView()
            }
        }
    }
}

#Preview {
    ProfileImageView()
        .environmentObject(UserManager())
}
