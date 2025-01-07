import SwiftUI

struct SearchBarView: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var update: Bool
    @Binding var selectedMemoId: Int?
    @Binding var item: [Item]
    @State var query: String = ""
    @State var isMyInfo: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                TextField("Search", text: $query)
                    .textFieldStyle(.roundedBorder)
                
                Spacer()
                
                Button(action: { isMyInfo.toggle() }) {
                    if userManager.userInfo != nil {
                        ProfileImageView(imageURL: userManager.userInfo?.profileImage)
                            .frame(width: 40, height: 40)
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 40, height: 40)
                            Text("Login")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .sheet(isPresented: $isMyInfo, content: {
                    NavigationStack {
                        MyInfoView()
                    }.onDisappear {
                        update = true
                    }
                    .presentationDragIndicator(.visible)
                })
                Spacer()
            }
            
            List(item.filter {
                $0.title.lowercased().contains(query.lowercased()) || query.isEmpty
            }
                 , id: \.id) { result in
                HStack {
                    Text(result.title)
                    Spacer()
                    Text(result.category).font(.caption)
                }
                .listRowBackground(Color.cLightGray)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedMemoId = result.id
                }
            }
                 .scrollContentBackground(.hidden)
        }
    }
}

