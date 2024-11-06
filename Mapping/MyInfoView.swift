//
//  MyInfoView.swift
//  Mapping
//
//  Created by 김민정 on 11/6/24.
//

import SwiftUI

struct MyInfoView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        if userManager.isLoggedIn, let userInfo = userManager.userInfo {
            HStack{
                Text("\(userInfo.nickname)님 안녕하세요!")
                    .padding()
                Button(action: {userManager.logout()}) {
                    Text("로그아웃")
                }
            }
        } else {
            HStack {
                Button(action: {
                    userManager.kakaoLogin()
                }){
                    Text("로그인이 필요합니다.")
                }
                .padding()
            }
        }
    }
}

#Preview {
    MyInfoView()
        .environmentObject(UserManager())
}
