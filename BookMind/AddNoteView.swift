//
//  AddNoteView.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//

import SwiftUI

struct AddNoteView: View {
    @Binding var book: Book
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var bookDataManager: BookDataManager
    
    @State private var pageNumber = ""
    @State private var noteContent = ""
    @State private var selectedFeeling = ""
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    private let feelings = ["😊", "😢", "😡", "😍", "🤔", "😴", "😱", "🤯", "😌", "🥰", "😤", "🤓", "😎", "🙄", "😳"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Page number input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Page Number")
                            .font(.headline)
                        
                        TextField("Enter page", text: $pageNumber)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        
                        if let page = Int(pageNumber), page <= 0 {
                            Text("Page number must be greater than 0")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Note input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Note")
                            .font(.headline)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $noteContent)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            
                            if noteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Write your thoughts here...")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                            }
                        }
                        
                        if noteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Note content is required")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Feelings picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How did this make you feel?")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(feelings, id: \.self) { feeling in
                                Button {
                                    selectedFeeling = feeling
                                } label: {
                                    Text(feeling)
                                        .font(.title2)
                                        .frame(width: 48, height: 48)
                                        .background(
                                            selectedFeeling == feeling ?
                                            Color.blue.opacity(0.15) : Color.gray.opacity(0.1)
                                        )
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(
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
                                Text("Selected: \(selectedFeeling)")
                                    .font(.subheadline)
                                Spacer()
                                Button("Clear") {
                                    selectedFeeling = ""
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Add Note")
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
        
        // Check if page already has a note
        if book.notes.contains(where: { $0.page == page }) {
            validationMessage = "A note for page \(page) already exists. Please choose a different page number."
            showingValidationAlert = true
            return
        }
        
        let newNote = BookNote(page: page, content: trimmedContent, feeling: selectedFeeling)
        bookDataManager.addNoteToBook(newNote, to: book)
        book.notes.append(newNote)
        dismiss()
    }
}
