import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    
    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        
        print(">>> URLSession.data 1")
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in  // 2
            DispatchQueue.main.async {
                print(">>> URLSession.data 2")
                completion(result)
            }
        }
        print(">>> URLSession.data 3")
        let task = dataTask(with: request, completionHandler: { data, response, error in
            print(">>> URLSession.data 4")
            
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                    print(">> Data",data)// 3
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode))) // 4
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error))) // 5
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError)) // 6
            }
        })
        print(">>> URLSession.data task")
        return task
    }
    
}
