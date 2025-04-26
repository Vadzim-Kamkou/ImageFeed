import Foundation
import SwiftKeychainWrapper

protocol OAuth2TokenStorageProtocol {
    var token: String? { get }
    func storeBearerToken(token: String)
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
  
    private let storage: KeychainWrapper = .standard
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "bearerToken")
        }
        set {
            guard let newValue else {return}
            KeychainWrapper.standard.set(newValue, forKey: "bearerToken")
        }
    }

    func storeBearerToken(token: String) {
        
        let isSuccess = storage.set(token, forKey: "bearerToken")
        guard isSuccess else {
            print("OAUTH2 TOKEN STORED FAILED")
            return
        }
        print(">>> OAUTH2 TOKEN STORED SUCCESSFULLY", token)
    }
}
