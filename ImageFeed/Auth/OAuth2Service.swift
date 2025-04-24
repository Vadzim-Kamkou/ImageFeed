import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    private var OAuthToken:String = ""
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {
        oAuth2TokenStorage = OAuth2TokenStorage()
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Unable to construct baseURL")
            return nil
        }
           
        guard let urlForRequest = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("Unable to construct urlForRequest")
            return nil
        }

        var request = URLRequest(url: urlForRequest)
        request.httpMethod = "POST"
        return request
     }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self = self else {return}
    
                switch result {
                case .success(let oAuthTokenResponseBody):
                    
                    let token: String = oAuthTokenResponseBody.accessToken
                    self.oAuth2TokenStorage.storeBearerToken(token: token)
                    handler(.success(token))

                case .failure(let error):
                    handler(.failure(error))
                }
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
}
