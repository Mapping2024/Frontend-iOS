import SwiftUI
import Alamofire

struct UserActionMenuView: View {
    var accesstoken: String
    var id: Int
    var userId: Int
    var nickname: String
    var type: String
    
    @State var isPresentedDeclaration: Bool = false
    @State var isPresentedBlock: Bool = false
    
    var body: some View {
        Menu {
            Button("신고하기", action: {isPresentedDeclaration = true})
            Button("차단하기", action: {isPresentedBlock = true})
        } label: {
            Label("", systemImage: "ellipsis")
                .foregroundColor(.cBlack)
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
    }
    
    private func declaration(reason: String) {
            let urlString = "https://api.mapping.kro.kr/api/v2/memo/report"
            let parameters: [String: Any] = [
                "memoId": id,
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
                      print("게시글 신고 성공")
                  case .failure(let error):
                      print("게시글 신고 실패: \(error.localizedDescription)")
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
              case .failure(let error):
                  print("유저 차단 실패: \(error.localizedDescription)")
              }
          }
    }
}
