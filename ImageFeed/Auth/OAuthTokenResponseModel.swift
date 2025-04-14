import Foundation

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
