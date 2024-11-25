import SwiftUI

struct CategoryView: View {
    let CategoryOptions: [(String, String)] = [
            ("전체", "mappin"),
            ("흡연장", "smoke.fill"),
            ("쓰레기통", "trash.fill"),
            ("화장실", "toilet.fill")
        ]
    //let onSelected: (String) -> Void
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(CategoryOptions, id: \.0) { key, value in
                    Button(action: {
                        // action
                        //onSelected(key)
                    }, label: {
                        HStack {
                            Image(systemName: value)
                            Text(key)
                        }
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(Color.gray.opacity(0.3))
                    .foregroundStyle(.black)
                }
            }
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    CategoryView(onSelected: { _ in })
//}
#Preview {
    CategoryView()
}
