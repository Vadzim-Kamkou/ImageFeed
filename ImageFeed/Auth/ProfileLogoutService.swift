import Foundation
import WebKit
import SwiftKeychainWrapper

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol

    private init() {
        oAuth2TokenStorage = OAuth2TokenStorage()
        
    }

    func logout() {
        cleanCookies()
        // удаляем токен авторизации
        KeychainWrapper.standard.removeObject(forKey: "bearerToken")
        // удаляем данные профиля, структура Profile
        ProfileService.shared.clearProfileData()
        // удаляем картинку профиля avatarURL
        ProfileImageService.shared.clearProfileImageData()
        // удаляем все картинки
        ImagesListService.shared.clearPhotos()
        print(">>> TOKEN AND PROFILE DATA SUCCESSFULLY DELETED")
    }

    private func cleanCookies() {
      // Очищаем все куки из хранилища
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      // Запрашиваем все данные из локального хранилища
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         // Массив полученных записей удаляем из хранилища
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
    }
}


