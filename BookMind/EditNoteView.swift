//
//  EditNoteView.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//


import Foundation
import SwiftUI

import Foundation
import SwiftUI

struct EditNoteView: View {
    @Binding var book: Book
    let note: BookNote
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var bookDataManager: BookDataManager
    
    @State private var pageNumber: String
    @State private var noteContent: String
    @State private var selectedFeeling: String
    @State private var noteDate: Date
    @State private var showingDeleteAlert = false
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    private let feelings = ["😊", "😢", "😡", "😍", "🤔", "😴", "😱", "🤯", "😌", "🥰", "😤", "🤓", "😎", "🙄", "😳"]
    
    init(book: Binding<Book>, note: BookNote) {
        self._book = book
        self.note = note
        self._pageNumber = State(initialValue: "\(note.page)")
        self._noteContent = State(initialValue: note.content)
        self._selectedFeeling = State(initialValue: note.feeling)
        self._noteDate = State(initialValue: note.dateCreated)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Note Details") {
                    HStack {
                        Text("Page")
                        TextField("Page number", text: $pageNumber)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    DatePicker("Date", selection: $noteDate, displayedComponents: [.date])
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                        TextEditor(text: $noteContent)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        if noteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Please enter your note content")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How did this make you feel?")
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                            ForEach(feelings, id: \.self) { feeling in
                                Button(action: {
                                    selectedFeeling = feeling
                                }) {
                                    Text(feeling)
                                        .font(.title2)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            selectedFeeling == feeling ?
                                            Color.blue.opacity(0.2) : Color.gray.opacity(0.1)
                                        )
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    selectedFeeling == feeling ?
                                                    Color.blue : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        if !selectedFeeling.isEmpty {
                            HStack {
                                Text("Selected:")
                                Text(selectedFeeling)
                                    .font(.title3)
                                Spacer()
                                Button("Clear") {
                                    selectedFeeling = ""
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Delete Note", role: .destructive) {
                        showingDeleteAlert = true
                    }
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(!isValidInput())
                }
            }
            .alert("Delete Note", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteNote()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this note? This action cannot be undone.")
            }
            .alert("Invalid Input", isPresented: $showingValidationAlert) {
                Button("OK") { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    private func isValidInput() -> Bool {
        let trimmedContent = noteContent.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPage = pageNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !trimmedPage.isEmpty &&
               !trimmedContent.isEmpty &&
               Int(trimmedPage) != nil &&
               Int(trimmedPage)! > 0
    }
    
    private func saveNote() {
        let trimmedContent = noteContent.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPage = pageNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate page number
        guard let page = Int(trimmedPage), page > 0 else {
            validationMessage = "Please enter a valid page number greater than 0"
            showingValidationAlert = true
            return
        }
        
        // Validate content
        guard !trimmedContent.isEmpty else {
            validationMessage = "Please enter note content"
            showingValidationAlert = true
            return
        }
        
        // Check if page already has a note (excluding current note)
        if book.notes.contains(where: { $0.page == page && $0.id != note.id }) {
            validationMessage = "A note for page \(page) already exists. Please choose a different page number."
            showingValidationAlert = true
            return
        }
        
        updateNote(page: page, content: trimmedContent, feeling: selectedFeeling, date: noteDate)
        dismiss()
    }
    
    private func updateNote(page: Int, content: String, feeling: String, date: Date) {
        let updatedNote = BookNote(
            id: note.id,
            page: page,
            content: content,
            feeling: feeling,
            dateModified: date
        )
        
        if let bookIndex = bookDataManager.books.firstIndex(where: { $0.id == book.id }),
           let noteIndex = bookDataManager.books[bookIndex].notes.firstIndex(where: { $0.id == note.id }) {
            
            bookDataManager.books[bookIndex].notes[noteIndex] = updatedNote
            bookDataManager.saveBooks()
            
            if let localNoteIndex = book.notes.firstIndex(where: { $0.id == note.id }) {
                book.notes[localNoteIndex] = updatedNote
            }
        }
    }
    
    private func deleteNote() {
        bookDataManager.deleteNoteFromBook(note.id, from: book)
        book.notes.removeAll { $0.id == note.id }
    }
}
