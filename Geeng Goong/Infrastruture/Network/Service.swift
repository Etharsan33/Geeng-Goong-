
import CoreLocation
import Foundation
import Moya
import RxSwift

class Service: ServiceType {
    
    let serverConfig: ServerConfigType
    var provider: ServiceProvider<Route>
    
    required init(serverConfig: ServerConfigType, token: OauthTokenAuthType?) {
        self.serverConfig = serverConfig
        self.provider = ServiceProvider(baseURL: serverConfig.apiBaseUrl, oauthToken: token)
    }
    
    func setOauthToken(_ token: OauthTokenAuthType?) {
        self.provider.setOauthToken(token)
    }
    
    func register(userName: String, avatarColor: String) -> Observable<RegisterResponse> {
        let target = Route.register(userName: userName, avatarColor: avatarColor)
        return provider.request(target)
            .filterSuccessfulStatusCodes()
            .map(RegisterResponse.self)
            .catchError { error in
                throw NSError.handleUnknownError(error)
            }
    }
}
