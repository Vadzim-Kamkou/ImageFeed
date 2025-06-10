import XCTest
@testable import ImageFeed

// MARK: - Mock ImagesListService
class MockImagesListService: ImagesListServiceProtocol, LikeService {
    var photos: [Photo] = []
    var didChangeLike = false
    var didFetchPhotos = false
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        didFetchPhotos = true
    }
    
    func changeLike(photoId: String, isLiked: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        didChangeLike = true
        completion(.success(()))
    }
    
    func resetPhotos() {
        photos = []
    }
    
    func changeLikeStatus(photoId: String, isLiked: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        didChangeLike = true
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            var photo = photos[index]
            photo.isLiked = isLiked
            photos[index] = photo
        }
        // Выполняем колбэк синхронно
        completion(.success(isLiked))
    }
}
