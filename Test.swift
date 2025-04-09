//
//import Foundation
//
//
//questionFactory?.loadData()
//
//
//func loadData() {
//    
//    moviesLoader.loadMovies { [weak self] result in
//        
//        DispatchQueue.main.async {
//            
//            guard let self = self else { return }
//            switch result {
//            
//            case .success(let mostPopularMovies):
//                self.movies = mostPopularMovies.items
//                self.delegate?.didLoadDataFromServer()
//            case .failure(let error):
//                self.delegate?.didFailToLoadData(with: error)
//            }
//        }
//    }
//}
//
//func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
//    networkClient.fetch(url: mostPopularMoviesUrl) { result in
//        print(">>>", result)
//        switch result {
//        case .success(let data):
//            do {
//                let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
//                handler(.success(mostPopularMovies))
//            } catch {
//                handler(.failure(error))
//            }
//        case .failure(let error):
//            handler(.failure(error))
//        }
//    }
//}
//
//
//struct NetworkClient:NetworkRouting {
//
//    private enum NetworkError: Error {
//        case codeError
//    }
//    
//    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
//        let request = URLRequest(url: url)
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            // Проверяем, пришла ли ошибка
//            if let error = error {
//                handler(.failure(error))
//                return
//            }
//            
//            // Проверяем, что нам пришёл успешный код ответа
//            if let response = response as? HTTPURLResponse,
//                response.statusCode < 200 || response.statusCode >= 300 {
//                handler(.failure(NetworkError.codeError))
//                return
//            }
//            
//            // Возвращаем данные
//            guard let data = data else { return }
//            handler(.success(data))
//        }
//        
//        task.resume()
//    }
//}
