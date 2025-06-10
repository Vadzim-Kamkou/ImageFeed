import UIKit

protocol ImagesListCellProtocol: AnyObject {
    var delegate: ImagesListCellDelegate? { get set }
    func configure(with viewModel: ImageCellViewModel)
    func setIsLiked(likeState: Bool)
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellLikeDidTaped(_ cell: ImagesListCellProtocol)
}

protocol PhotoProvider: AnyObject {
    func photo(at index: Int) -> Photo
}

final class ImagesListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    var imagesListService: ImagesListServiceProtocol
    var imagesListServiceObserver: ImagesListServiceObserver?
    
    private let isoDateFormatter: DateFormatting
    private let displayFormatter: DateFormatting
    
    private let viewModelFactory: ImageCellViewModelFactory
    
    private var photosCount: Int {
        photos.count
    }
    
    private let likeService: LikeService
    
    private lazy var likeHandler: ImageLikeHandler = {
        return ImageLikeHandler(likeService: likeService)
    }()
    

    init(
        imagesListService: ImagesListServiceProtocol = ImagesListService.shared,
        likeService: LikeService = ImagesListService.shared,
        isoDateFormatter: DateFormatting = ISO8601DateFormatterWrapper(),
        displayFormatter: DateFormatting = DisplayDateFormatter(localeIdentifier: "ru_RU", dateFormat: "d MMMM yyyy"),
        viewModelFactory: ImageCellViewModelFactory? = nil
    ) {
        self.imagesListService = imagesListService
        self.likeService = likeService
        self.isoDateFormatter = isoDateFormatter
        self.displayFormatter = displayFormatter
        
        
        let resolvedFactory = viewModelFactory ?? DefaultImageCellViewModelFactory(
                isoDateFormatter: isoDateFormatter,
                displayFormatter: displayFormatter
            )
        self.viewModelFactory = resolvedFactory
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.imagesListService = ImagesListService.shared
        self.likeService = ImagesListService.shared
        self.isoDateFormatter = ISO8601DateFormatterWrapper()
        self.displayFormatter = DisplayDateFormatter(localeIdentifier: "ru_RU", dateFormat: "d MMMM yyyy")
        self.viewModelFactory = DefaultImageCellViewModelFactory(
                isoDateFormatter: isoDateFormatter,
                displayFormatter: displayFormatter
            )
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let tableView = tableView else { return }
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imagesListService.fetchPhotosNextPage()
        
        imagesListServiceObserver = ImagesListServiceObserver()
        imagesListServiceObserver?.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                return
            }
            
            guard let largeImageURL = URL(string: photo(at: indexPath.row).largeImageURL) else {
                return
            }
            
            viewController.largeImageURL = largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updatePhotos() {
        photos = imagesListService.photos
    }
    private func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard oldCount != newCount else { return }
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    // настраиваем ячейку: дата (какая дата?) и лайк, если он есть.
    func configCell(for cell: ImagesListCellProtocol, with indexPath: IndexPath) {
        let photo = self.photo(at: indexPath.row)
        let viewModel = viewModelFactory.makeViewModel(from: photo)
        cell.configure(with: viewModel)
        
        // Подгрузка следующей страницы (оставим здесь)
        tableView(self.tableView, willDisplay: cell as! UITableViewCell, forRowAt: indexPath)
    }

    // если подошли подошли к концу ленты - догружаем фотографии
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

//MARK: EXTENSIONS
extension ImagesListViewController: UITableViewDataSource {
    // определяем количество ячеек в секции, через размер массива с фото
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    // подготавливаем ячейки к реиспользованию
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imagesListCell.delegate = self
        configCell(for: imagesListCell, with: indexPath)
        
        return imagesListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    // определение высоты ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // проверяем есть ли такая картинка, если нет выходим
        let image = photos[indexPath.row]
        
        // определяем ширину и высоту ячейки учитывая размеры фото
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let callHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return callHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellLikeDidTaped(_ cell: ImagesListCellProtocol) {
        guard let indexPath = tableView.indexPath(for: cell as! UITableViewCell) else { return }
        let photo = photos[indexPath.row]
        likeHandler.toggleLike(for: photo) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedPhoto):
                    self?.photos[indexPath.row] = updatedPhoto
                    cell.setIsLiked(likeState: updatedPhoto.isLiked)
                case .failure:
                    let alert = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось обновить лайк. Попробуйте позже.",
                        preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}

extension ImagesListViewController: ImagesListServiceObserverDelegate {
    func didUpdatePhotos() {
        let oldCount = photos.count
        updatePhotos()
        let newCount = photos.count
        updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
}

extension ImagesListViewController: PhotoProvider {
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
}

extension ImagesListViewController: ImageLikeHandlerDelegate {
    func didUpdateLikeState(to isLiked: Bool, for cell: ImagesListCellProtocol) {
        guard let tableViewCell = cell as? UITableViewCell,
              tableView.indexPath(for: tableViewCell) != nil else { return }
        self.photos = self.imagesListService.photos
        cell.setIsLiked(likeState: isLiked)
    }

    func didFailToUpdateLike(for cell: ImagesListCellProtocol) {
        let alertResult = UIAlertController(
            title: "Что-то пошло не так",
            message: "Функционал лайков недоступен.\nПопробуйте позже.",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Ok", style: .default)
        alertResult.addAction(action)
        self.present(alertResult, animated: true)
    }
}

