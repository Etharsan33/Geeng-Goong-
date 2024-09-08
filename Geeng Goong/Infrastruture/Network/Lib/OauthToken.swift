import Foundation

/**
 A type that can provide oauth token authentication, i.e. a user's personal token.
 */
protocol OauthTokenAuthType {
    var token: String { get }
}

struct OauthToken: OauthTokenAuthType {
    let token: String
    
    init(token: String) {
        self.token = token
    }
}
