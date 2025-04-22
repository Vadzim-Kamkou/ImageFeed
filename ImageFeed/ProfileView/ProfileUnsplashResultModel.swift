import Foundation

/*:
 Unsplash Documentation
 https://unsplash.com/documentation#current-user
 Get the user’s profile  JSON
 >>>
 Optional("{
 \"id\":\"2ntxW4Z2kkI\",
 \"updated_at\":\"2025-04-18T10:12:21Z\",
 \"username\":\"vadzimkamkou\",
 \"name\":\"Vadzim Kamkou\",
 \"first_name\":\"Vadzim\",
 \"last_name\":\"Kamkou\",
 \"twitter_username\":null,
 \"portfolio_url\":null,
 \"bio\":null,
 \"location\":null,
 \"links\":{
    \"self\":\"https://api.unsplash.com/users/vadzimkamkou\",
    \"html\":\"https://unsplash.com/@vadzimkamkou\",
    \"photos\":\"https://api.unsplash.com/users/vadzimkamkou/photos\",
    \"likes\":\"https://api.unsplash.com/users/vadzimkamkou/likes\",
    \"portfolio\":\"https://api.unsplash.com/users/vadzimkamkou/portfolio\"
 },
 
 \"profile_image\":{
    \"small\":\"https://images.unsplash.com/placeholder-avatars/extra-large.jpg?ixlib=rb-4.0.3\\u0026crop=faces\\u0026fit=crop\\u0026w=32\\u0026h=32\",
    \"medium\":\"https://images.unsplash.com/placeholder-avatars/extra-large.jpg?ixlib=rb-4.0.3\\u0026crop=faces\\u0026fit=crop\\u0026w=64\\u0026h=64\",
    \"large\":\"https://images.unsplash.com/placeholder-avatars/extra-large.jpg?ixlib=rb-4.0.3\\u0026crop=faces\\u0026fit=crop\\u0026w=128\\u0026h=128\"
 },
 \"instagram_username\":null,
 \"total_collections\":0,
 \"total_likes\":0,
 \"total_photos\":0,
 \"total_promoted_photos\":0,
 \"total_illustrations\":0,
 \"total_promoted_illustrations\":0,
 \"accepted_tos\":false,
 \"for_hire\":false,
 \"social\":{
    \"instagram_username\":null,
    \"portfolio_url\":null,
    \"twitter_username\":null,
    \"paypal_email\":null},
    \"photos\":[],
    \"badge\":null,
    \"tags\":{
        \"custom\":[],
        \"aggregated\":[]
    },
    \"allow_messages\":true,
    \"numeric_id\":17980909,
    \"downloads\":0,
    \"meta\":{
        \"index\":false
    },
    \"uid\":\"2ntxW4Z2kkI\",
    \"confirmed\":true,
    \"uploads_remaining\":10,
    \"unlimited_uploads\":false,
    \"email\":\"vadzim.kamkou@gmail.com\",
    \"dmca_verification\":\"unverified\",
    \"unread_in_app_notifications\":false,
    \"unread_highlight_notifications\":false
 }")

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
    //let links: [UserProfileLinks]
    
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
        //links: [UserProfileLinks]
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
        //self.links = links
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
        //case links = "links"
    }
}
//
//struct UserProfileLinks: Codable {
//    let userLinkAPI: String?
//    let html: String?
//    let photos: String?
//    let likes: String?
//    let portfolio: String?
//    
//    init(userLinkAPI: String, html: String, photos: String, likes: String, portfolio: String) {
//        self.userLinkAPI = userLinkAPI
//        self.html = html
//        self.photos = photos
//        self.likes = likes
//        self.portfolio = portfolio
//    }
//    
//    private enum CodingKeys: String, CodingKey {
//        case userLinkAPI = "self"
//        case html = "html"
//        case photos = "photos"
//        case likes = "likes"
//        case portfolio = "portfolio"
//    }
//}
