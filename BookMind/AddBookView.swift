import SwiftUI
import PhotosUI

struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var bookDataManager: BookDataManager
    
    @State private var bookTitle = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var coverImageData: Data?
    @State private var showValidationError = false
    @State private var showCamera = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Book Title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Book Title")
                        .font(.headline)
                    
                    TextField("Enter book title", text: $bookTitle)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(showValidationError && bookTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Color.red : Color.clear, lineWidth: 1)
                        )
                    
                    if showValidationError && bookTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Please enter a book title.")
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                }
                
                // MARK: - Book Cover
                VStack(alignment: .leading, spacing: 8) {
                    Text("Book Cover")
                        .font(.headline)
                    
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            if let imageData = coverImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            } else {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray5))
                                    .frame(width: 150, height: 220)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "book.closed")
                                                .font(.system(size: 32))
                                                .foregroundColor(.gray)
                                            Text("No Cover")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            
                            HStack(spacing: 16) {
                                PhotosPicker(selection: $selectedImage, matching: .images) {
                                    VStack(spacing: 6) {
                                        Image(systemName: "photo.on.rectangle")
                                            .font(.system(size: 24))
                                        Text("Gallery")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.blue)
                                    .frame(width: 80, height: 80)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                
                                Button(action: {
                                    showCamera = true
                                }) {
                                    VStack(spacing: 6) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 24))
                                        Text("Camera")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.blue)
                                    .frame(width: 80, height: 80)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                // MARK: - Add Book Button
                Button(action: {
                    let trimmedTitle = bookTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if trimmedTitle.isEmpty {
                        showValidationError = true
                    } else {
                        let newBook = Book(title: trimmedTitle, coverImageData: coverImageData)
                        bookDataManager.addBook(newBook)
                        dismiss()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Add Book to Library")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(bookTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.blue)
                    )
                }
                .disabled(bookTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                .animation(.easeInOut(duration: 0.2), value: bookTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationTitle("Add Book")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedImage) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    coverImageData = data
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                if let image = image, let data = image.jpegData(compressionQuality: 0.9) {
                    coverImageData = data
                }
                showCamera = false
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - CameraPicker
struct CameraPicker: UIViewControllerRepresentable {
    var completion: (UIImage?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            parent.completion(image)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
        }
    }
}
