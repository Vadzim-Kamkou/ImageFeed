import Foundation

protocol ImageLikeHandlerDelegate: AnyObject {
    func didUpdateLikeState(to isLiked: Bool, for cell: ImagesListCellProtocol)
    func didFailToUpdateLike(for cell: ImagesListCellProtocol)
}

protocol LikeHandler: AnyObject {
    func toggleLike(for photo: Photo, completion: @escaping (Result<Photo, Error>) -> Void)
}

final class ImageLikeHandler: LikeHandler {
    private let likeService: LikeService

    init(likeService: LikeService) {
        self.likeService = likeService
    }

    func toggleLike(for photo: Photo, completion: @escaping (Result<Photo, Error>) -> Void) {
        let photoId = photo.id
        let isLiked = photo.isLiked

        likeService.changeLikeStatus(photoId: photoId, isLiked: isLiked) { result in
            switch result {
            case .success(let newLikeState):
                var updatedPhoto = photo
                updatedPhoto.isLiked = newLikeState
                completion(.success(updatedPhoto))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


 
