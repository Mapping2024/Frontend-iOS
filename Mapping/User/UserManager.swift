//
//  UserManager.swift
//  Mapping
//
//  Created by 김민정 on 11/2/24.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKUser
import Combine
import Alamofire

class UserManager: ObservableObject {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("accessTokenKakao") var accessTokenKakao: String = ""
    @AppStorage("accessToken") var accessToken: String = ""
    @AppStorage("refreshToken") var refreshToken: String = ""
    @Published var userInfo: UserInfo? = nil
    
    func login(accessTokenKakao: String) {
        self.accessTokenKakao = accessTokenKakao
        self.isLoggedIn = true
        fetchUserInfo()  // 로그인 시 백엔드에서 사용자 정보 가져옴
    }
    
    func logout() {
        self.accessToken = ""
        self.refreshToken = ""
        self.userInfo = nil
        self.isLoggedIn = false
    }

    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print("Kakao login error: \(error)")
                } else if let token = oauthToken?.accessToken {
                    print("Kakao login success, kakaoToken: \(token)")
                    self.login(accessTokenKakao: token)  // 로그인 메서드 호출
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print("Kakao login error: \(error)")
                } else if let token = oauthToken?.accessToken {
                    print("Kakao login success, kakaoToken: \(token)")
                    self.login(accessTokenKakao: token)  // 로그인 메서드 호출
                }
            }
        }
    }
    
    func fetchUserInfo() {
        let url = "https://api.mapping.kro.kr/api/v2/member/login"
        let parameters: [String: String] = ["accessToken": accessTokenKakao]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseDecodable(of: UserInfoResponse.self) { response in
                switch response.result {
                case .success(let data):
                    if data.status == 200, data.success {
                        if let userData = data.data {
                            DispatchQueue.main.async {
                                self.userInfo = UserInfo(
                                    socialId: userData.socialId,
                                    nickname: userData.nickname,
                                    profileImage: userData.profileImage,
                                    role: userData.role
                                )
                                self.accessToken = userData.tokens.accessToken
                                self.refreshToken = userData.tokens.refreshToken
                                print(self.accessToken)
                            }
                        }
                    } else {
                        print("Failed to fetch user info: \(data.message)")
                    }
                case .failure(let error):
                    print("Error fetching user info: \(error)")
                }
            }
    }
}

