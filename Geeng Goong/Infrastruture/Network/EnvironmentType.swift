
import Foundation

enum EnvironmentType: String {

    static let allCases: [EnvironmentType] = [.production, .staging, .development]

    case production = "Production"
    case staging = "Staging"
    case development = "Development"
}

extension EnvironmentType {

    /// Current environment loaded from Info.plist file.
    static var current: EnvironmentType = {
        guard
            let env = Bundle.main.object(forInfoDictionaryKey: "GeengGoongEnvironment") as? String,
            let envType = EnvironmentType(rawValue: env)
            else {
                print("GeengGoongEnvironment not defined in Info.plist")
                return .production
        }
        return envType
    }()
}
