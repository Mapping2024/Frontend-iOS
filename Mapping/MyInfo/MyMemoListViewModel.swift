import Foundation
import Alamofire

final class MyMemoListViewModel: ObservableObject {
    @Published var myMemo: [MyMemo] = []
    
    func fetchMyMemo(userManager: UserManager) {
        userManager.fetchUserInfo() // 토큰 유효성 확인 및 재발급
        let accessToken = userManager.accessToken
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        let url = "https://api.mapping.kro.kr/api/v2/memo/my-memo"
        
        AF.request(url, method: .get, headers: headers).responseDecodable(of: MyMemoResponse.self) { [weak self] response in
            switch response.result {
            case .success(let memoResponse):
                if memoResponse.success {
                    DispatchQueue.main.async {
                        self?.myMemo = memoResponse.data
                    }
                } else {
                    print("Failed to fetch memo locations: \(memoResponse.message)")
                }
            case .failure(let error):
                print("Error fetching memo locations: \(error)")
            }
        }
    }
}

