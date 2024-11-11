//
//  MappingApp.swift
//  Mapping
//
//  Created by 김민정 on 11/2/24.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct MappingApp: App {
    @StateObject private var userManager = UserManager()
    
    init() {
            // Kakao SDK 초기화
            if let kakaoNativeKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String {
                KakaoSDK.initSDK(appKey: kakaoNativeKey)
            }
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)  // UserManager를 환경 객체로 설정
                .onOpenURL(perform: { url in
                if (AuthApi.isKakaoTalkLoginUrl(url)) {
                    AuthController.handleOpenUrl(url: url)
                }
            })
        }
    }
}

extension Color {
    static let skyBlue = Color(red: 0.4627, green: 0.8392, blue: 1.0)
}
