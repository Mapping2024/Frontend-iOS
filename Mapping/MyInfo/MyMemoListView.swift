//
//  MyMemoListView.swift
//  Mapping
//
//  Created by 김민정 on 11/7/24.
//

import SwiftUI
import Alamofire

struct MyMemoListView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var myMemo: [MyMemo] = []
    
    var body: some View {
        NavigationStack {
            List(myMemo) { memo in
                NavigationLink(destination: MyMemoDetailView(id: memo.id)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack{
                            VStack(alignment: .leading){
                                Text(memo.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(memo.content)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2) // 줄 수 제한
                            }
                            Spacer()
                            if memo.images.first != nil {
                                AsyncImage(url: URL(string: memo.images.first!)) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 50,height: 50)
                                .cornerRadius(10)
                            }
                        }
                        HStack {
                            Text("\(memo.category)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            HStack {
                                if(memo.secret){
                                    Image(systemName: "parkingsign")
                                }
                                HStack {
                                    Image(systemName: "hand.thumbsup.fill")
                                    Text("\(memo.likeCnt)")
                                }
                                
                                HStack {
                                    Image(systemName: "hand.thumbsdown.fill")
                                    Text("\(memo.hateCnt)")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationBarTitle("내 메모")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    fetchMyMemo()
                }
            }
        }
    }
    
    private func fetchMyMemo() {
        userManager.fetchUserInfo() // 토큰 유효성 확인 및 재발급
        let accessToken = userManager.accessToken
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        let url = "https://api.mapping.kro.kr/api/v2/memo/my-memo"
        
        AF.request(url, method: .get, headers: headers).responseDecodable(of: MyMemoResponse.self) { response in
            switch response.result {
            case .success(let memoResponse):
                if memoResponse.success {
                    self.myMemo = memoResponse.data
                } else {
                    print("Failed to fetch memo locations: \(memoResponse.message)")
                }
            case .failure(let error):
                print("Error fetching memo locations: \(error)")
            }
        }
    }
}

#Preview {
    MyMemoListView()
        .environmentObject(UserManager())
}
