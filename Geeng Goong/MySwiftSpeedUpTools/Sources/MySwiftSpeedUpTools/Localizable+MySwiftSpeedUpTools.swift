import Foundation

public typealias MyToolsLoc = MySwiftSpeedUpToolsLocalizable

public enum MySwiftSpeedUpToolsLocalizable {
    
    // MARK: - Global
    public enum Global: String, LocalizableProtocol {
        case ALERT_ERROR_DEFAULT_TITLE
        case ALERT_ERROR_DEFAULT_MESSAGE
        case OK
        case CANCEL
        case TRY_AGAIN
        case DONE
    }
    
    // MARK: - CalendarEvent
    enum CalendarEvent: String, LocalizableProtocol {
        case EVENT_ADDED_ALREADY_ALERT_TITLE
        case EVENT_ADDED_ALREADY_ALERT_MESSAGE
        case EVENT_ADDED_ERROR_ALERT_TITLE
        case EVENT_ADDED_ERROR_ALERT_MESSAGE
        case EVENT_NOT_ACCESS_ALERT_TITLE
        case EVENT_NOT_ACCESS_ALERT_MESSAGE
        case EVENT_NOT_ACCESS_GO_BUTTON
    }
    
    // MARK: - Mail
    enum Mail : String, LocalizableProtocol {
        case ALERT_CAN_NOT_SEND_MAIL_TITLE
        case ALERT_CAN_NOT_SEND_MAIL_MESSAGE
    }
}
