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
        let task = URLSession.shared.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch result {
                case .success(let data):
                    switch self.decodeProfileDataJSON(from: data) {
                    case .success(let responseBody):

                        guard let profileImageURL: String = responseBody.profileImages?.small else {
                            return
                        }
                        completion(.success(profileImageURL))
                        
                        NotificationCenter.default                                     // 1
                            .post(                                                     // 2
                                name: ProfileImageService.didChangeNotification,       // 3
                                object: self,                                          // 4
                                userInfo: ["URL": profileImageURL])                    // 5
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
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
    
    private func decodeProfileDataJSON(from data: Data) -> Result<UserResult, Error> {
        //print(String(data: data, encoding: .utf8))
        do {
            let responseBody = try JSONDecoder().decode(UserResult.self, from: data)
            print(">>> UNSPLASH PROFILE IMAGE JSON SUCCESSFULLY PARSED")
            return .success(responseBody)
        } catch {
            print(">>> ОШИБКА ДЕКОДИРОВАНИЯ PROFILE IMAGE JSON: ", error)
            return .failure(error)
        }
    }
    
}
