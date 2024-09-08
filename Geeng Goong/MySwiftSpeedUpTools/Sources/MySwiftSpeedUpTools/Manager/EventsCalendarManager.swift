//
//  EventsCalendarManager.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 04/03/2020.
//  Copyright © 2020 ELANKUMARAN Tharsan. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

typealias EventsCalendarManagerResponse = (_ result: Result<Bool, EventsCalendarManager.EventError>) -> Void

/// let event = EventsCalendarManager.Event(name: "Event", startDate: "12/03/2020", endDate: "15/03/2020")
/// EventCalendarManager().addEventToCalendarHandled(VC: self, event: event)
open class EventsCalendarManager: NSObject, EKEventEditViewDelegate {
    
    public struct Event {
        var name: String?
        var startDate: Date
        var endDate: Date
        
        public init(name: String?, startDate: Date, endDate: Date) {
            self.name = name
            self.startDate = startDate
            self.endDate = endDate
        }
    }
    
    public enum EventError: Error {
        case calendarAccessDeniedOrRestricted
        case eventNotAddedToCalendar
        case eventAlreadyExistsInCalendar
    }
    
    var eventStore: EKEventStore!
    
    public override init() {
        eventStore = EKEventStore()
    }
    
    // Request access to the Calendar
    private func requestAccess(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: .event) { (accessGranted, error) in
            completion(accessGranted, error)
        }
    }
    
    // Get Calendar auth status
    private func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    // Check Calendar permissions auth status
    // Try to add an event to the calendar if authorized
    func addEventToCalendar(event: Event, completion : @escaping EventsCalendarManagerResponse) {
        let authStatus = getAuthorizationStatus()
        switch authStatus {
        case .authorized:
            let eventToAdd = generateEvent(event: event)
            if !eventAlreadyExists(event: eventToAdd) {
                completion(.success(true))
            } else {
                completion(.failure(.eventAlreadyExistsInCalendar))
            }
        case .notDetermined:
            //Auth is not determined
            //We should request access to the calendar
            requestAccess { (accessGranted, error) in
                if accessGranted {
                    let eventToAdd = self.generateEvent(event: event)
                    if !self.eventAlreadyExists(event: eventToAdd) {
                        completion(.success(true))
                    } else {
                        completion(.failure(.eventAlreadyExistsInCalendar))
                    }
                } else {
                    // Auth denied, we should display a popup
                    completion(.failure(.calendarAccessDeniedOrRestricted))
                }
            }
        case .denied, .restricted:
            // Auth denied or restricted, we should display a popup
            completion(.failure(.calendarAccessDeniedOrRestricted))
        }
    }
    
    // Generate an event which will be then added to the calendar
    private func generateEvent(event: Event, wantDefaultAlarm: Bool = false) -> EKEvent {
        let newEvent = EKEvent(eventStore: self.eventStore)
        newEvent.calendar = self.eventStore.defaultCalendarForNewEvents
        newEvent.title = event.name
        newEvent.startDate = event.startDate
        
        if event.startDate == event.endDate {
            newEvent.isAllDay = true
            newEvent.endDate = event.startDate.addingTimeInterval(3600) // 1 hour
        } else {
            newEvent.endDate = event.endDate
        }
        
        // Set Default alarm minutes after event
        if wantDefaultAlarm {
            let alarm = EKAlarm(relativeOffset: 60*15) //15min
            newEvent.addAlarm(alarm)
        }
        
        return newEvent
    }
    
    // Try to save an event to the calendar
    private func addEvent(event: Event, completion : @escaping EventsCalendarManagerResponse) {
        let eventToAdd = generateEvent(event: event)
        if !eventAlreadyExists(event: eventToAdd) {
            do {
                try eventStore.save(eventToAdd, span: .thisEvent)
            } catch {
                // Error while trying to create event in calendar
                completion(.failure(.eventNotAddedToCalendar))
            }
            completion(.success(true))
        } else {
            completion(.failure(.eventAlreadyExistsInCalendar))
        }
    }
    
    // Check if the event was already added to the calendar
    private func eventAlreadyExists(event eventToAdd: EKEvent) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: eventToAdd.startDate, end: eventToAdd.endDate, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        
        let eventAlreadyExists = existingEvents.contains { (event) -> Bool in
            return eventToAdd.title == event.title && event.startDate == eventToAdd.startDate && event.endDate == eventToAdd.endDate
        }
        return eventAlreadyExists
    }
    
    // Show event kit ui to add event to calendar
    func presentCalendarModalToAddEvent(event: Event, completion : @escaping EventsCalendarManagerResponse) {
        let authStatus = getAuthorizationStatus()
        switch authStatus {
        case .authorized:
            completion(.success(true))
        case .notDetermined:
            //Auth is not determined
            //We should request access to the calendar
            requestAccess { (accessGranted, error) in
                if accessGranted {
                    completion(.success(true))
                } else {
                    // Auth denied, we should display a popup
                    completion(.failure(.calendarAccessDeniedOrRestricted))
                }
            }
        case .denied, .restricted:
            // Auth denied or restricted, we should display a popup
            completion(.failure(.calendarAccessDeniedOrRestricted))
        }
    }
    
    // Present edit event calendar modal
    func presentEventCalendarDetailModal(event: Event) {
        let event = generateEvent(event: event)
        let eventModalVC = EKEventEditViewController()
        eventModalVC.event = event
        eventModalVC.eventStore = eventStore
        eventModalVC.editViewDelegate = self
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(eventModalVC, animated: true, completion: nil)
        }
    }
}

// MARK: - EKEventEditViewDelegate
extension EventsCalendarManager {
    
    public func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Function handle Error & Display PopUp
extension EventsCalendarManager {
    
    public func addEventToCalendarHandled(VC: UIViewController, event: Event) {
        self.addEventToCalendar(event: event) { result in
            
            DispatchQueue.main.async { // Dispatch main for show UI
                switch result {
                    case .success:
                        self.presentEventCalendarDetailModal(event: event)
                    case .failure(let eventError):
                        switch eventError {
                        case .eventAlreadyExistsInCalendar:
                            VC.showAlert(title: MyToolsLoc.CalendarEvent.EVENT_ADDED_ALREADY_ALERT_TITLE.localized, message: MyToolsLoc.CalendarEvent.EVENT_ADDED_ALREADY_ALERT_MESSAGE.localized)
                        case .eventNotAddedToCalendar:
                            VC.showAlert(title: MyToolsLoc.CalendarEvent.EVENT_ADDED_ERROR_ALERT_TITLE.localized, message: MyToolsLoc.CalendarEvent.EVENT_ADDED_ERROR_ALERT_MESSAGE.localized)
                        case .calendarAccessDeniedOrRestricted:
                            VC.showAlert(title: MyToolsLoc.CalendarEvent.EVENT_NOT_ACCESS_ALERT_TITLE.localized, message: MyToolsLoc.CalendarEvent.EVENT_NOT_ACCESS_ALERT_MESSAGE.localized,
                                         buttons: [.title(MyToolsLoc.CalendarEvent.EVENT_NOT_ACCESS_GO_BUTTON.localized) {
                                            
                                            if let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
                                                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                                            }
                                            
                                         }, .titleWithStyle(MyToolsLoc.Global.CANCEL.localized, .cancel)])
                    }
                }
            }
            
        }
    }
}

