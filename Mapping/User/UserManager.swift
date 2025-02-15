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
        if !isLoggedIn { return }
        let url = "https://api.mapping.kro.kr/api/v2/member/user-info"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        AF.request(url, method: .get, headers: headers)
            .responseDecodable(of: UserInfoResponse.self) { response in
                // 먼저 응답 상태 코드 확인
                if let httpResponse = response.response {
                    switch httpResponse.statusCode {
                    case 200:
                        // 성공적인 응답 처리
                        print("Request successful (200): Data fetched successfully.")
                        if let data = response.value {
                            if data.status == 200, data.success {
                                if let userData = data.data {
                                    DispatchQueue.main.async {
                                        self.userInfo = UserInfo(
                                            socialId: userData.socialId,
                                            nickname: userData.nickname,
                                            profileImage: userData.profileImage,
                                            role: userData.role
                                        )
                                    }
                                }
                            } else {
                                print("Failed to fetch user info: \(data.message)")
                            }
                        }
                        
                    case 401:
                        // 401 에러 처리: 토큰 만료나 권한 문제로 처리
                        print("Request failed (401): Unauthorized - Token may be expired.")
                        // 토큰 재발급 처리를 위한 로직을 추가하거나 로그아웃 등을 처리
                        self.expiredAccessToken()  // 예시로 토큰 재발급 처리 호출
                    default:
                        // 기타 상태 코드 처리
                        print("Request failed with status code: \(httpResponse.statusCode)")
                    }
                }
                
                // 실패 결과 처리 (디코딩 에러 등)
                if let error = response.error {
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
                    self.logout() // 로그아웃 처리
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    print(httpResponse)
                    if let newAccessToken = httpResponse.headers["authorization"], let newRefreshToken = httpResponse.headers["authorization-refresh"]
                    {
                        DispatchQueue.main.async {
                            self.accessToken = newAccessToken.replacingOccurrences(of: "Bearer ", with: "")
                            self.refreshToken = newRefreshToken.replacingOccurrences(of: "Bearer ", with: "")
                            print("Token reissued successfully ")
                            self.fetchUserInfo()
                        }
                    } else {
                        print("Missing tokens in response headers")
                        self.logout() // 로그아웃 처리
                    }
                } else {
                    print("Failed to reissue token, status code: \(httpResponse.statusCode)")
                    self.logout() // 로그아웃 처리
                }
            }
    }
    
    func withdrawUser(completion: @escaping (Bool) -> Void) {
            let url = "https://api.mapping.kro.kr/api/v2/member/withdraw"
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(accessToken)",
                "accept": "*/*"
            ]
            
            AF.request(url, method: .delete, headers: headers)
                .validate(statusCode: 200..<300)
                .response { response in
                    DispatchQueue.main.async {
                        switch response.result {
                        case .success:
                            print("✅ 회원 탈퇴 성공")
                            self.isLoggedIn = false
                            self.userInfo = nil
                            self.accessTokenKakao = ""
                            self.accessToken = ""
                            self.refreshToken = ""
                            completion(true)
                        case .failure(let error):
                            print("❌ 회원 탈퇴 실패: \(error.localizedDescription)")
                            completion(false)
                        }
                    }
                }
        }
}

