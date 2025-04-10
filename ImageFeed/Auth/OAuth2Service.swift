import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    private var OAuthToken:String = ""
    
    init() {
        oAuth2TokenStorage = OAuth2TokenStorage()
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        
        var baseURL:URL {
            guard let url = URL(string: "https://unsplash.com") else {
                preconditionFailure("Unable to construct baseURL")
            }
            return url
        }
        
        var urlForRequest:URL {
            guard let url = URL(
                string: "/oauth/token"
                + "?client_id=\(Constants.accessKey)"
                + "&&client_secret=\(Constants.secretKey)"
                + "&&redirect_uri=\(Constants.redirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
                relativeTo: baseURL
            ) else {
                preconditionFailure("Unable to construct urlForRequest")
            }
            return url
        }
        
        var request = URLRequest(url: urlForRequest)
        request.httpMethod = "POST"
        return request
     }
    
    func decodeJSON(from data: Data) -> Result<OAuthTokenResponseBody, Error> {
        do {
            let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            return .success(responseBody)
        } catch {
            print(">>> ОШИБКА ДЕКОДИРОВАНИЯ JSON: ", error)
            return .failure(error)
        }
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void) {
        let request: URLRequest = makeOAuthTokenRequest(code: code)
        let task = URLSession.shared.data(for: request) { result in
            switch result {
                    case .success(let data):
                        switch self.decodeJSON(from: data) {
                        case .success(let response):
                            let token: String = response.accessToken
                            self.oAuth2TokenStorage.storeBearerToken(token: token)
                            handler(.success(token))
                        case .failure(let error):
                            handler(.failure(error))
                        }
                    case .failure(let error):
                        handler(.failure(error))
                    }
        }
        task.resume()
    }
}
