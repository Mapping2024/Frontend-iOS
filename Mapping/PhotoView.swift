//
//  PhotoView.swift
//  Mapping
//
//  Created by 김민정 on 12/3/24.
//

import SwiftUI

struct PhotoView: View {
    let image: Image
    @Binding var isPresented: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            image
                .resizable()
                .scaledToFit()
                .padding()

            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(Color.black.opacity(0.7)))
                    .padding()
            }
        }
    }
}

//#Preview {
//    PhotoView()
//}
