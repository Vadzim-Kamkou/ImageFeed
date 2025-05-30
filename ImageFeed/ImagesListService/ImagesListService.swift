import UIKit

//MARK: Struct Photo
struct Photo {
    let id: String
    let size: CGSize
    let createdAt: String
    let welcomeDescription: String
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
        
        
        guard let token = storage.token else {
            return
        }
        task?.cancel()
        lastToken = token
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotoRequest(token: token, nextPage: nextPage) else {
            //completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        

        let task = URLSession.shared.objectTaskArray(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
                guard let self = self else {return}
                switch result {
                case .success(let photoResult):
                    DispatchQueue.main.async {
                        
                        self.lastLoadedPage = nextPage
                        
                        for i in 0...photoResult.count - 1 {
                            let id = photoResult[i].id ?? ""
                            let size = CGSize(width: photoResult[i].width ?? .zero, height: photoResult[i].height ?? .zero)
                            let createdAt = photoResult[i].createdAt ?? ""
                            let description = photoResult[i].description ?? ""
                            let thumbImageURL = photoResult[i].urls?.thumb ?? ""
                            let largeImageURL = photoResult[i].urls?.full ?? ""
                            let likedByUser = photoResult[i].likedByUser ?? false
                            
                            let photoDescription: Photo = Photo(
                                id: id,
                                size: size,
                                createdAt: createdAt,
                                welcomeDescription: description,
                                thumbImageURL: thumbImageURL,
                                largeImageURL: largeImageURL,
                                isLiked: likedByUser
                            )
                            
                            let existingIDs = Set(self.photos.map { $0.id })
                            if !existingIDs.contains(photoDescription.id) {
                                self.photos.append(photoDescription)
                            }
                        }

                        NotificationCenter.default
                            .post(
                                name: ImagesListService.didChangeNotification,
                                object: self)

                        // для отладки
//                        for i in 0...self.photos.count - 1 {
//                            print("Photo \(i+1) id = \(self.photos[i].id)")
//                            print()
//                            print("size \(self.photos[i].size)")
//                            print("createdAt \(self.photos[i].createdAt)")
//                            print("welcomeDescription \(self.photos[i].welcomeDescription)")
//                            print("thumbImageURL  \(self.photos[i].thumbImageURL)")
//                            print("largeImageURL  \(self.photos[i].largeImageURL)")
//                            print("isLiked  \(self.photos[i].isLiked)")
//                            print("")
//                        }
                    }
                case .failure(let error):
                    print("[\(self)]: Network Error - \(error)")
                    //completion(.failure(error))
                }
                self.task = nil
                self.lastToken = nil
            }
        self.task = task
        task.resume()
    }
    
    private func makePhotoRequest(token: String, nextPage: Int) -> URLRequest? {
        
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            print("Unable to construct baseURL makePhotoRequest")
            return nil
        }
        guard let urlForRequest = URL(
            string: "/photos"
            + "?page=\(nextPage)",
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
    
    


