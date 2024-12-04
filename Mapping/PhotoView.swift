//
//  PhotoView.swift
//  Mapping
//
//  Created by 김민정 on 12/3/24.
//

import SwiftUI

struct PhotoView: View {
    let imageURL: String
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            VStack {
                if let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Text("유효하지 않은 URL입니다.")
                        .foregroundColor(.red)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action:{isPresented.toggle()}) {
                        Image(systemName: "xmark.circle")
                    }
                }
            }
        }
    }
}
