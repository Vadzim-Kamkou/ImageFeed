import XCTest
@testable import ImageFeed

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
        sut.tableView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        sut.tableView.register(MockImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        sut.imagesListServiceObserver = ImagesListServiceObserver()
        sut.imagesListServiceObserver?.delegate = sut
        sut.loadViewIfNeeded()
        
        // Устанавливаем делегаты таблицы
        sut.tableView.dataSource = self
        sut.tableView.delegate = sut
    }
    
    override func tearDown() {
        sut = nil
        mockImagesListService = nil
        super.tearDown()
    }
    
    func testViewControllerInitialization() {
        // Given
        let viewController = ImagesListViewController()
        viewController.view = UIView()
        viewController.tableView = UITableView()
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
        
        // Создаем ячейку напрямую
        let cell = MockImagesListCell(style: .default, reuseIdentifier: ImagesListCell.reuseIdentifier)
        cell.delegate = sut
        
        // Конфигурируем ячейку
        let viewModel = ImageCellViewModel(
            imageURL: URL(string: photo.thumbImageURL),
            isLiked: photo.isLiked,
            dateText: ""
        )
        cell.configure(with: viewModel)
        
        // When
        cell.simulateLikeButtonTap()
        
        // Then
        XCTAssertTrue(cell.likeButtonTapped, "Кнопка лайка должна быть нажата")
    }
    
    func testLoadNextPage() {
        // Given
        mockImagesListService.photos = [Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: "", welcomeDescription: "", thumbImageURL: "test_url", largeImageURL: "test_url", isLiked: false)]
        sut.updatePhotos()
        sut.tableView.reloadData()
        
        // When
        let cell = MockImagesListCell(style: .default, reuseIdentifier: ImagesListCell.reuseIdentifier)
        sut.tableView(sut.tableView, willDisplay: cell, forRowAt: IndexPath(row: 0, section: 0))
        
        // Then
        XCTAssertTrue(mockImagesListService.didFetchPhotos)
    }
    
    func testShowSingleImage() {
        // Given
        let photo = Photo(id: "test_id", size: CGSize(width: 100, height: 100), createdAt: "", welcomeDescription: "", thumbImageURL: "test_url", largeImageURL: "test_url", isLiked: false)
        mockImagesListService.photos = [photo]
        sut.updatePhotos()
        sut.tableView.reloadData()
        
        // When
        let indexPath = IndexPath(row: 0, section: 0)
        let destinationVC = SingleImageViewController()
        let segue = UIStoryboardSegue(identifier: "ShowSingleImage", source: sut, destination: destinationVC)
        
        sut.prepare(for: segue, sender: indexPath)
        
        // Then
        XCTAssertEqual(destinationVC.largeImageURL?.absoluteString, photo.largeImageURL)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewControllerTests: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockImagesListService.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! MockImagesListCell
        cell.delegate = sut
        let photo = mockImagesListService.photos[indexPath.row]
        let viewModel = ImageCellViewModel(
            imageURL: URL(string: photo.thumbImageURL),
            isLiked: photo.isLiked,
            dateText: ""
        )
        cell.configure(with: viewModel)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewControllerTests: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 // Фиксированная высота для тестов
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sut.tableView(tableView, didSelectRowAt: indexPath)
    }
}
