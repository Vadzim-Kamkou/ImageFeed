import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    //print(String(data: data, encoding: .utf8) ?? "")
                    let responseBody = try JSONDecoder().decode(T.self, from: data)
                    print(">>> JSON SUCCESSFULLY PARSED, \(T.self) STRUCT CREATED")
                    completion(.success(responseBody))
                } catch {
                    print(">>> JSON DECODE ERROR, \(T.self) STRUCT FAILED: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }

    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print(">>> ОШИБКА ОТВЕТА СЕРВЕРА: ", NetworkError.httpStatusCode(statusCode))
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                print(">>> СЕТЕВАЯ ОШИБКА: ", NetworkError.urlRequestError(error))
            } else {
                print(">>> НЕИЗВЕСТНАЯ ОШИБКА URLSessionTask", NetworkError.urlSessionError)
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
    
    
   func objectTaskArray<T: Decodable>(for request: URLRequest, completion: @escaping (Result<[T], Error>) -> Void) -> URLSessionTask {
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let responseBody = try JSONDecoder().decode([T].self, from: data)
                    print(">>> JSON SUCCESSFULLY PARSED, \([T].self) STRUCT CREATED")
                    completion(.success(responseBody))
                    
                } catch {
                    print(">>> JSON DECODE ERROR, \([T].self) STRUCT FAILED: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }  
}
