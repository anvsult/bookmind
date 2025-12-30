//
//  Models.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//

import Foundation

struct Book: Identifiable, Codable {
    var id = UUID()
    var title: String
    var coverImageData: Data?
    var dateAdded: Date
    var notes: [BookNote]
    var isFavorite: Bool
    var isRead: Bool
    
    init(title: String, coverImageData: Data? = nil) {
        self.title = title
        self.coverImageData = coverImageData
        self.dateAdded = Date()
        self.notes = []
        self.isFavorite = false
        self.isRead = false
    }
}

struct BookNote: Identifiable, Codable {
    let id: UUID
    var page: Int
    var content: String
    var feeling: String
    var dateCreated: Date
    
    // Default initializer for new notes
    init(page: Int, content: String, feeling: String) {
        self.id = UUID()
        self.page = page
        self.content = content
        self.feeling = feeling
        self.dateCreated = Date()
    }
    
    // Custom initializer for editing existing notes (including date)
    init(id: UUID, page: Int, content: String, feeling: String, dateModified: Date) {
        self.id = id
        self.page = page
        self.content = content
        self.feeling = feeling
        self.dateCreated = dateModified
    }
}
