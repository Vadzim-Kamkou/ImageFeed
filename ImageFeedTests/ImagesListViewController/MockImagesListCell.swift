import XCTest
@testable import ImageFeed

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
