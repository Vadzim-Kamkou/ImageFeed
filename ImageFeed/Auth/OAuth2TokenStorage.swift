import Foundation
import SwiftKeychainWrapper

protocol OAuth2TokenStorageProtocol {
    var token: String? { get }
    func storeBearerToken(token: String)
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
  
    private let storage: KeychainWrapper = .standard
    private let tokenKey: String = "bearerToken"
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            guard let newValue else {return}
            KeychainWrapper.standard.set(newValue, forKey: tokenKey)
        }
    }

    func storeBearerToken(token: String) {
        
        let isSuccess = storage.set(token, forKey: tokenKey)
        guard isSuccess else {
            print("OAUTH2 TOKEN STORED FAILED")
            return
        }
        print(">>> OAUTH2 TOKEN STORED SUCCESSFULLY", token)
    }
}
