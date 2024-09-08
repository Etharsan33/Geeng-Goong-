import Foundation
import Moya
import RxSwift

struct DynamicTarget: TargetType {
    
    let baseURL: URL
    let target: TargetType
    let headers: [String: String]?
    
    var path: String { return target.path }
    var method: Moya.Method { return target.method }
    var sampleData: Data { return target.sampleData }
    var task: Task { return target.task }
}

class ServiceProvider<Target>: MoyaProvider<DynamicTarget> where Target: TargetType {
    
    private let baseURL: URL
    private var oauthToken: OauthTokenAuthType?
    
    private static var networkLoggerPlugin: NetworkLoggerPlugin {
        let plgn = NetworkLoggerPlugin()
        plgn.configuration.logOptions = (EnvironmentType.current != .production) ? .verbose : .default
        return plgn
    }
    
    /// Same code as defaultAlamofireSession but add custom timeout
    private class func customSession() -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 45 // 45s

        return Session(configuration: configuration, startRequestsImmediately: false)
    }
    
    public init(baseURL: URL,
                oauthToken: OauthTokenAuthType? = nil,
                endpointClosure: @escaping EndpointClosure = ServiceProvider.defaultEndpointMapping,
                requestClosure: @escaping RequestClosure = ServiceProvider.defaultRequestMapping,
                stubClosure: @escaping StubClosure = ServiceProvider.neverStub,
                callbackQueue: DispatchQueue? = nil,
                session: Session = ServiceProvider.customSession(),
                plugins: [PluginType] = [ServiceProvider.networkLoggerPlugin],
                trackInflights: Bool = false) {
        self.baseURL = baseURL
        self.oauthToken = oauthToken
        super.init(
            endpointClosure: endpointClosure,
            requestClosure: requestClosure,
            stubClosure: stubClosure,
            callbackQueue: callbackQueue,
            session: session,
            plugins: plugins,
            trackInflights: trackInflights)
    }
    
    public func setOauthToken(_ token: OauthTokenAuthType?) {
        self.oauthToken = token
    }
    
    func request(_ target: TargetType) -> Observable<Moya.Response> {
        var headers: [String: String] = [:]

        if let oauthToken = oauthToken {
            headers["token"] = oauthToken.token
        }

        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        headers["app-version"] = appVersion ?? ""
        headers["device"] = "iOS"
        headers["language"] = "fr"
        
        let dynamicTarget = DynamicTarget(baseURL: baseURL, target: target, headers: headers)
        
        return Observable.create { [weak self] observer in
            let cancellableToken = self?.request(dynamicTarget) { result in
                switch result {
                case let .success(response):
                    observer.onNext(response)
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
}
