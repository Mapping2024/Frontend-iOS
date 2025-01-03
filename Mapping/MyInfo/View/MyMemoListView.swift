import SwiftUI

struct MyMemoListView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = MyMemoListViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.myMemo) { memo in
                NavigationLink(destination: MyMemoDetailView(id: memo.id)) {
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
                                if memo.secret {
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
                viewModel.fetchMyMemo(userManager: userManager)
            }
        }
    }
}

#Preview {
    MyMemoListView()
        .environmentObject(UserManager())
}
