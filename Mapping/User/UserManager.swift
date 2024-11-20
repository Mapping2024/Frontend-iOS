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
        fristLogin() // 로그인 시 백엔드에서 사용자 정보 가져옴
    }
    
    func logout() {
        self.accessTokenKakao = ""
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
    
    func fristLogin() {
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
                                if let token = userData.tokens {
                                    self.accessToken = token.accessToken
                                    self.refreshToken = token.refreshToken
                                }
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
    
    func fetchUserInfo() {
        let url = "https://api.mapping.kro.kr/api/v2/member/user-info"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        AF.request(url, method: .get, headers: headers)
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
                                print(self.accessToken)
                                print("refresh token: \(self.refreshToken)")
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
    
    func expiredAccessToken() {
        let url = "https://api.mapping.kro.kr/api/v2/member/token-reissue"
        let headers: HTTPHeaders = [
            "Authorization-Refresh": "Bearer \(self.refreshToken)"
        ]
        
        AF.request(url, method: .get, headers: headers)
            .response { response in
                guard let httpResponse = response.response else {
                    print("No response received")
                    //self.logout() // 로그아웃 처리
                    return
                }

                if httpResponse.statusCode == 200 {
                    print(httpResponse)
                    if let newAccessToken = httpResponse.headers["Authorization"]
                        {
                        DispatchQueue.main.async {
                            self.accessToken = newAccessToken
                            //self.refreshToken = newRefreshToken
                            print("Token reissued successfully \(self.accessToken)")
                        }
                    } else {
                        print("Missing tokens in response headers")
                        //self.logout() // 로그아웃 처리
                    }
                } else {
                    print("Failed to reissue token, status code: \(httpResponse.statusCode)")
                    self.logout() // 로그아웃 처리
                }
            }
    }
}

