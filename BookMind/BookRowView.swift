//
//  BookRowView.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//

import Foundation

import SwiftUI
struct BookRowView: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 15) {
            // Book cover
            Group {
                if let imageData = book.coverImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "book.closed")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            }
            .frame(width: 60, height: 80)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text("Added \(book.dateAdded, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text((book.notes.count) == 1 ? "1 note" : "\(book.notes.count) notes")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()
