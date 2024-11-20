//
//  UserInfo.swift
//  Mapping
//
//  Created by 김민정 on 11/2/24.
//

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

// 서버 응답 형식과 일치하는 구조체
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
