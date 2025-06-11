import Testing
import XCTest
@testable import ImageFeed

class ProfileViewControllerMock: ProfileViewController {
        var presentedVC: UIViewController?
        
        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            self.presentedVC = viewControllerToPresent
        }
    }

