struct BlockedUsers: Decodable, Identifiable {
    let userId: Int
    let profileImage: String?
    let nickname: String
    
    var id: Int { userId } // Identifiable을 따르기 위해 id 프로퍼티 추가
}

struct BlockedUsersResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: [BlockedUsers]
}

struct UnblockedResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
}
