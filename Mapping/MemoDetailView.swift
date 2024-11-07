//
//  MemoDetailView.swift
//  Mapping
//
//  Created by 김민정 on 11/3/24.
//

import SwiftUI
import Alamofire

import SwiftUI
import Alamofire

struct MemoDetailView: View {
    @EnvironmentObject var userManager: UserManager
    var id: Int
    @State private var memoDetail: MemoDetail?
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let detail = memoDetail {
                HStack {
                    Text(detail.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    Spacer()
                    if let profileImageUrl = detail.profileImage {
                        AsyncImage(url: URL(string: profileImageUrl)) { image in
                            image
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .padding(.top)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .padding(.top)
                    }
                    
                    Text(detail.nickname)
                        .font(.headline)
                        .padding(.top)
                }
                
                Divider()
                
                Text(detail.content)
                    .font(.body)
                
                if let images = detail.images, !images.isEmpty {
                    if images.count == 1 {
                        AsyncImage(url: URL(string: images[0])) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(images, id: \.self) { imageUrl in
                                    AsyncImage(url: URL(string: imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .frame(width: 200, height: 150)
                                                .cornerRadius(8)
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 150)
                    }
                }
                
                HStack {
                    Text("👍 \(detail.likeCnt)")
                    Text("👎 \(detail.hateCnt)")
                }
                .font(.caption)
                
                Spacer()
            } else if isLoading {
                ProgressView("Loading...")
            } else {
                Text("Failed to load data.")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
            delayFetch()
        }
    }
    
    private func delayFetch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            fetchMemoDetail()
        }
    }
    
    private func fetchMemoDetail() {
        let accessToken = userManager.accessToken
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        let url = "https://api.mapping.kro.kr/api/v2/memo/detail?memoId=\(id)"
        
        AF.request(url, headers: headers)
            .responseDecodable(of: MemoDetailResponse.self) { response in
                switch response.result {
                case .success(let memoDetailResponse):
                    if memoDetailResponse.success {
                        self.memoDetail = memoDetailResponse.data
                    } else {
                        print("Failed to fetch memo detail: \(memoDetailResponse.message)")
                    }
                case .failure(let error):
                    print("Error fetching memo detail: \(error)")
                }
                self.isLoading = false
            }
    }
}


// 응답 전체 구조체
struct MemoDetailResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: MemoDetail
}

struct MemoDetail: Decodable {
    let id: Int
    let title: String
    let content: String
    let likeCnt: Int
    let hateCnt: Int
    let images: [String]?
    let myMemo: Bool
    let authorId: Int
    let nickname: String
    let profileImage: String?
}

#Preview {
    MemoDetailView(id: 3)
        .environmentObject(UserManager())
}
