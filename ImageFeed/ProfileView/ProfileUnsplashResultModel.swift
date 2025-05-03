import Foundation

/*
 Unsplash Documentation Get the user’s profile JSON
 https://unsplash.com/documentation#current-user
 */

struct ProfileResult: Codable {
    let id: String?
    let updated_at: String?
    let username: String?
    let first_name: String?
    let last_name: String?
    let twitter_username: String?
    let portfolio_url: URL?
    let bio: String?
    let location: String?
    let total_likes: Int?
    let total_photos: Int?
    let total_collections: Int?
    let downloads: Int?
    let uploads_remaining: Int?
    let instagram_username: String?
    let location_additional: String?
    let email: String?
    
    init(
        id: String,
        updated_at: String,
        username: String,
        first_name: String,
        last_name: String,
        twitter_username: String,
        portfolio_url: URL,
        bio: String,
        location: String,
        total_likes: Int,
        total_photos: Int,
        total_collections: Int,
        downloads: Int,
        uploads_remaining: Int,
        instagram_username: String,
        location_additional: String?,
        email: String?
    ){
        self.id = id
        self.updated_at = updated_at
        self.username = username
        self.first_name = first_name
        self.last_name = last_name
        self.twitter_username = twitter_username
        self.portfolio_url = portfolio_url
        self.bio = bio
        self.location = location
        self.total_likes = total_likes
        self.total_photos = total_photos
        self.total_collections = total_collections
        self.downloads = downloads
        self.uploads_remaining = uploads_remaining
        self.instagram_username = instagram_username
        self.location_additional = location_additional
        self.email = email
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case updated_at = "updated_at"
        case username = "username"
        case first_name = "first_name"
        case last_name = "last_name"
        case twitter_username = "twitter_username"
        case portfolio_url = "portfolio_url"
        case bio = "bio"
        case location = "location"
        case total_likes = "total_likes"
        case total_photos = "total_photos"
        case total_collections = "total_collections"
        case downloads = "downloads"
        case uploads_remaining = "uploads_remaining"
        case instagram_username = "instagram_username"
        case location_additional = ""
        case email = "email"
    }
}
