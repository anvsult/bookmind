//
//  DataManager.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//

import Foundation
import SwiftUI
class BookDataManager: ObservableObject {
    @Published var books: [Book] = []
    
    private let userDefaults = UserDefaults.standard
    private let booksKey = "SavedBooks"
    
    init() {
        loadBooks()
    }
    
    func addBook(_ book: Book) {
        books.insert(book, at: 0) // Insert at beginning for reverse chronological order
        saveBooks()
    }
    
    func updateBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            saveBooks()
        }
    }
    
    
    func deleteBook(_ book: Book) {
        books.removeAll { $0.id == book.id }
        saveBooks()
    }
    
    func addNoteToBook(_ note: BookNote, to book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index].notes.append(note)
            saveBooks()
        }
    }
    
    func getDatesWithEntries() -> Set<DateComponents> {
        var dates = Set<DateComponents>()
        let calendar = Calendar.current
        
        for book in books {
            for note in book.notes {
                let components = calendar.dateComponents([.year, .month, .day], from: note.dateCreated)
                dates.insert(components)
                
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
            }
        }
        
        return dates
    }
    func deleteNoteFromBook(_ noteId: UUID, from book: Book) {
        if let bookIndex = books.firstIndex(where: { $0.id == book.id }) {
            books[bookIndex].notes.removeAll { $0.id == noteId }
            saveBooks()
        }
    }
    
    func updateNoteInBook(_ updatedNote: BookNote, in book: Book) {
        if let bookIndex = books.firstIndex(where: { $0.id == book.id }),
           let noteIndex = books[bookIndex].notes.firstIndex(where: { $0.id == updatedNote.id }) {
            books[bookIndex].notes[noteIndex] = updatedNote
            saveBooks()
        }
    }
    
//    func saveBooks() {
//        if let encoded = try? JSONEncoder().encode(books) {
//            userDefaults.set(encoded, forKey: booksKey)
//        }
//    }
    
//    private func loadBooks() {
//        if let data = userDefaults.data(forKey: booksKey),
//           let decoded = try? JSONDecoder().decode([Book].self, from: data) {
//            books = decoded
//        }
//    }
    
    func resetAllData() {
        books = []
        userDefaults.removeObject(forKey: booksKey)
    }
    
    
    func saveBooks() {
        let url = getBooksFileURL()
        do {
            let data = try JSONEncoder().encode(books)
            try data.write(to: url)
        } catch {
            print("❌ Failed to save books:", error)
        }
    }

    func loadBooks() {
        let url = getBooksFileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            books = try JSONDecoder().decode([Book].self, from: data)
        } catch {
            print("❌ Failed to load books:", error)
        }
    }

    private func getBooksFileURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("books.json")
    }
    
    
    
}
