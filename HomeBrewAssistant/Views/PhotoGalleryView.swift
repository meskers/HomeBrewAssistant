import SwiftUI

/// Photo gallery view for displaying and managing brewing photos
struct PhotoGalleryView: View {
    @ObservedObject private var photoManager = PhotoManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedContext: PhotoContext = .recipe
    @State private var showingAddPhoto = false
    @State private var showingPhotoDetail: BrewPhoto?
    @State private var selectedImage: UIImage?
    @State private var photoDescription = ""
    @State private var showingImageSource = false
    
    let recipeId: UUID?
    
    init(recipeId: UUID? = nil) {
        self.recipeId = recipeId
    }
    
    var filteredPhotos: [BrewPhoto] {
        if let recipeId = recipeId {
            return photoManager.getPhotos(for: recipeId)
        } else {
            return photoManager.getPhotos(for: selectedContext)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Context filter (if not recipe-specific)
                if recipeId == nil {
                    contextFilterSection
                }
                
                // Photo grid
                photoGridSection
            }
            .navigationTitle("photo.gallery.title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingImageSource = true
                    }) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.brewTheme)
                    }
                }
            }
        }
        .confirmationDialog("photo.source.title".localized, isPresented: $showingImageSource) {
            Button("photo.source.camera".localized) {
                if photoManager.cameraAuthStatus == .authorized {
                    showingAddPhoto = true
                } else {
                    photoManager.requestCameraPermission()
                }
            }
            
            Button("photo.source.library".localized) {
                // Show photo library picker
                showPhotoLibraryPicker()
            }
            
            Button("action.cancel".localized, role: .cancel) { }
        }
        .sheet(isPresented: $showingAddPhoto) {
            AddPhotoView(context: selectedContext, recipeId: recipeId)
        }
        .sheet(item: $showingPhotoDetail) { photo in
            PhotoDetailView(photo: photo)
        }
        .onChange(of: selectedImage) { _, image in
            if let image = image {
                addPhotoWithImage(image)
                selectedImage = nil
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "photo.stack")
                    .font(.system(size: 24))
                    .foregroundColor(.brewTheme)
                
                VStack(alignment: .leading) {
                    Text("photo.gallery.title".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("photo.gallery.subtitle".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                                        Text("photo.gallery.count".localized(with: filteredPhotos.count))
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.primaryCard)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var contextFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PhotoContext.allCases, id: \.self) { context in
                    ContextFilterButton(
                        context: context,
                        isSelected: selectedContext == context,
                        action: {
                            selectedContext = context
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var photoGridSection: some View {
        ScrollView {
            if filteredPhotos.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(filteredPhotos) { photo in
                        PhotoThumbnailView(photo: photo) {
                            showingPhotoDetail = photo
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("photo.gallery.empty.title".localized)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("photo.gallery.empty.message".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("photo.add.first".localized) {
                showingImageSource = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func showPhotoLibraryPicker() {
        // This would typically show a photo library picker
        // For now, we'll just trigger the add photo sheet
        showingAddPhoto = true
    }
    
    private func addPhotoWithImage(_ image: UIImage) {
        photoManager.addPhoto(
            image,
            for: selectedContext,
            description: photoDescription.isEmpty ? selectedContext.displayName : photoDescription
        )
        photoDescription = ""
    }
}

/// Context filter button for photo gallery
struct ContextFilterButton: View {
    let context: PhotoContext
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: context.icon)
                    .font(.caption)
                
                Text(context.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.brewTheme : Color.primaryCard)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Photo thumbnail view for grid display
struct PhotoThumbnailView: View {
    let photo: BrewPhoto
    let action: () -> Void
    
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Photo with loading state
                ZStack {
                    if let image = loadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 120)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            )
                    }
                }
                
                // Info overlay
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: photo.context.icon)
                            .font(.caption2)
                            .foregroundColor(.brewTheme)
                        
                        Text(photo.context.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                    
                    if !photo.description.isEmpty {
                        Text(photo.description)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Text(photo.formattedDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color(.systemBackground))
            }
        }
        .background(Color.primaryCard)
        .cornerRadius(12)
        .shadow(radius: 2)
        .buttonStyle(PlainButtonStyle())
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        // Try to load from cache first
        if let cached = PhotoManager.shared.getCachedImage(for: photo.id, thumbnail: true) {
            loadedImage = cached
            isLoading = false
            return
        }
        
        // Load and generate thumbnail in background
        await Task.detached(priority: .background) {
            let thumbnail = PhotoManager.shared.generateThumbnail(from: photo.image, for: photo.id)
            
            await MainActor.run {
                loadedImage = thumbnail
                isLoading = false
            }
        }.value
    }
}

/// Add photo view with context and description
struct AddPhotoView: View {
    @ObservedObject private var photoManager = PhotoManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let context: PhotoContext
    let recipeId: UUID?
    
    @State private var selectedImage: UIImage?
    @State private var photoDescription = ""
    @State private var photoLocation = ""
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: context.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.brewTheme)
                    
                    Text("photo.add.for".localized(with: context.displayName))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Image preview or placeholder
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(height: 200)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                
                                Text("photo.select.prompt".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
                
                // Photo source buttons
                HStack(spacing: 16) {
                    Button("photo.source.camera".localized) {
                        showingCamera = true
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("photo.source.library".localized) {
                        showingPhotoLibrary = true
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
                
                // Description and location
                VStack(alignment: .leading, spacing: 12) {
                    Text("photo.details".localized)
                        .font(.headline)
                    
                    TextField("photo.description.placeholder".localized, text: $photoDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("photo.location.placeholder".localized, text: $photoLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
                
                // Save button
                Button("photo.save".localized) {
                    savePhoto()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedImage == nil)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .navigationTitle("photo.add.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("action.cancel".localized) {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            PhotoLibraryView(selectedImage: $selectedImage)
        }
    }
    
    private func savePhoto() {
        guard let image = selectedImage else { return }
        
        var photo = BrewPhoto(
            image: image,
            context: context,
            description: photoDescription.isEmpty ? context.displayName : photoDescription,
            location: photoLocation,
            timestamp: Date()
        )
        
        // Set recipe ID if available
        if let recipeId = recipeId {
            photo.recipeId = recipeId
        }
        
        photoManager.addPhoto(
            image,
            for: context,
            description: photo.description,
            location: photoLocation
        )
        
        dismiss()
    }
}

/// Photo detail view for full-screen viewing and editing
struct PhotoDetailView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let photo: BrewPhoto
    @State private var showingDeleteAlert = false
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Full-size photo with loading state
                    ZStack {
                        if let image = loadedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                        } else {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(1.5)
                                )
                        }
                    }
                    
                    // Photo details
                    VStack(alignment: .leading, spacing: 16) {
                        // Context and date
                        HStack {
                            Label(photo.context.displayName, systemImage: photo.context.icon)
                                .font(.headline)
                                .foregroundColor(.brewTheme)
                            
                            Spacer()
                            
                            Text(photo.formattedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Description
                        if !photo.description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("photo.description".localized)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text(photo.description)
                                    .font(.body)
                            }
                        }
                        
                        // Location
                        if !photo.location.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("photo.location".localized)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text(photo.location)
                                    .font(.body)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.primaryCard)
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("photo.detail.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("action.close".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("action.delete".localized) {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .alert("photo.delete.confirm".localized, isPresented: $showingDeleteAlert) {
            Button("action.delete".localized, role: .destructive) {
                PhotoManager.shared.deletePhoto(photo)
                dismiss()
            }
            Button("action.cancel".localized, role: .cancel) { }
        } message: {
            Text("photo.delete.message".localized)
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        // Try to load from cache first
        if let cached = PhotoManager.shared.getCachedImage(for: photo.id) {
            loadedImage = cached
            isLoading = false
            return
        }
        
        // Load thumbnail first for quick display
        if let thumbnail = PhotoManager.shared.getCachedImage(for: photo.id, thumbnail: true) {
            loadedImage = thumbnail
        }
        
        // Load full resolution image in background
        await Task.detached(priority: .background) {
            let fullImage = photo.image
            PhotoManager.shared.cacheImage(fullImage, for: photo.id)
            
            await MainActor.run {
                loadedImage = fullImage
                isLoading = false
            }
        }.value
    }
} 