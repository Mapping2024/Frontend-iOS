import SwiftUI
import MapKit

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
                            Text("Login")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                        .frame(width: 40, height: 40)
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
                 .padding(.top, -20)
        }
    }
}

#Preview {
    SearchBarView(update: .constant(false), selectedMemoId: .constant(nil), item: .constant([
        Item(id: 1, title: "테스트1", category: "Fruit", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), secret: false),
        Item(id: 2, title: "테스트2", category: "Fruit", location: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), secret: false),
        Item(id: 3, title: "테스트3", category: "Vegetable", location: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), secret: false)
    ]))
                .environmentObject(UserManager())
}
