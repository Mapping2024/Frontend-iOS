//
//  MyInfoView.swift
//  Mapping
//
//  Created by 김민정 on 11/6/24.
//

import SwiftUI

struct MyInfoView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GroupBox(label:
                    Label("프로필", systemImage: "person")) {
            HStack() {
                ProfileImageView()
                    .frame(width: 50, height: 50)
                //.padding(.leading)
                if userManager.isLoggedIn, let userInfo = userManager.userInfo {
                    HStack{
                        Text("\(userInfo.nickname)님")
                            .font(.title2)
                            .padding(.leading)
                        Spacer()
                        NavigationLink(destination: ChangeMyInfoView()){
                            Text("프로필 변경")
                                .padding(7)
                                .background(Color.white) // 원하는 백그라운드 색상 지정
                                .cornerRadius(10) // 백그라운드에 모서리 곡선 적용
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                                .padding()
                        }
                    }
                } else {
                    Spacer()
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                            userManager.kakaoLogin()
                        }){
                            Text("카카오로 로그인 하기")
                                .padding(7)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                        }
                        .padding()
                    }
                }
            }
        }
                    .padding()
                    .navigationBarTitle("내 정보")
                    .navigationBarItems(trailing: Button(action: {userManager.logout()}) {
                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                    }
                        .disabled(!userManager.isLoggedIn))
        Divider()
            .padding([.horizontal, .bottom])
        
        if userManager.isLoggedIn {
            NavigationLink(destination: MyMemoListView()) {
                Text("내가 작성한 메모")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        Spacer()
    }
}

#Preview {
    MyInfoView()
        .environmentObject(UserManager())
}
