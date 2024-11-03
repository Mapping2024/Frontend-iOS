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
        KakaoSDK.initSDK(appKey: "a34cfc6091e7f408f953597d0eba7a19")
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
