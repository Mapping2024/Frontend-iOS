import SwiftUI

struct MyInfoView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlertLogout = false
    @State private var showAlertWithdraw = false
    
    var body: some View {
        NavigationStack {
            GroupBox(label: Label("프로필", systemImage: "person")) {
                HStack {
                    ProfileImageView(imageURL: userManager.userInfo?.profileImage)
                        .frame(width: 50, height: 50)
                    
                    if userManager.isLoggedIn, let userInfo = userManager.userInfo {
                        HStack {
                            Text(userInfo.nickname)
                                .font(.body).fontWeight(.bold)
                                //.padding(.leading)

                            Spacer()
                            NavigationLink(destination: ChangeMyInfoView()) {
                                Text("프로필 변경")
                                    .font(.subheadline)
                                    .padding(7)
                                    .background(Color("pastelAqua"))
                                    .foregroundStyle(.white)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("pastelAqua"), lineWidth: 2))
                            }
                        }
                    } else {
                        Spacer()
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                                userManager.kakaoLogin()
                            }) {
                                Text("카카오로 로그인 하기")
                                    .padding(7)
                                    .background(Color("pastelAqua"))
                                    .foregroundStyle(Color.white)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("pastelAqua"), lineWidth: 2))
                            }
                            .padding()
                        }
                    }
                }
            }
            .padding()
            .navigationBarTitle("내 정보", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showAlertLogout = true
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.forward")
            }.disabled(!userManager.isLoggedIn))
            .alert("로그아웃", isPresented: $showAlertLogout) {
                Button("취소", role: .cancel) { }
                Button("확인", role: .destructive) {
                    userManager.logout()
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("로그아웃 하시겠습니까?")
            }
            
            Divider().padding([.horizontal])
            
            if userManager.isLoggedIn {
                GroupBox(label: Text("내 활동")) {
                    VStack(alignment: .leading) {
                        NavigationLink(destination: MemoListView(type: "my-memo")) {
                            HStack{
                                Text("📝 내 메모")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .padding()
                                    .foregroundStyle(Color("cBlack"))
                                
                                Spacer()
                            }
                        }
                        
                        Divider()
                        
                        NavigationLink(destination: MemoListView(type: "liked")) {
                            HStack{
                                Text("👍 좋아요 누른 메모")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .padding()
                                    .foregroundStyle(Color("cBlack"))
                                
                                Spacer()
                            }
                        }
                        
                        Divider()
                        
                        NavigationLink(destination: MemoListView(type: "commented")) {
                            HStack{
                                Text("💬 댓글 단 메모")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .padding()
                                    .foregroundStyle(Color("cBlack"))
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            if userManager.isLoggedIn {
                Button(action: {
                    showAlertWithdraw = true
                    userManager.fetchUserInfo()
                }) {
                    Text("회원 탈퇴")
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                }
                .padding()
                .alert("회원 탈퇴", isPresented: $showAlertWithdraw) {
                    Button("취소", role: .cancel) { }
                    Button("확인", role: .destructive) {
                        userManager.withdrawUser { success in
                            if success {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                } message: {
                    Text("회원 탈퇴 후 30일간 데이터가 유지되며, 이후 완전히 삭제됩니다. 만약 30일 안에 재가입하면 기존 정보를 유지할 수 있습니다. 정말 탈퇴하시겠습니까?")
                }
            }
        }
        .padding(.top)
    }
}

#Preview {
    let userManager = UserManager()
    userManager.isLoggedIn = true
    userManager.userInfo = UserInfo(socialId: "123456", nickname: "테스트 사용자", profileImage: nil, role: "user")

    return MyInfoView().environmentObject(userManager)
}
