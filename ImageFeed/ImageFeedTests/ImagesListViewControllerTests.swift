import XCTest
@testable import ImageFeed

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellLikeDidTaped(_ cell: ImagesListCellProtocol)
}

protocol ImagesListCellProtocol: AnyObject {
    var delegate: ImagesListCellDelegate? { get set }
    func configure(with viewModel: ImageCellViewModel)
    func setIsLiked(likeState: Bool)
}

class MockImagesListCell: UITableViewCell, ImagesListCellProtocol {
    var configuredViewModel: ImageCellViewModel?
    var likeButtonTapped = false
    weak var delegate: ImagesListCellDelegate?
    
    func configure(with viewModel: ImageCellViewModel) {
        configuredViewModel = viewModel
    }
    
    func setIsLiked(likeState: Bool) {
        // Ничего не делаем в моке
    }
    
    func simulateLikeButtonTap() {
        likeButtonTapped = true
        delegate?.imageListCellLikeDidTaped(self)
    }
}

final class ImagesListViewControllerTests: XCTestCase {
    
    var sut: ImagesListViewController!
    var mockImagesListService: MockImagesListService!
    
    override func setUp() {
        super.setUp()
        mockImagesListService = MockImagesListService()
        sut = ImagesListViewController(
            imagesListService: mockImagesListService,
            likeService: mockImagesListService
        )
        sut.view = UIView()
        sut.tableView = UITableView()
        sut.tableView.register(MockImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        sut.imagesListServiceObserver = ImagesListServiceObserver()
        sut.imagesListServiceObserver?.delegate = sut
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        mockImagesListService = nil
        super.tearDown()
    }
    
    func testViewControllerInitialization() {
        // Given
        let viewController = ImagesListViewController()
        viewController.loadViewIfNeeded()
        
        // Then
        XCTAssertNotNil(viewController)
        XCTAssertNotNil(viewController.tableView)
    }
    
    func testTableViewConfiguration() {
        // Then
        XCTAssertEqual(sut.tableView.numberOfSections, 1)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 0)
    }
    
    func testLikeButtonTapped() {
        // Given
        let photo = Photo(id: "test_id", size: CGSize(width: 100, height: 100), createdAt: "", welcomeDescription: "", thumbImageURL: "test_url", largeImageURL: "test_url", isLiked: false)
        mockImagesListService.photos = [photo]
        sut.updatePhotos()
        sut.tableView.reloadData()
        
        // When
        let cell = MockImagesListCell(style: .default, reuseIdentifier: ImagesListCell.reuseIdentifier)
        cell.delegate = sut
        let viewModel = ImageCellViewModel(
            imageURL: URL(string: photo.thumbImageURL),
            isLiked: photo.isLiked,
            dateText: ""
        )
        cell.configure(with: viewModel)
        cell.simulateLikeButtonTap()
        
        // Then
        XCTAssertTrue(mockImagesListService.didChangeLike)
    }
    
    func testLoadNextPage() {
        // Given
        mockImagesListService.photos = [Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: "", welcomeDescription: "", thumbImageURL: "test_url", largeImageURL: "test_url", isLiked: false)]
        sut.tableView.reloadData()
        
        // When
        sut.tableView(sut.tableView, willDisplay: ImagesListCell(), forRowAt: IndexPath(row: 0, section: 0))
        
        // Then
        XCTAssertTrue(mockImagesListService.didFetchPhotos)
    }
    
    func testShowSingleImage() {
        // Given
        let photo = Photo(id: "test_id", size: CGSize(width: 100, height: 100), createdAt: "", welcomeDescription: "", thumbImageURL: "test_url", largeImageURL: "test_url", isLiked: false)
        mockImagesListService.photos = [photo]
        sut.tableView.reloadData()
        
        // When
        sut.tableView(sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        // Then
        let singleImageVC = sut.presentedViewController as? SingleImageViewController
        XCTAssertNotNil(singleImageVC, "SingleImageViewController должен быть показан")
        XCTAssertEqual(singleImageVC?.largeImageURL?.absoluteString, photo.largeImageURL)
    }
}

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
        completion(.success(isLiked))
    }
} 