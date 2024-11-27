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
            Text("핀 추가하기")
                .padding(7)
                .background(Color.blue) // 원하는 백그라운드 색상 지정
                .cornerRadius(10)// 백그라운드에 모서리 곡선 적용
                .foregroundStyle(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
        }
        .sheet(isPresented: $isPinAdd, content: {
            NavigationView {
                AddPinView(update: $update)
            }
            .presentationDragIndicator(.visible)
        })
    }
}

