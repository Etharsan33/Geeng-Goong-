
import Foundation
import Moya

extension Route: TargetType {
    
    var headers: [String: String]? {
        return nil
    }
    
    var baseURL: URL {
        // swiftlint:disable force_unwrapping
        return Foundation.URL(string: "http://dummy.fr")!
        // swiftlint:enable force_unwrapping
    }
    
    // MARK: - Service
    var service: String {
        switch self {
        default:
            return "/"
        }
    }
    
    // MARK: - Path
    var path: String {
        var path: String = service
        
        switch self {
        case .register:
            path += "users/register"
        }
        return path
    }
    
    var URL: Foundation.URL? {
        return Foundation.URL(string: "\(baseURL)\(path)")
    }
    
    // MARK: - Method
    var method: Moya.Method {
        switch self {
        case .register:
            return .post
        default:
            return .get
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    // MARK: - Task
    public var task: Task {
        if let multipartBody = multipartBody {
            return .uploadMultipart(multipartBody)
        }
        if let parameters = parameters {
            if let urlParameters = urlParameters {
                return .requestCompositeParameters(
                    bodyParameters: parameters,
                    bodyEncoding: JSONEncoding.default,
                    urlParameters: urlParameters)
            }
            return .requestParameters(parameters: parameters, encoding: parameterEncoding)
        }
        return .requestPlain
    }
    
    // MARK: - Query Params
    var urlParameters: [String: Any]? {
        switch self {
        default:
            break
        }
        return nil
    }
    
    // MARK: - Params
    var parameters: [String: Any]? {
        switch self {
        case .register(let userName, let avatarColor):
            return ["userName" : userName, "avatarColor": avatarColor]
        default:
            return nil
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    // MARK: - Multipart Body
    var multipartBody: [MultipartFormData]? {
        switch self {
        default:
            return nil
        }
    }
}

// MARK: - Helper

private func multipartFormData(from dictionary: [String: String?]) -> [MultipartFormData] {
    var formData: [MultipartFormData] = []
    dictionary.forEach {
        if let value = $0.value, let data = value.data(using: .utf8) {
            formData.append(MultipartFormData(provider: .data(data), name: $0.key))
        }
    }
    return formData
}

private func multipartFormData(from pictureData: Data) -> MultipartFormData {
    return MultipartFormData(
        provider: .stream(InputStream(data: pictureData), UInt64(pictureData.count)),
        name: "picture",
        fileName: "\(UUID().uuidString).jpg",
        mimeType: "image/jpg")
}

private func multiparFormData(from pictures: [UIImage]) -> [MultipartFormData] {
    var formData: [MultipartFormData] = []
    pictures.enumerated()
        .forEach { index, image in
            if let data = image.jpegData(compressionQuality: 0.75) {
                formData.append(MultipartFormData(
                    provider: .stream(InputStream(data: data), UInt64(data.count)),
                    name: "picture_\(index + 1)",
                    fileName: "\(UUID().uuidString).jpg",
                    mimeType: "image/jpg"))
            }
    }
    return formData
}

private extension Dictionary where Key == String, Value == Any? {
    
    func filterEmptyAndOptional() -> [String: Any] {
        var params: [String: Any] = [:]
        self.forEach { key, object in
            if let object = object {
                if let string = object as? String {
                    if !string.isEmpty {
                        params[key] = object
                    }
                } else if let array = object as? Array<Any> {
                    if !array.isEmpty {
                        params[key] = object
                    }
                }
                else {
                    params[key] = object
                }
            }
        }
        return params
    }
}
