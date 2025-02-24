import SwiftUI
import Alamofire

struct UserActionMenuView: View {
    var accesstoken: String
    var id: Int
    var userId: Int
    var nickname: String
    var type: String // 신고 메세지 표시를 위함
    @Binding var refresh: Bool
    
    @State var isPresentedDeclaration: Bool = false
    @State var isPresentedBlock: Bool = false
    @State var isReportSuccess: Bool = false // 신고 성공 여부

    var body: some View {
        Menu {
            Button("신고하기", action: { isPresentedDeclaration = true })
            Button("차단하기", action: { isPresentedBlock = true })
        } label: {
            Image(systemName: "ellipsis")
                .padding(6)
        }
        .alert("사용자 차단", isPresented: $isPresentedBlock) {
            Button("취소", role: .cancel) { }
            Button("확인", role: .destructive) {
                blockUser()
            }
        } message: {
            Text("\(nickname)님을 차단하시겠습니까?")
        }
        .confirmationDialog("\(type) 신고", isPresented: $isPresentedDeclaration, titleVisibility: .visible) {
            Button("스팸홍보/도배글", action: { declaration(reason: "SPAM") })
            Button("음란물", action: { declaration(reason: "OBSCENE") })
            Button("불법정보", action: { declaration(reason: "ILLEGAL_INFORMATION") })
            Button("청소년에게 유해한 내용", action: { declaration(reason: "HARMFUL_TO_MINORS") })
            Button("욕설/생명경시/혐오/차별적 표현", action: { declaration(reason: "OFFENSIVE_EXPRESSION") })
            Button("개인정보 노출", action: { declaration(reason: "PRIVACY_EXPOSURE") })
            Button("불쾌한 표현", action: { declaration(reason: "UNPLEASANT_EXPRESSION") })
            Button("기타", action: { declaration(reason: "OTHER") })
            Button("취소", role: .cancel) { }
        }
        .alert("신고 완료", isPresented: $isReportSuccess) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("정상적으로 신고되었습니다. 신고는 24시간 이내에 검토 후 처리됩니다.")
        }
    }
    
    private func declaration(reason: String) {
        let urlString = type == "메모" ? "https://api.mapping.kro.kr/api/v2/report/memo/report" : "https://api.mapping.kro.kr/api/v2/report/comment/report"
        let idKey = type == "메모" ? "memoId" : "commentId"
        let parameters: [String: Any] = [
            idKey: id,
            "reportReason": reason
        ]
        let headers: HTTPHeaders = [
            "Accept": "*/*",
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accesstoken)"
        ]
        
        AF.request(urlString,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
        .validate(statusCode: 200..<300)
        .response { response in
            switch response.result {
            case .success:
                print("\(type) 신고 성공")
                isReportSuccess = true // 신고 성공 시 Alert 표시
            case .failure(let error):
                print("\(type) 신고 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func blockUser() {
        let urlString = "https://api.mapping.kro.kr/api/v2/member/block"
        let parameters: [String: Any] = ["userId": userId]
        let headers: HTTPHeaders = [
            "Accept": "*/*",
            "Authorization": "Bearer \(accesstoken)"
        ]
        
        AF.request(urlString,
                   method: .post,
                   parameters: parameters,
                   encoding: URLEncoding(destination: .queryString),
                   headers: headers)
        .validate(statusCode: 200..<300)
        .response { response in
            switch response.result {
            case .success:
                print("유저 차단 성공 \(nickname)")
                refresh = true
            case .failure(let error):
                print("유저 차단 실패: \(error.localizedDescription)")
            }
        }
    }
}
