import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellLikeDidTaped(_ cell: ImagesListCell)
}

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    let imagesListService = ImagesListService.shared
    
    let isoDateFormatter = ISO8601DateFormatter()
    let displayFormatter = DateFormatter()
    
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imagesListService.fetchPhotosNextPage()
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                updateTableViewAnimated()
            }
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
    
    private func updateTableViewAnimated() {
        
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
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
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellLikeDidTaped(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let imageId = photos[indexPath.row].id
        let isLiked = photos[indexPath.row].isLiked
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: imageId, isLiked: isLiked){ result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(likeState: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                
                let alertResult = UIAlertController(
                    title: "Что-то пошло не так",
                    message: "Функционал лайков недоступен.\nПопробуйте позже.",
                    preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default)
                alertResult.addAction(action)
                self.present(alertResult, animated: true, completion: nil)
            }
        }
    }
}


extension ImagesListViewController {
    
    // настраиваем ячейку: дата (какая дата?) и лайк, если он есть.
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        tableView(self.tableView, willDisplay: cell, forRowAt: indexPath)
        
        if imagesListService.photos.count == 0 {
            return
        }
        
        guard let url = URL(string: photos[indexPath.row].thumbImageURL) else {
            return
        }
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url,
                                   placeholder: UIImage(resource: .downloading)) { result in
            switch result {
            case .success(let value):
                
                // подставляем картинку, однако работает и явного присваивания
                cell.cellImage.image = value.image
                
                // подставляем лайк
                let isLiked = self.photos[indexPath.row].isLiked
                let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "NoActive")
                cell.likeButton.setImage(likeImage, for: .normal)
                
                // выводим дату
                let createdAt = self.photos[indexPath.row].createdAt
                if let date = self.isoDateFormatter.date(from: createdAt){
                    self.displayFormatter.locale = Locale(identifier: "ru_RU")
                    self.displayFormatter.dateFormat = "d MMMM yyyy"
                    cell.dateLabel.text = self.displayFormatter.string(from: date)
                } else {
                    cell.dateLabel.text = ""
                }
                
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
    // если подошли подошли к концу ленты - догружаем фотографии
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}
