import UIKit
import ProgressHUD

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded , let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var largeImageURL: URL?

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        loadLargeImageURL ()
    }
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
            let share = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            present(share, animated: true, completion: nil)
        }
    
    private func loadLargeImageURL () {
        guard let largeImageURL else {return}
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: largeImageURL) { result in
                                                switch result {
                                                case .success(let value):
                                                    UIBlockingProgressHUD.dismiss()
                                                    self.image = value.image
                                                case .failure(_):
                                                    UIBlockingProgressHUD.dismiss()
                                                    self.showError()
                                                }
                                            }
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        if imageSize.width == 0 || imageSize.height == 0 {
            return
        }
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func showError() {
        let alertResult = UIAlertController(
            title: "Что-то пошло не так",
            message: "Полноразмерная картинка не загружена.\nПопробовать еще раз?",
            preferredStyle: .alert)
        let action_skip = UIAlertAction(title: "Не нужно", style: .default)
        let action_reload = UIAlertAction(title: "Повторить", style: .cancel) { _ in
            self.loadLargeImageURL()
        }
        alertResult.addAction(action_skip)
        alertResult.addAction(action_reload)
        self.present(alertResult, animated: true, completion: nil)
    }
    
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
