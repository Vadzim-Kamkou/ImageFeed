import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let oAuth2TokenStorage: OAuth2TokenStorageProtocol
    

    private init() {
        oAuth2TokenStorage = OAuth2TokenStorage()
    }
    
    var OAuthToken:String = ""
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
         let baseURL = URL(string: "https://unsplash.com")
         let url = URL(
             string: "/oauth/token"
             + "?client_id=\(Constants.accessKey)"
             + "&&client_secret=\(Constants.secretKey)"
             + "&&redirect_uri=\(Constants.redirectURI)"
             + "&&code=\(code)"
             + "&&grant_type=authorization_code",
             relativeTo: baseURL
         )! // TODO:
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         return request
     }
    
    func decodeJSON(from data: Data) -> Result<OAuthTokenResponseBody, Error> {
        do {
            let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            return .success(responseBody)
        } catch {
            return .failure(error)
        }
    }
    
    
    
    
    
    
    private enum NetworkError: Error {
        case codeError
    }
    
    
    func fetchOAuthToken(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {


        let task = URLSession.shared.data(for: request) { result in
            
            switch result {
                    case .success(let data):
                        switch self.decodeJSON(from: data) {
                            case .success(let response):
                                self.oAuth2TokenStorage.storeBearerToken(token: response.accessToken)

                            case .failure(let error):
                                handler(.failure(error))
                        }
                        handler(.success(data))
                    case .failure(let error):
                        handler(.failure(error))
                    }
            
        }
        
        
        
        // Реквест, чтобы получить код
//        let task1 = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                handler(.failure(error))
//                return
//            }
//            
//            if let response = response as? HTTPURLResponse,
//                response.statusCode < 200 || response.statusCode >= 300 {
//                handler(.failure(NetworkError.codeError))
//                return
//            }
//            // Возвращаем данные
//            guard let data = data else { return }
//            switch self.decodeJSON(from: data) {
//            case .success(let response):
//                self.oAuth2TokenStorage.storeBearerToken(token: response.accessToken)
//                print(">>> TOKEN SUCCESS", response.accessToken)
//            case .failure(let error):
//                handler(.failure(error))
//            }
//            handler(.success(data))
//        }
        
        task.resume()
    }
    
    

}
