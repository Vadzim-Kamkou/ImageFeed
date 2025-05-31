import Foundation

struct PhotoResult: Codable {
    let id: String?
    let createdAt: String?
    let width: Int?
    let height: Int?
    let likedByUser: Bool?
    let description: String?
    let urls: UrlResult?

    init(
        id: String?,
        createdAt: String?,
        width: Int?,
        height: Int?,
        likedByUser: Bool?,
        description: String?,
        urls: UrlResult?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.width = width
        self.height = height
        self.likedByUser = likedByUser
        self.description = description
        self.urls = urls
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case width = "width"
        case height = "height"
        case likedByUser = "liked_by_user"
        case description = "description"
        case urls = "urls"
    }
}


struct UrlResult: Codable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?

    init(
        raw: String?,
        full: String?,
        regular: String?,
        small: String?,
        thumb: String?
    ) {
        self.raw = raw
        self.full = full
        self.regular = regular
        self.small = small
        self.thumb = thumb
    }
    
    private enum CodingKeys: String, CodingKey {
        case raw = "raw"
        case full = "full"
        case regular = "regular"
        case small = "small"
        case thumb = "thumb"
    }
}

// структура-обертка для обработки "https://api.unsplash.com/photos/id/like" JSON
struct ChangeLikePhotoResult: Decodable {
    let photo: PhotoResult
}
