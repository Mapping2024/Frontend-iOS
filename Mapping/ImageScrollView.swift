import SwiftUI

struct ImageScrollView: View {
    let images: [String]
    let onImageTap: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(images, id: \.self) { urlString in
                    if let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .onTapGesture {
                                        onImageTap(urlString)
                                    }
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 150, height: 150)
                        .clipped()
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.top)
        }
    }
}

