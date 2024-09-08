
import Foundation

protocol ServerConfigType {
    var apiBaseUrl: URL { get }
    var webBaseUrl: URL { get }
    var environment: EnvironmentType { get }
}

struct ServerConfig: ServerConfigType {
    
    let apiBaseUrl: URL
    let webBaseUrl: URL
    let environment: EnvironmentType
    
    static let `default`: ServerConfigType = {        
        switch EnvironmentType.current {
        case .development:
            return development
        case .staging:
            return staging
        case .production:
            return production
        }
    }()
    
    static let production: ServerConfigType = ServerConfig(
        apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.production)")!,
        webBaseUrl: URL(string: "https://\(Secrets.Web.Endpoint.production)")!,
        environment: EnvironmentType.production)
    
    static let staging: ServerConfigType = ServerConfig(
        apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.staging)")!,
        webBaseUrl: URL(string: "https://\(Secrets.Web.Endpoint.staging)")!,
        environment: EnvironmentType.staging)
    
    static let development: ServerConfigType = ServerConfig(
        apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.development)")!,
        webBaseUrl: URL(string: "https://\(Secrets.Web.Endpoint.development)")!,
        environment: EnvironmentType.development)
    
    static func config(for environment: EnvironmentType) -> ServerConfigType {
        switch environment {
        case .development:
            return ServerConfig.development
        case .staging:
            return ServerConfig.staging
        case .production:
            return ServerConfig.production
        }
    }
}
