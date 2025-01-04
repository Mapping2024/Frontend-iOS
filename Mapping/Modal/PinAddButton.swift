import SwiftUI

struct PinAddButton: View {
    @State private var isPinAdd = false
    @Binding var update: Bool
    
    var body: some View {
        Button(action:{isPinAdd.toggle()}){
            HStack{
                Image(systemName: "mappin.and.ellipse")
                Text("핀 생성")
                    .font(.caption)
            }
            .padding(10)
            .background(Color.cYellow) // 원하는 백그라운드 색상 지정
            .cornerRadius(8)// 백그라운드에 모서리 곡선 적용
            .foregroundStyle(Color.cWhite)
        }
        .sheet(isPresented: $isPinAdd, content: {
            NavigationView {
                AddPinView(update: $update)
            }
            .presentationDragIndicator(.visible)
        })
    }
}

