import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var category: String
    @Binding var update: Bool
    let CategoryOptions: [(String, String)] = [
        ("전체", "mappin"),
        ("개인","person.fill"),
        ("흡연장", "smoke.fill"),
        ("쓰레기통", "trash.fill"),
        ("공용 화장실", "toilet.fill"),
        //("붕어빵","fish.fill"),
        ("기타", "star.fill")
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center) {
                Spacer()
                if userManager.isLoggedIn && userManager.userInfo != nil {
                    PinAddButton( update: $update)
                }
                ForEach(CategoryOptions, id: \.0) { key, value in
                    if (key == "개인") {
                       if userManager.isLoggedIn && userManager.userInfo != nil {
                           Button(action: {
                               category = key
                           }, label: {
                               HStack {
                                   Image(systemName: value)
                                       .font(.caption)
                                   Text(key)
                                       .font(.caption)
                               }
                               .padding(10)
                               .background(category == key ? Color.cBlue : Color.gray)
                               .cornerRadius(8)
                               .foregroundStyle(Color.cWhite)
                           })
                        }
                    } else {
                        Button(action: {
                            category = key
                        }, label: {
                            HStack {
                                Image(systemName: value)
                                    .font(.caption)
                                if key == "공용 화장실" {
                                    Text("화장실").font(.caption)
                                } else {
                                    Text(key).font(.caption)
                                }
                            }
                            .padding(10)
                            .background(category == key ? Color.cBlue : Color.gray)
                            .cornerRadius(8)
                            .foregroundStyle(Color.cWhite)
                        })
                    }
                }
                Spacer()
            }
        }
        Spacer()
    }
}

#Preview {
    CategoryView(category: .constant("전체"), update: .constant(false))
        .environmentObject(UserManager())
}

