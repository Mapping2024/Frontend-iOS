import SwiftUI

struct MemoListView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = MemoListViewModel()
    var type: String
    
    var body: some View {
        NavigationStack {
            List(viewModel.listMemo) { memo in
                NavigationLink(destination: type == "my-memo" ?
                               AnyView(MyPageMemoDetailView(id: memo.id)) :
                                AnyView(MemoListDetailView(id: memo.id))
                )
                {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(memo.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(memo.content)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            if let imageUrl = memo.images.first, let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)
                            }
                        }
                        HStack {
                            Text("\(memo.category)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            HStack {
                                if memo.secret != nil && memo.secret == true {
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
            .navigationBarTitle(
                type == "liked" ? "좋아요 누른 메모" :
                    type == "commented" ? "댓글 단 메모" : "내 메모"
            )
            
            .onAppear {
                viewModel.fetchListMemo(userManager: userManager, type: type)
            }
        }
    }
}

//#Preview {
//    MemoListView()
//}
