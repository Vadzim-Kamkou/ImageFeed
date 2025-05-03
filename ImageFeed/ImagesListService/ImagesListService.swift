import UIKit

//MARK: Struct Photo
struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

final class ImagesListService {

    //MARK: Property
    static let shared = ImagesListService()
    private init() {}
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String? //? используется ли
    private let storage = OAuth2TokenStorage()
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
  
    
    
    
    
    //MARK: Functions
    func fetchPhotosNextPage() {
        // функция внутри себя определяет номер следующей страницы для закачки (номер не должен сообщаться извне, как параметр функции);
        //если идёт закачка, то нового сетевого запроса не создаётся, а выполнение функции прерывается;
        //при получении новых фотографий массив photos обновляется из главного потока, новые фото добавляются в конец массива;
        //после обновления значения массива photos публикуется нотификация ImagesListService.DidChangeNotification.
        print("fetchPhotosNextPage")
        
        guard let token = storage.token else {
            return
        }

        
        guard let request = makePhotoRequest(token: token) else {
            //completion(.failure(AuthServiceError.invalidRequest))
            print("!")
            
            return
        }
        print(request)
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<PhotoResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch result {
                case .success(let profileResult):
                    
                        print("!!")
//                    guard self.profile != nil else {
//                        return
//                    }
//
//                    if let username = profileResult.username {
//                        let loginName = "@\(username)"
//                        self.profile?.username = username
//                        self.profile?.loginName = loginName
//                    }
//                    if let first_name = profileResult.first_name, let last_name = profileResult.last_name {
//                        let name = "\(first_name)\(" ")\(last_name)"
//                        self.profile?.name = name
//                    }
//                    if let bio = profileResult.bio {
//                        self.profile?.bio = bio
//                    }
//                    
//                    guard let profile = self.profile else {
//                        return
//                    }
                    
                        //completion(.success("Ура"))

                case .failure(let error):
                    print("[\(self)]: Network Error - \(error)")
                    //completion(.failure(error))
                }
                self.task = nil
                //self.lastToken = nil
            }
        }
        self.task = task
        task.resume()
        
        
        
    }
    
    private func makePhotoRequest(token: String) -> URLRequest? {
        
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            print("Unable to construct baseURL makePhotoRequest")
            return nil
        }
        guard let urlForRequest = URL(
            string: "/photos"
            + "?page=\(1)",
            relativeTo: baseURL
        ) else {
            print("Unable to construct urlForRequest")
            return nil
        }
        
        
        
        var request = URLRequest(url: urlForRequest)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
     }
    
    
    
    
}
    
    


