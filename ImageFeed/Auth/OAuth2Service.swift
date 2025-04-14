import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    private var OAuthToken:String = ""
    
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
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            return
        }
        let task = URLSession.shared.data(for: request) { [weak self] result in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
    
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
        }
        task.resume()
    }
}
