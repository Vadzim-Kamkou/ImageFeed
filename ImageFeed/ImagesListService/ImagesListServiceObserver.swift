import Foundation

protocol ImagesListServiceObserverDelegate: AnyObject {
    func didUpdatePhotos()
}

final class ImagesListServiceObserver {
    weak var delegate: ImagesListServiceObserverDelegate?
    private var observer: NSObjectProtocol?
    
    init() {
        observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.delegate?.didUpdatePhotos()
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}


