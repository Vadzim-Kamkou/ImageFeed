import Foundation

/*
[
  {
    "id": "LBI7cgq3pbM",
    "created_at": "2016-05-03T11:00:28-04:00",
    "updated_at": "2016-07-10T11:00:01-05:00",
    "width": 5245,
    "height": 3497,
    "color": "#60544D",
    "blur_hash": "LoC%a7IoIVxZ_NM|M{s:%hRjWAo0",
    "likes": 12,
    "liked_by_user": false,
    "description": "A man drinking a coffee.",
    "user": {
      // ...
    },
    // ...
    "urls": {
      "raw": "https://images.unsplash.com/face-springmorning.jpg",
      "full": "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg",
      "regular": "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg&w=1080&fit=max",
      "small": "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg&w=400&fit=max",
      "thumb": "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg&w=200&fit=max"
    },
    // ...
  },
  // ... more photos
]
 */

struct PhotoResult: Codable {
    let id: String?
//    let created_at: String?
//    let updated_at: String?
//    let width: Int?
//    let height: Int?
//    let color: String?
//    let blur_hash: URL?
//    let likes: Int?
//    let liked_by_user: Bool?
//    let description: String?

    init(
        id: String?
//        created_at: String?,
//        updated_at: String?,
//        width: Int?,
//        height: Int?,
//        color: String?,
//        blur_hash: URL?,
//        likes: Int?,
//        liked_by_user: Bool?,
//        description: String?
    ) {
        self.id = id
//        self.created_at = created_at
//        self.updated_at = updated_at
//        self.width = width
//        self.height = height
//        self.color = color
//        self.blur_hash = blur_hash
//        self.likes = likes
//        self.liked_by_user = liked_by_user
//        self.description = description
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
//        case created_at = "created_at"
//        case updated_at = "updated_at"
//        case width = "width"
//        case height = "height"
//        case color = "color"
//        case blur_hash = "blur_hash"
//        case likes = "likes"
//        case liked_by_user = "liked_by_user"
//        case description = "description"
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
