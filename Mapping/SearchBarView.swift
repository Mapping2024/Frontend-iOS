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
    @Binding var category: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $query)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onSubmit {
                    // code fired when you return in TextField
                }
            Spacer()
            
            Button(action: {isMyInfo.toggle()}) {
                ProfileImageView()
                    .frame(width: 40, height: 40)
            }
            .padding(.trailing)
            .sheet(isPresented: $isMyInfo, content: {
                NavigationView {
                    MyInfoView()
                }
                .presentationDragIndicator(.visible)
            })
        }
        .padding(.top)
        CategoryView(category: $category)
        Spacer()
    }
}

//#Preview {
//    SearchBarView(query: .constant("init"), isMyInfo: .constant(false))
//}
