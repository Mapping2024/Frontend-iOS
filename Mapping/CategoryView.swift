import SwiftUI

struct CategoryView: View {
    @Binding var category: String
    let CategoryOptions: [(String, String)] = [
            ("전체", "mappin"),
            ("흡연장", "smoke.fill"),
            ("쓰레기통", "trash.fill"),
            ("공용 화장실", "toilet.fill")
        ]
   
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(CategoryOptions, id: \.0) { key, value in
                    Button(action: {
                        category = key
                    }, label: {
                        HStack {
                            Image(systemName: value)
                            if key == "공용 화장실" {
                                Text("화장실")
                            } else {
                                Text(key)
                            }
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
    CategoryView(category: .constant("전체"))
}
