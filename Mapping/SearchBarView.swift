//
//  SearchBarView.swift
//  Mapping
//
//  Created by 김민정 on 11/22/24.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var query: String
    @Binding var isMyInfo: Bool
    
    var body: some View {
        HStack {
            Spacer()
            TextField("Search", text: $query)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    // code fired when you return in TextField
                }
            Spacer()
            
            Button(action: {isMyInfo.toggle()}) {
                ProfileImageView()
                    .frame(width: 40, height: 40)
            }
            .sheet(isPresented: $isMyInfo, content: {
                NavigationStack {
                    MyInfoView()
                }
                .presentationDragIndicator(.visible)
            })
            Spacer()
        }
    }
}


#Preview {
    SearchBarView(query: .constant("Coffe"), isMyInfo: .constant (false)).environmentObject(UserManager())
}
