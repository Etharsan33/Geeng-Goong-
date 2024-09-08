
import Foundation

enum Secrets {
    enum Api {
        enum Endpoint {
            static let production = "" // Put a server test
            static let staging = "" // Put a server test
            static let development = "" // Put a server test
        }

        enum Picture {
            static let development = "dev-images.fr"
            static let staging = "stage-images.fr"
            static let production = "images.fr"
        }
    }
    
    enum Web {
        enum Endpoint {
            static let production = "mobile.com"
            static let staging = "mobile.fr"
            static let development = "mobile.fr"
        }
    }
}
