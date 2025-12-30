//
//  BookDetailView.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//
import SwiftUI
import Foundation

struct BookDetailView: View {
    @State var book: Book
    @EnvironmentObject var bookDataManager: BookDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddNote = false
    @State private var showingDeleteAlert = false
    @State private var selectedNote: BookNote?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Header with gradient
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.3), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                        
                        VStack(spacing: 12) {
                            // Title and buttons row
                            HStack {
                                Text(book.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                
                                Spacer()
                                
                                // Action buttons
                                HStack(spacing: 12) {
                                    // Favorite button
                                    Button(action: {
                                        book.isFavorite.toggle()
                                        bookDataManager.updateBook(book)
                                    }) {
                                        Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                                            .font(.title3)
                                            .foregroundColor(book.isFavorite ? .red : .gray)
                                            .frame(width: 32, height: 32)
                                    }
                                    
                                    // Read status button
                                    Button(action: {
                                        book.isRead.toggle()
                                        bookDataManager.updateBook(book)
                                    }) {
                                        Image(systemName: book.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                                            .font(.title3)
                                            .foregroundColor(book.isRead ? .green : .gray)
                                            .frame(width: 32, height: 32)
                                    }
                                    
                                    // Add note button
                                    Button(action: { showingAddNote = true }) {
                                        Image(systemName: "plus")
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                            .frame(width: 32, height: 32)
                                            .background(Color.blue.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            
                            // Status indicators
                            HStack(spacing: 16) {
                                if book.isFavorite {
                                    HStack(spacing: 4) {
                                        Image(systemName: "heart.fill")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                        Text("Favorite")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                if book.isRead {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                        Text("Read")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                            .frame(height: 16) // Fixed height to prevent layout shifts
                            .animation(.easeInOut(duration: 0.2), value: book.isFavorite)
                            .animation(.easeInOut(duration: 0.2), value: book.isRead)
                        }
                        .padding()
                    }
                    .frame(height: 100)
                    
                    // Notes list
                    if book.notes.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "note.text")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No Notes Yet")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Text("Tap + to add your first note")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(book.notes.sorted(by: { $0.dateCreated > $1.dateCreated })) { note in
                                    NoteRowView(note: note, onEdit: {
                                        selectedNote = note
                                    })
                                }
                            }
                            .padding()
                            .padding(.bottom, 80) // Add padding to prevent overlap with delete button
                        }
                    }
                }
                
                // Floating delete button in bottom right
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingDeleteAlert = true }) {
                            Image(systemName: "trash")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.red)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(book: $book)
            }
            .sheet(item: $selectedNote) { note in
                EditNoteView(book: $book, note: note)
            }
            .alert("Delete Book", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    bookDataManager.deleteBook(book)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete \"\(book.title)\" and all its notes? This action cannot be undone.")
            }
        }
    }
}
