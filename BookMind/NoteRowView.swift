import Foundation
//
//  NoteRowView.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//
import SwiftUI

struct NoteRowView: View {
    let note: BookNote
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Page \(note.page)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
                
                Spacer()
                
                VStack {
                    
                    Text(note.dateCreated, formatter: dateFormatter)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if !note.feeling.isEmpty {
                        Text("Feeling: \(note.feeling)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                }
            }
            HStack {
                Text(note.content)
                    .font(.body)
                    .foregroundColor(.primary)
                
                
                
                Spacer()
                // Edit button
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()
