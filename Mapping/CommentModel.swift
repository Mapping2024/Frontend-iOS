struct CommentResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: [Comment]?
}

struct Comment: Identifiable, Decodable {
    let id: Int
    let comment: String
    let rating: Int
    let likeCnt: Int
    let modify: Bool
    let nickname: String
    let profileImageUrl: String?
    let updatedAt: String
    let myLike: Bool
    
    var isAnimatingLike: Bool? = nil
}
