
import Foundation
import CoreLocation
import RxSwift

protocol BaseService {
    var serverConfig: ServerConfigType { get }
    
    init(serverConfig: ServerConfigType, token: OauthTokenAuthType?)
    func setOauthToken(_ token: OauthTokenAuthType?)
}

protocol ServiceType: BaseService {
    func register(userName: String, avatarColor: String) -> Observable<RegisterResponse>
}
