import UIKit

protocol ApplicationProtocol {
    var windows: [UIWindow] { get }
}

extension UIApplication: ApplicationProtocol {}
