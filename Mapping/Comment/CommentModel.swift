struct CommentsResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: [Int]?
}

struct CommentResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: Comment?
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

    // 기본 생성자 추가
    init(
        id: Int = 0,
        comment: String = "",
        rating: Int = 0,
        likeCnt: Int = 0,
        modify: Bool = false,
        nickname: String = "",
        profileImageUrl: String? = nil,
        updatedAt: String = "",
        myLike: Bool = false,
        isAnimatingLike: Bool? = nil
    ) {
        self.id = id
        self.comment = comment
        self.rating = rating
        self.likeCnt = likeCnt
        self.modify = modify
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.updatedAt = updatedAt
        self.myLike = myLike
        self.isAnimatingLike = isAnimatingLike
    }
}

