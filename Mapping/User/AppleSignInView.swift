import AuthenticationServices
import SwiftUI

struct AppleSignInView: View {
    var body: some View {
        SignInWithAppleButton(

            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
          
            onCompletion: { result in
                switch result {
                case .success(let authResults):
                    if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                        let userIdentifier = appleIDCredential.user
                        let fullName = appleIDCredential.fullName
                        let email = appleIDCredential.email
                        
                        // identityToken을 활용해 서버 검증을 진행할 수 있습니다.
                        if let identityTokenData = appleIDCredential.identityToken,
                           let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
                            print("Identity Token: \(identityTokenString)")
                        }
                        
                        print("사용자 ID: \(userIdentifier)")
                        print("이름: \(fullName?.givenName ?? "")")
                        print("이메일: \(email ?? "")")
                    }
                case .failure(let error):
                    print("Apple 로그인 에러: \(error.localizedDescription)")
                }
            }
        )
        .signInWithAppleButtonStyle(.white) // 스타일 (.black, .white, .whiteOutline) 선택 가능
    }
}
