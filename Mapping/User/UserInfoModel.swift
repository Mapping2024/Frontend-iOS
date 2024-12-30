struct UserInfo: Codable {
    let socialId: String
    let nickname: String
    let profileImage: String?
    let role: String
}

struct Tokens: Codable {
    let accessToken: String
    let refreshToken: String
}

struct UserInfoResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: UserData?
}

struct UserData: Codable {
    let socialId: String
    let nickname: String
    let profileImage: String?
    let role: String
    let tokens: Tokens?
}
