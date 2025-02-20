import SwiftUI

struct MemoHeaderView: View {
    let detail: MemoDetail

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(detail.title)
                    .font(.title2)
                    .fontWeight(.bold)
                if let datePart = detail.date.split(separator: ":").first {
                    HStack {
                        Text(datePart)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        if detail.certified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Spacer()
            ProfileImageView(imageURL: detail.profileImage)
                .frame(width: 35, height: 35)
            Text("\(detail.nickname)")
                .font(.subheadline)
        }
    }
}
