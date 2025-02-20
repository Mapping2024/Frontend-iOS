import Foundation
import Alamofire

final class BlockedUsersViewModel: ObservableObject {
    @Published var blockedUsers: [BlockedUsers] = []
    
    func fetchBlockUsers(userManager: UserManager) {
        userManager.fetchUserInfo() // 토큰 유효성 확인 및 재발급
        let accessToken = userManager.accessToken
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        let url = "https://api.mapping.kro.kr/api/v2/member/block/list"
        
        AF.request(url, method: .get, headers: headers).responseDecodable(of: BlockedUsersResponse.self) { [weak self] response in
            switch response.result {
            case .success(let blockResponse):
                if blockResponse.success {
                    DispatchQueue.main.async {
                        self?.blockedUsers = blockResponse.data
                    }
                } else {
                    print("Failed to fetch blocked user list locations: \(blockResponse.message)")
                }
            case .failure(let error):
                print("Error fetching blocked user list locations: \(error)")
            }
        }
    }
    
    func unblockedUser(userManager: UserManager, userId: Int) {
        userManager.fetchUserInfo()
        let accessToken = userManager.accessToken
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        let url = "https://api.mapping.kro.kr/api/v2/member/block/\(userId)"
        
        AF.request(url, method: .delete, headers: headers).responseDecodable(of: UnblockedResponse.self) { [weak self] response in
            switch response.result {
            case .success(let unblockedResponse):
                if unblockedResponse.success {
                    DispatchQueue.main.async {
                        self?.blockedUsers.removeAll { $0.userId == userId } // 차단 해제된 사용자 제거
                    }
                    print("User \(userId) successfully unblocked.")
                } else {
                    print("Failed to unblock user: \(unblockedResponse.message)")
                }
            case .failure(let error):
                print("Error unblocking user: \(error.localizedDescription)")
            }
        }
    }

}
