import SwiftUI

struct MyInfoView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack{
            GroupBox(label:
                        Label("프로필", systemImage: "person")) {
                HStack{
                    ProfileImageView(imageURL: userManager.userInfo?.profileImage)
                        .frame(width: 50, height: 50)
                    if userManager.isLoggedIn, let userInfo = userManager.userInfo {
                        HStack{
                            Text("\(userInfo.nickname)")
                                .font(.body).fontWeight(.bold)
                                .padding(.leading)
                            Spacer()
                            NavigationLink(destination: ChangeMyInfoView()){
                                Text("프로필 변경")
                                    .padding(7)
                                    .background(Color("pastelAqua")) // 원하는 백그라운드 색상 지정
                                    .foregroundStyle(.white)
                                    .cornerRadius(10) // 백그라운드에 모서리 곡선 적용
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color("pastelAqua"), lineWidth: 2)
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
                                    .background(Color("cWhite"))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color("pastelAqua"), lineWidth: 2)
                                    )
                            }
                            .padding()
                        }
                    }
                }
            }
                        .padding()
                        .navigationBarTitle(Text("내 정보"), displayMode: .inline)
                        .navigationBarItems(trailing: Button(action: {userManager.logout()}) {
                            Image(systemName: "rectangle.portrait.and.arrow.forward")
                        }
                            .disabled(!userManager.isLoggedIn))
            Divider()
                .padding([.horizontal])
            
            if userManager.isLoggedIn {
                GroupBox(label: Text("메모 관리")){
                    VStack(alignment: .leading){
                        
                        NavigationLink(destination: MyMemoListView()) {
                            Text("📝 내 메모")
                                .font(.headline)
                                .padding()
                                .foregroundStyle(Color("cBlack"))
                        }
                        
                        Divider()
                        
                        NavigationLink(destination: MyMemoListView()) {
                            Text("👍 좋아요 누른 메모")
                                .font(.headline)
                                .padding()
                                .foregroundStyle(Color("cBlack"))
                        }
                    }
                }
                .padding()
            }
            Spacer()
        }
        .padding(.top)
    }
}

#Preview {
    let userManager = UserManager()
    userManager.isLoggedIn = true // 로그인된 상태로 설정
    userManager.userInfo = UserInfo(
        socialId: "123456",
        nickname: "테스트 사용자",
        profileImage: nil, // 필요하면 이미지 URL 추가
        role: "user"
    )

    return MyInfoView()
        .environmentObject(userManager)
}
