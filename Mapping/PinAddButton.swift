//
//  PinAddButton.swift
//  Mapping
//
//  Created by 김민정 on 11/23/24.
//

import SwiftUI

struct PinAddButton: View {
    @Binding var isPinAdd: Bool
    @Binding var update: Bool
    
    var body: some View {
        Button(action:{isPinAdd.toggle()}){
            HStack{
                Image(systemName: "mappin.and.ellipse")
                Text("핀 생성")
                    .font(.caption)
            }
            .padding(10)
            .background(Color.yellow) // 원하는 백그라운드 색상 지정
            .cornerRadius(8)// 백그라운드에 모서리 곡선 적용
            .foregroundStyle(.white)
        }
        .sheet(isPresented: $isPinAdd, content: {
            NavigationView {
                AddPinView(update: $update)
            }
            .presentationDragIndicator(.visible)
        })
    }
}

