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
        }
        .sheet(isPresented: $isPinAdd, content: {
            NavigationView {
                AddPinView(update: $update)
            }
            .presentationDragIndicator(.visible)
        })
    }
}

