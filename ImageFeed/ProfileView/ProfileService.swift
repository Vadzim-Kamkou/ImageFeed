import UIKit

struct Profile {
    
    var username: String
    var name: String
    var loginName: String
    var bio: String
    
    init(username: String, name: String, loginName: String, bio: String) {
        self.username = username
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }
}

final class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile? = Profile.init(username: "username", name: "name", loginName: "@loginName", bio: "bio")
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)  {

        assert(Thread.isMainThread)

        guard lastToken != token else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastToken = token
        
        guard let request = self.makeAutorizationRequest(token: token) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch result {
                case .success(let profileResult):
                    
     
                    guard self.profile != nil else {
                        return
                    }

                    if let username = profileResult.username {
                        let loginName = "@\(username)"
                        self.profile?.username = username
                        self.profile?.loginName = loginName
                    }
                    if let first_name = profileResult.first_name, let last_name = profileResult.last_name {
                        let name = "\(first_name)\(" ")\(last_name)"
                        self.profile?.name = name
                    }
                    if let bio = profileResult.bio {
                        self.profile?.bio = bio
                    }
                    
                    guard let profile = self.profile else {
                        return
                    }
                    
                    completion(.success(profile))

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
    
    private func makeAutorizationRequest(token: String) -> URLRequest? {
        
        guard let baseURL = URL(string: "https://api.unsplash.com/me") else {
            print("Unable to construct baseURL makeAutorizationRequest")
            return nil
        }
        
        var request = URLRequest(url: baseURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
     }
    
//    private func decodeProfileDataJSON(from data: Data) -> Result<ProfileResult, Error> {
//        do {
//            let responseBody = try JSONDecoder().decode(ProfileResult.self, from: data)
//            print(">>> UNSPLASH PROFILE JSON SUCCESSFULLY PARSED")
//            return .success(responseBody)
//        } catch {
//            print(">>> ОШИБКА ДЕКОДИРОВАНИЯ JSON: ", error)
//            return .failure(error)
//        }
//    }
}
