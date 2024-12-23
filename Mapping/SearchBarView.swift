import SwiftUI

import SwiftUI

struct SearchBarView: View {
    @Binding var update: Bool
    @Binding var selectedMemoId: Int?
    @State var query: String = ""
    @State var isMyInfo: Bool = false
    var item: [Item] = []
    
    @State private var searchResults: [Item] = []
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                TextField("Search", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: query) { newValue, oldValue in
                        searchResults = filterItems(by: newValue)
                    }
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
            
            List(searchResults, id: \.id) { result in
                HStack {
                    Text(result.title)
                    Spacer()
                    Text(result.category).font(.caption)
                }
                .listRowBackground(Color.lightGray)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedMemoId = result.id
                }
            }
            .scrollContentBackground(.hidden)
        }
        .onAppear {
            searchResults = item
        }
    }
    
    private func filterItems(by query: String) -> [Item] {
        guard !query.isEmpty else { return item } // 검색어가 비어 있으면 전체 아이템 반환
        
        let normalizedQuery = query.applyingTransform(.toUnicodeName, reverse: false) ?? query // 검색어 정규화
        
        return item.filter { item in
            let normalizedTitle = item.title.applyingTransform(.toUnicodeName, reverse: false) ?? item.title
            return normalizedTitle.contains(normalizedQuery) // 정규화된 문자열 비교
        }
    }
}
