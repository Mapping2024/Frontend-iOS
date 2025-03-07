struct ListMemo: Identifiable, Decodable {
    let id: Int
    let title: String
    let content: String
    let category: String
    let likeCnt: Int
    let hateCnt: Int
    let images: [String]
    let secret: Bool?
}

struct ListMemoResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: [ListMemo]
}
