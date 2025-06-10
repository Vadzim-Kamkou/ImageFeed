import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell, ImagesListCellProtocol {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    
    @IBAction func tapLikeButton(_ sender: Any) {
        self.delegate?.imageListCellLikeDidTaped(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    
    func setIsLiked(likeState: Bool) {
        let likeImage = likeState ? UIImage(named: "Active") : UIImage(named: "NoActive")
        self.likeButton.setImage(likeImage, for: .normal)
    }
    
    func configure(with viewModel: ImageCellViewModel) {
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: viewModel.imageURL, placeholder: UIImage(resource: .downloading))
        
        let likeImage = viewModel.isLiked ? UIImage(named: "Active") : UIImage(named: "NoActive")
        likeButton.setImage(likeImage, for: .normal)
        
        dateLabel.text = viewModel.dateText
    }
}
