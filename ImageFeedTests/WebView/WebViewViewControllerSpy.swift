import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var didLoadCalled: Bool = false
    var presenter: WebViewPresenterProtocol?
    
    func load(request: URLRequest) {
        didLoadCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        //progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        //progressView.isHidden = isHidden
    }
    
}



