import SwiftUI

struct SearchBarView: View {
    @Binding var update: Bool
    @Binding var selectedMemoId: Int?
    @Binding var item: [Item]
    @State var query: String = ""
    @State var isMyInfo: Bool = false
    
    @State private var searchResults: [Item] = []
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                TextField("Search", text: $query)
                    .textFieldStyle(.roundedBorder)
                
                Spacer()
                
                Button(action: { isMyInfo.toggle() }) {
                    ProfileImageView()
                        .frame(width: 40, height: 40)
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
            
            List(item.filter{$0.title.hasPrefix(query) || query == ""}, id: \.id) { result in
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

