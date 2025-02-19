struct MemoDetailResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: MemoDetail
}

//1개만 상세보기
struct MemoDetail: Decodable {
    let id: Int
    let title: String
    let content: String
    let date: String
    let lat: Double
    let lng: Double
    let category: String
    let likeCnt: Int
    let hateCnt: Int
    let images: [String]?
    let myMemo: Bool
    let myLike: Bool
    let myHate: Bool
    let certified: Bool
    let authorId: Int
    let nickname: String
    let profileImage: String?
}

// 맵에서 검색할때
struct MemoData: Identifiable, Decodable {
    let id: Int
    let title: String
    let category: String
    let lat: Double
    let lng: Double
    let certified: Bool
    let secret: Bool
}

struct MemoResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: [MemoData]
}
