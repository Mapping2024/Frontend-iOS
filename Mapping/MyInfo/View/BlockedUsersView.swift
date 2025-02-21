import SwiftUI

struct BlockedUsersView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = BlockedUsersViewModel()
    @State private var showAlert = false
    @State private var selectedUserId: Int?
    @State private var selectedUserNickname: String = ""
    
    var body: some View {
        NavigationStack {
            if viewModel.blockedUsers.isEmpty {
                Text("차단한 사용자가 없습니다.")
            } else {
                List(viewModel.blockedUsers) { blockedUser in
                    Button(action: {
                        selectedUserId = blockedUser.userId
                        selectedUserNickname = blockedUser.nickname
                        showAlert = true
                    }) {
                        HStack {
                            ProfileImageView(imageURL: blockedUser.profileImage)
                                .frame(width: 40, height: 40)
                            
                            Text(blockedUser.nickname)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .navigationBarTitle("차단한 사용자")
        .onAppear {
            viewModel.fetchBlockUsers(userManager: userManager)
        }
        .alert("\(selectedUserNickname)님을 차단 해제하시겠습니까?", isPresented: $showAlert) {
            Button("취소", role: .cancel) { }
            Button("확인", role: .destructive) {
                if let userId = selectedUserId {
                    viewModel.unblockedUser(userManager: userManager, userId: userId)
                }
            }
        }
    }
}
