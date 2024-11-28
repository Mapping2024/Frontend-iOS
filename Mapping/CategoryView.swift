import SwiftUI

struct CategoryView: View {
    @Binding var category: String
    let CategoryOptions: [(String, String)] = [
        ("전체", "mappin"),
        ("흡연장", "smoke.fill"),
        ("쓰레기통", "trash.fill"),
        ("공용 화장실", "toilet.fill"),
        ("기타", "star.fill")
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center) {
                Spacer()
                ForEach(CategoryOptions, id: \.0) { key, value in
                    Button(action: {
                        category = key
                    }, label: {
                        HStack {
                            Image(systemName: value)
                            if key == "공용 화장실" {
                                Text("화장실").font(.caption)
                            } else {
                                Text(key).font(.caption)
                            }
                        }
                        .padding(10)
                        .background(category == key ? Color.blue : Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        .foregroundStyle(category == key ? .white : .black)
                    })
                }
                Spacer()
            }
        }
    }
}

#Preview {
    CategoryView(category: .constant("전체"))
}

