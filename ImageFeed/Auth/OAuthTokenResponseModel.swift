import Foundation

//{
//    \"access_token\":\"bdnmgen0YruxtsKNaBzem8WoNuE1FlHhXSAwcVQXkd8\",
//    \"token_type\":\"Bearer\",
//    \"refresh_token\":\"MQ6ZZ0d-RrfgrkC7bWhkD4WLeyuhz2PRQbnPN9DCgYM\",
//    \"scope\":\"public read_user write_likes\",
//    \"created_at\":1743798061,
//    \"user_id\":17980909,
//    \"username\":\"vadzimkamkou\"
//}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let refreshToken: String
    let scope: String
    let createdAt: Date
    let userId: Int
    let username: String

    init(accessToken: String, tokenType: String, refreshToken: String, scope: String, createdAt: Date, userId: Int, username: String) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.refreshToken = refreshToken
        self.scope = scope
        self.createdAt = createdAt
        self.userId = userId
        self.username = username
    }
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case scope = "scope"
        case createdAt = "created_at"
        case userId = "user_id"
        case username = "username"
    }
}
