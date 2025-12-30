//
//  MyLibraryView.swift
//  BookMind2
//
//  Created by Anvar Sultanov on 2025-09-09.
//

import Foundation
import SwiftUI

enum BookFilter: CaseIterable {
    case all, favorites, read, unread
    
    var title: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Favorites"
        case .read: return "Read"
        case .unread: return "Unread"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "books.vertical"
        case .favorites: return "heart.fill"
        case .read: return "checkmark.circle.fill"
        case .unread: return "book.closed"
        }
    }
}

struct MyLibraryView: View {
    @EnvironmentObject var bookDataManager: BookDataManager
    @State private var selectedFilter: BookFilter = .all
    
    private var filteredBooks: [Book] {
        let books = bookDataManager.books
        
        switch selectedFilter {
        case .all:
            return books
        case .favorites:
            return books.filter { $0.isFavorite }
        case .read:
            return books.filter { $0.isRead }
        case .unread:
            return books.filter { !$0.isRead }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with gradient
                headerView
                
                // Filter chips
                filterChipsView
                
                // Content
                if filteredBooks.isEmpty {
                    emptyStateView
                } else {
                    bookListView
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerView: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.3), .clear]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Library")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(bookDataManager.books.count) book\(bookDataManager.books.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                NavigationLink(destination: AddBookView()) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(12)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .frame(height: 100)
    }
    
    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(BookFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.title,
                        icon: filter.icon,
                        isSelected: selectedFilter == filter
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedFilter == .all ? "books.vertical" : selectedFilter.icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(emptyStateTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(emptyStateSubtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all: return "No Books Yet"
        case .favorites: return "No Favorites"
        case .read: return "No Books Read"
        case .unread: return "No Unread Books"
        }
    }
    
    private var emptyStateSubtitle: String {
        switch selectedFilter {
        case .all: return "Tap the + button to add your first book"
        case .favorites: return "Mark books as favorites by tapping the heart icon"
        case .read: return "Mark books as read by tapping the checkmark icon"
        case .unread: return "All your books have been marked as read!"
        }
    }
    
    private var bookListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredBooks) { book in
                    NavigationLink(destination: BookDetailView(book: book)) {
                        BookRowView(book: book)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .animation(.easeInOut(duration: 0.3), value: filteredBooks.count)
        }
    }
}

// Make BookFilter conform to Hashable for ForEach
extension BookFilter: Hashable {}
