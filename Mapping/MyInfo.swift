//
//  MyInfo.swift
//  Mapping
//
//  Created by 김민정 on 11/2/24.
//

import SwiftUI

struct MyInfo: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        Button(action: {
            userManager.kakaoLogin()
        }){
            Text("kakao login")
        }
    }
}

#Preview {
    MyInfo()
}
