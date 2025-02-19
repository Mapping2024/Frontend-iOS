import AuthenticationServices
import SwiftUI

struct AppleSignInView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.colorScheme) var colorScheme // 다크모드 감지
    
    var body: some View {
        SignInWithAppleButton(

            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
          
            onCompletion: { result in
                switch result {
                case .success(let authResults):
                    if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
//                        let fullName = appleIDCredential.fullName
//                        let email = appleIDCredential.email

                        if let authorizationCodeData = appleIDCredential.authorizationCode,
                           let authorizationCodeString = String(data: authorizationCodeData, encoding: .utf8) {
                            //print("Authorization Token: \(authorizationCodeString)")
                            userManager.appleLogin(appleAuthorizationCode: authorizationCodeString)
                        }
                    }
                case .failure(let error):
                    print("Apple 로그인 에러: \(error.localizedDescription)")
                }
            }
        )
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .whiteOutline) // 스타일 (.black, .white, .whiteOutline) 선택 가능
    }
}
