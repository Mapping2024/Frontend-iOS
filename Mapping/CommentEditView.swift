//
//  CommentEditView.swift
//  Mapping
//
//  Created by 김민정 on 12/17/24.
//

import SwiftUI

struct CommentEditView: View {
    @State private var updatedCommentText: String = "" // 수정할 댓글 내용
    @State private var updatedRating: Int = 1 // 수정할 별점
    
    var body: some View {
        // 수정 모드 UI
        VStack(alignment: .leading, spacing: 8) {
            TextField("댓글 내용", text: $updatedCommentText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Text("별점: \(updatedRating)")
                Stepper("", value: $updatedRating, in: 1...5)
                    .labelsHidden()
            }
            
            HStack {
                Button("취소") {
                    editingCommentId = nil // 수정 모드 종료
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("저장") {
                    updateComment(id: comment.id)
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    CommentEditView()
}
