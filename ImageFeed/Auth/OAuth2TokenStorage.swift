
import Foundation

protocol OAuth2TokenStorageProtocol {
    var token: String? { get }
    func storeBearerToken(token: String)
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
  
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case token = "bearerToken"
    }
    
    var token: String? {
        get {
            storage.string(forKey: Keys.token.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.token.rawValue)
        }
    }

    func storeBearerToken(token: String) {
        storage.set(token, forKey: "bearerToken")
    }
}
