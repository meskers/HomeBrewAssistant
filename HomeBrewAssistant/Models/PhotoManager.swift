import SwiftUI
import UIKit
import PhotosUI
import AVFoundation

/// Manages photo capture, storage, and organization for brewing documentation
class PhotoManager: NSObject, ObservableObject {
    static let shared = PhotoManager()
    
    @Published var capturedImages: [BrewPhoto] = []
    @Published var showingImagePicker = false
    @Published var showingCamera = false
    @Published var selectedImage: UIImage?
    
    // Image caching
    private let imageCache = NSCache<NSString, UIImage>()
    private let thumbnailCache = NSCache<NSString, UIImage>()
    private let maxCacheSize = 50 * 1024 * 1024 // 50MB
    private let maxThumbnailSize = 10 * 1024 * 1024 // 10MB
    
    // File management
    private let fileManager = FileManager.default
    private var photosDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Photos", isDirectory: true)
    }
    private var thumbnailsDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PhotoThumbnails", isDirectory: true)
    }
    
    /// Photo source options
    enum PhotoSource {
        case camera
        case photoLibrary
    }
    
    /// Camera authorization status
    @Published var cameraAuthStatus: AVAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        setupDirectories()
        setupCache()
        checkCameraPermission()
        loadPhotos()
    }
    
    /// Setup photo directories
    private func setupDirectories() {
        try? fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: thumbnailsDirectory, withIntermediateDirectories: true)
    }
    
    /// Setup image caches
    private func setupCache() {
        imageCache.totalCostLimit = maxCacheSize
        thumbnailCache.totalCostLimit = maxThumbnailSize
        
        // Cleanup cache when memory warning received
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cleanupCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        // Schedule periodic cleanup of old cached files
        Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { [weak self] _ in
            Task.detached { [weak self] in
                await MainActor.run {
                    self?.cleanupOldCachedFiles()
                }
            }
        }
    }
    
    @objc private func cleanupCache() {
        imageCache.removeAllObjects()
        thumbnailCache.removeAllObjects()
    }
    
    /// Get image file URL
    private func imageFileURL(for id: UUID, thumbnail: Bool = false) -> URL {
        let directory = thumbnail ? thumbnailsDirectory : photosDirectory
        return directory.appendingPathComponent("\(id.uuidString).jpg")
    }
    
    /// Save image to disk
    private func saveImageToDisk(_ image: UIImage, for id: UUID, thumbnail: Bool = false) {
        let fileURL = imageFileURL(for: id, thumbnail: thumbnail)
        let quality: CGFloat = thumbnail ? 0.7 : 0.9
        
        if let data = image.jpegData(compressionQuality: quality) {
            try? data.write(to: fileURL)
        }
    }
    
    /// Load image from disk
    private func loadImageFromDisk(for id: UUID, thumbnail: Bool = false) -> UIImage? {
        let fileURL = imageFileURL(for: id, thumbnail: thumbnail)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    /// Get cached image with disk fallback
    func getCachedImage(for id: UUID, thumbnail: Bool = false) -> UIImage? {
        let cache = thumbnail ? thumbnailCache : imageCache
        
        // Check memory cache first
        if let cached = cache.object(forKey: id.uuidString as NSString) {
            return cached
        }
        
        // Try loading from disk
        if let diskImage = loadImageFromDisk(for: id, thumbnail: thumbnail) {
            cache.setObject(diskImage, forKey: id.uuidString as NSString)
            return diskImage
        }
        
        return nil
    }
    
    /// Cache image in memory and on disk
    func cacheImage(_ image: UIImage, for id: UUID, thumbnail: Bool = false) {
        let cache = thumbnail ? thumbnailCache : imageCache
        cache.setObject(image, forKey: id.uuidString as NSString)
        
        Task.detached(priority: .background) { [weak self] in
            self?.saveImageToDisk(image, for: id, thumbnail: thumbnail)
        }
    }
    
    /// Generate and cache thumbnail
    func generateThumbnail(from image: UIImage, for id: UUID) -> UIImage {
        if let cached = thumbnailCache.object(forKey: id.uuidString as NSString) {
            return cached
        }
        
        let size = CGSize(width: 300, height: 300)
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: rect)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let thumbnail = thumbnail {
            thumbnailCache.setObject(thumbnail, forKey: id.uuidString as NSString)
            return thumbnail
        }
        
        return image
    }
    
    /// Check camera permission status
    func checkCameraPermission() {
        cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    /// Request camera permission
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
    }
    
    /// Add a new photo with metadata
    func addPhoto(_ image: UIImage, for context: PhotoContext, description: String = "", location: String = "") {
        Task {
            // Compress image in background
            let compressedImage = await compressImage(image)
            
            let photo = BrewPhoto(
                image: compressedImage,
                context: context,
                description: description,
                location: location,
                timestamp: Date()
            )
            
            // Cache the image
            cacheImage(compressedImage, for: photo.id)
            let thumbnail = generateThumbnail(from: compressedImage, for: photo.id)
            cacheImage(thumbnail, for: photo.id, thumbnail: true)
            
            await MainActor.run {
                capturedImages.append(photo)
                savePhoto(photo)
            }
            
            print("📸 Added photo for \(context.rawValue): \(description)")
        }
    }
    
    /// Compress image to reasonable size
    private func compressImage(_ image: UIImage) async -> UIImage {
        let maxDimension: CGFloat = 1600 // Max dimension for photos
        let maxFileSize: Int = 1024 * 1024 // 1MB
        
        // Scale down if needed
        var processedImage = image
        if image.size.width > maxDimension || image.size.height > maxDimension {
            let scale = maxDimension / max(image.size.width, image.size.height)
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            if let scaledImage = UIGraphicsGetImageFromCurrentImageContext() {
                processedImage = scaledImage
            }
            UIGraphicsEndImageContext()
        }
        
        // Compress until file size is acceptable
        var compression: CGFloat = 0.8
        var imageData = processedImage.jpegData(compressionQuality: compression)
        
        while let data = imageData, data.count > maxFileSize && compression > 0.1 {
            compression -= 0.1
            imageData = processedImage.jpegData(compressionQuality: compression)
        }
        
        if let finalData = imageData,
           let finalImage = UIImage(data: finalData) {
            return finalImage
        }
        
        return processedImage
    }
    
    /// Save photo to local storage
    private func savePhoto(_ photo: BrewPhoto) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photoPath = documentsPath.appendingPathComponent("Photos")
        
        // Create photos directory if it doesn't exist
        try? FileManager.default.createDirectory(at: photoPath, withIntermediateDirectories: true)
        
        // Save image
        let filename = "\(photo.id.uuidString).jpg"
        let imageURL = photoPath.appendingPathComponent(filename)
        
        if let imageData = photo.image.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: imageURL)
        }
        
        // Save metadata
        savePhotosMetadata()
    }
    
    /// Load all photos from storage
    private func loadPhotos() {
        // Load from UserDefaults or Core Data in a real app
        // For now, start with empty array
        capturedImages = []
    }
    
    /// Save photos metadata to UserDefaults
    private func savePhotosMetadata() {
        // In a real app, you'd use Core Data or another persistent storage
        // For demo purposes, we'll keep them in memory
    }
    
    /// Get photos for specific context
    func getPhotos(for context: PhotoContext) -> [BrewPhoto] {
        return capturedImages.filter { $0.context == context }
    }
    
    /// Get photos for specific recipe
    func getPhotos(for recipeId: UUID) -> [BrewPhoto] {
        return capturedImages.filter { $0.recipeId == recipeId }
    }
    
    /// Delete photo and its cached images
    func deletePhoto(_ photo: BrewPhoto) {
        // Remove from memory cache
        imageCache.removeObject(forKey: photo.id.uuidString as NSString)
        thumbnailCache.removeObject(forKey: photo.id.uuidString as NSString)
        
        // Remove from disk
        try? fileManager.removeItem(at: imageFileURL(for: photo.id))
        try? fileManager.removeItem(at: imageFileURL(for: photo.id, thumbnail: true))
        
        // Remove from array
        capturedImages.removeAll { $0.id == photo.id }
        
        print("🗑️ Deleted photo: \(photo.description)")
    }
    
    /// Cleanup old cached files
    private func cleanupOldCachedFiles() {
        let calendar = Calendar.current
        let oldDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let urls = try? fileManager.contentsOfDirectory(
            at: thumbnailsDirectory,
            includingPropertiesForKeys: [.creationDateKey],
            options: .skipsHiddenFiles
        )
        
        urls?.forEach { url in
            guard let attributes = try? fileManager.attributesOfItem(atPath: url.path),
                  let creationDate = attributes[.creationDate] as? Date,
                  creationDate < oldDate else { return }
            
            try? fileManager.removeItem(at: url)
        }
    }
}

/// Photo context for organization
enum PhotoContext: String, CaseIterable {
    case recipe = "recipe"
    case ingredients = "ingredients"
    case grainBill = "grain_bill"
    case mashing = "mashing"
    case boiling = "boiling"
    case fermentation = "fermentation"
    case conditioning = "conditioning"
    case finalProduct = "final_product"
    case equipment = "equipment"
    case process = "process"
    
    var displayName: String {
        switch self {
        case .recipe: return "Recipe"
        case .ingredients: return "Ingredients"
        case .grainBill: return "Grain Bill"
        case .mashing: return "Mashing"
        case .boiling: return "Boiling"
        case .fermentation: return "Fermentation"
        case .conditioning: return "Conditioning"
        case .finalProduct: return "Final Product"
        case .equipment: return "Equipment"
        case .process: return "Process"
        }
    }
    
    var icon: String {
        switch self {
        case .recipe: return "book"
        case .ingredients: return "list.bullet"
        case .grainBill: return "leaf"
        case .mashing: return "thermometer"
        case .boiling: return "flame"
        case .fermentation: return "drop.fill"
        case .conditioning: return "hourglass"
        case .finalProduct: return "wineglass"
        case .equipment: return "wrench.and.screwdriver"
        case .process: return "gearshape"
        }
    }
}

/// Photo model for brewing documentation
struct BrewPhoto: Identifiable {
    let id = UUID()
    let image: UIImage
    let context: PhotoContext
    let description: String
    let location: String
    let timestamp: Date
    var recipeId: UUID?
    var brewingSessionId: UUID?
    
    /// Formatted timestamp for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

/// Camera view wrapper for UIKit integration
struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

/// Photo library picker view
struct PhotoLibraryView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryView
        
        init(_ parent: PhotoLibraryView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first else {
                parent.presentationMode.wrappedValue.dismiss()
                return
            }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    if let uiImage = image as? UIImage {
                        self.parent.selectedImage = uiImage
                    }
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
} 