import Foundation

/*:
 Unsplash Documentation Get the user’s profile JSON
 https://unsplash.com/documentation#current-user
 */

struct profileResult: Codable {
    let username: String?
    let first_name: String?
    let last_name: String?
    let bio: String?
    
    init(
        username: String,
        first_name: String,
        last_name: String,
        bio: String
    ){
        self.username = username
        self.first_name = first_name
        self.last_name = last_name
        self.bio = bio
    }
    
    private enum CodingKeys: String, CodingKey {
        case username = "username"
        case first_name = "first_name"
        case last_name = "last_name"
        case bio = "bio"
    }
}
