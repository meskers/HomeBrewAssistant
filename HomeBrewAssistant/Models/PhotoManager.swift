import Foundation
import SwiftUI
import Photos

// MARK: - Photo Context Enum
enum PhotoContext: String, CaseIterable, Codable {
    case recipe = "recipe"
    case mashing = "mashing"
    case boiling = "boiling"
    case fermentation = "fermentation"
    case packaging = "packaging"
    case finished = "finished"
    case ingredients = "ingredients"
    case equipment = "equipment"
    
    var displayName: String {
        switch self {
        case .recipe: return "📖 Recept"
        case .mashing: return "🌾 Maischen"
        case .boiling: return "🔥 Koken"
        case .fermentation: return "🍺 Fermentatie"
        case .packaging: return "📦 Verpakking"
        case .finished: return "✅ Afgewerkt"
        case .ingredients: return "🥜 Ingrediënten"
        case .equipment: return "⚙️ Apparatuur"
        }
    }
    
    var icon: String {
        switch self {
        case .recipe: return "book.fill"
        case .mashing: return "leaf.fill"
        case .boiling: return "flame.fill"
        case .fermentation: return "drop.circle.fill"
        case .packaging: return "shippingbox.fill"
        case .finished: return "checkmark.circle.fill"
        case .ingredients: return "takeoutbag.and.cup.and.straw.fill"
        case .equipment: return "wrench.and.screwdriver.fill"
        }
    }
}

// MARK: - BrewPhoto Model
struct BrewPhoto: Identifiable, Codable {
    let id: UUID
    var description: String
    var brewStage: String
    var context: PhotoContext
    var timestamp: Date
    var recipeId: UUID?
    var imagePath: String
    var thumbnailPath: String?
    var isFavorite: Bool
    
    init(id: UUID = UUID(), description: String, brewStage: String, context: PhotoContext, timestamp: Date = Date(), recipeId: UUID? = nil, imagePath: String, thumbnailPath: String? = nil, isFavorite: Bool = false) {
        self.id = id
        self.description = description
        self.brewStage = brewStage
        self.context = context
        self.timestamp = timestamp
        self.recipeId = recipeId
        self.imagePath = imagePath
        self.thumbnailPath = thumbnailPath
        self.isFavorite = isFavorite
    }
    
    var image: UIImage {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: imagePath)),
           let image = UIImage(data: data) {
            return image
        }
        return UIImage(systemName: "photo") ?? UIImage()
    }

}

// MARK: - PhotoManager Class
class PhotoManager: ObservableObject {
    static let shared = PhotoManager()
    
    @Published var capturedImages: [BrewPhoto] = []
    @Published var cameraAuthStatus: PHAuthorizationStatus = .notDetermined
    
    private let userDefaults = UserDefaults.standard
    private let photosKey = "captured_photos"
    private let fileManager = FileManager.default
    
    private var photosDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("Photos")
    }
    
    private var thumbnailsDirectory: URL {
        let cachesPath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cachesPath.appendingPathComponent("PhotoThumbnails")
    }
    
    private init() {
        createDirectoriesIfNeeded()
        loadPhotos()
        checkCameraPermission()
    }
    
    // MARK: - Directory Management
    private func createDirectoriesIfNeeded() {
        try? fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: thumbnailsDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Photo Management
    func addPhoto(_ image: UIImage, description: String, context: PhotoContext, brewStage: String = "", recipeId: UUID? = nil) {
        let photoId = UUID()
        let imagePath = photosDirectory.appendingPathComponent("\(photoId).jpg").path
        
        // Save full image
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: URL(fileURLWithPath: imagePath))
        }
        
        // Generate and save thumbnail
        let thumbnail = generateThumbnail(from: image, for: photoId)
        let thumbnailPath = thumbnailsDirectory.appendingPathComponent("\(photoId)_thumb.jpg").path
        if let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) {
            try? thumbnailData.write(to: URL(fileURLWithPath: thumbnailPath))
        }
        
        let brewPhoto = BrewPhoto(
            id: photoId,
            description: description,
            brewStage: brewStage,
            context: context,
            timestamp: Date(),
            recipeId: recipeId,
            imagePath: imagePath,
            thumbnailPath: thumbnailPath
        )
        
        capturedImages.append(brewPhoto)
        savePhotos()
    }
    
    func deletePhoto(_ photo: BrewPhoto) {
        // Remove from array
        capturedImages.removeAll { $0.id == photo.id }
        
        // Delete files
        try? fileManager.removeItem(atPath: photo.imagePath)
        if let thumbnailPath = photo.thumbnailPath {
            try? fileManager.removeItem(atPath: thumbnailPath)
        }
        
        savePhotos()
    }
    
    func savePhoto(_ photo: BrewPhoto) {
        if let index = capturedImages.firstIndex(where: { $0.id == photo.id }) {
            capturedImages[index] = photo
            savePhotos()
        }
    }
    
    // MARK: - Photo Retrieval
    func getPhotos(for context: PhotoContext) -> [BrewPhoto] {
        return capturedImages.filter { $0.context == context }
    }
    
    func getPhotos(for recipeId: UUID) -> [BrewPhoto] {
        return capturedImages.filter { $0.recipeId == recipeId }
    }
    
    // MARK: - Thumbnail Generation
    func generateThumbnail(from image: UIImage, for photoId: UUID) -> UIImage {
        let size = CGSize(width: 150, height: 150)
        return image.resized(to: size) ?? image
    }
    
    // MARK: - Caching
    func getCachedImage(for photoId: UUID, thumbnail: Bool = false) -> UIImage? {
        let directory = thumbnail ? thumbnailsDirectory : photosDirectory
        let filename = thumbnail ? "\(photoId)_thumb.jpg" : "\(photoId).jpg"
        let path = directory.appendingPathComponent(filename).path
        
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func cacheImage(_ image: UIImage, for photoId: UUID) {
        // This method is for compatibility - images are already saved to disk
    }
    
    // MARK: - Camera Permissions
    func requestCameraPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.cameraAuthStatus = status
            }
        }
    }
    
    private func checkCameraPermission() {
        cameraAuthStatus = PHPhotoLibrary.authorizationStatus()
    }
    
    // MARK: - Persistence
    private func savePhotos() {
        if let encoded = try? JSONEncoder().encode(capturedImages) {
            userDefaults.set(encoded, forKey: photosKey)
        }
    }
    
    private func loadPhotos() {
        if let data = userDefaults.data(forKey: photosKey),
           let decoded = try? JSONDecoder().decode([BrewPhoto].self, from: data) {
            capturedImages = decoded
        }
    }
}

// MARK: - Enhanced Photo Management Extensions
extension PhotoManager {
    /// Get recent photos from the last N days
    func getRecentPhotos(days: Int = 7) -> [BrewPhoto] {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        return capturedImages.filter { $0.timestamp >= cutoffDate }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    /// Get favorite photos
    func getFavoritePhotos() -> [BrewPhoto] {
        return capturedImages.filter { $0.isFavorite }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    /// Toggle favorite status of a photo
    func toggleFavorite(for photo: BrewPhoto) {
        if let index = capturedImages.firstIndex(where: { $0.id == photo.id }) {
            capturedImages[index].isFavorite.toggle()
            savePhoto(capturedImages[index])
        }
    }
    
    /// Get photos by context
    func getPhotosForContext(_ context: PhotoContext) -> [BrewPhoto] {
        return capturedImages.filter { $0.context == context }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    /// Get photo statistics
    func getPhotoStats() -> PhotoStats {
        return PhotoStats(
            totalPhotos: capturedImages.count,
            recentPhotos: getRecentPhotos().count,
            favoritePhotos: getFavoritePhotos().count,
            recipePhotos: getPhotos(for: .recipe).count,
            brewingPhotos: getPhotosForContext(.mashing).count + getPhotosForContext(.boiling).count
        )
    }
}

// MARK: - Photo Sorting Options
enum PhotoSortOption: String, CaseIterable {
    case dateNewest = "date_newest"
    case dateOldest = "date_oldest"
    case nameAZ = "name_az" 
    case nameZA = "name_za"
    case favorites = "favorites"
    case context = "context"
    
    var displayName: String {
        switch self {
        case .dateNewest: return "📅 Nieuwste eerst"
        case .dateOldest: return "📅 Oudste eerst"
        case .nameAZ: return "🔤 Naam A-Z"
        case .nameZA: return "🔤 Naam Z-A"
        case .favorites: return "⭐ Favorieten eerst"
        case .context: return "🍺 Context"
        }
    }
    
    func sort(photos: [BrewPhoto]) -> [BrewPhoto] {
        switch self {
        case .dateNewest:
            return photos.sorted(by: { $0.timestamp > $1.timestamp })
        case .dateOldest:
            return photos.sorted(by: { $0.timestamp < $1.timestamp })
        case .nameAZ:
            return photos.sorted(by: { $0.description < $1.description })
        case .nameZA:
            return photos.sorted(by: { $0.description > $1.description })
        case .favorites:
            return photos.sorted(by: { 
                if $0.isFavorite == $1.isFavorite {
                    return $0.timestamp > $1.timestamp
                }
                return $0.isFavorite && !$1.isFavorite
            })
        case .context:
            return photos.sorted(by: { 
                if $0.context.rawValue == $1.context.rawValue {
                    return $0.timestamp > $1.timestamp
                }
                return $0.context.rawValue < $1.context.rawValue
            })
        }
    }
}

// MARK: - Photo Statistics
struct PhotoStats {
    let totalPhotos: Int
    let recentPhotos: Int
    let favoritePhotos: Int
    let recipePhotos: Int
    let brewingPhotos: Int
}

// MARK: - UIImage Extension
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
} 
// MARK: - BrewPhoto Extensions  
extension BrewPhoto {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var location: String {
        return "" // Default empty location for backward compatibility
    }
}
