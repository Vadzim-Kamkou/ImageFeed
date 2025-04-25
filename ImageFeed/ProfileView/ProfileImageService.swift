import Foundation

struct UserResult: Codable {
    let profileImages: ProfileImage?

    private enum CodingKeys: String, CodingKey {
        case profileImages = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String?
    
    private enum CodingKeys: String, CodingKey {
        case small = "small"
    }
    
}

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private init() {}
    private(set) var avatarURL: String?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
       
        assert(Thread.isMainThread)

        guard let token = OAuth2TokenStorage().token else {return}
        guard lastToken != token else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastToken = token
        
       
        
        guard let request = self.makeAutorizationRequest(token: token, username: username) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch result {
                case .success(let userResult):
                    
                    guard let profileImageURL: String = userResult.profileImages?.small else {
                        return
                    }
                    completion(.success(profileImageURL))
                    
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": profileImageURL])
                    
                case .failure(let error):
                    print("[\(self)]: Network Error - \(error)")
                    completion(.failure(error))
                }
                self.task = nil
                self.lastToken = nil
            }
        }
        self.task = task
        task.resume()

    }
    
    private func makeAutorizationRequest(token: String, username: String) -> URLRequest? {
        
        guard let baseURL = URL(string: "https://api.unsplash.com//users/\(username)") else {
            print("Unable to construct baseURL makeAutorizationRequest")
            return nil
        }
        
        var request = URLRequest(url: baseURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
     }
}
