//
//  Date+Extension.swift
//  MySwiftSpeedUpTools
//
//  Created by ELANKUMARAN Tharsan on 15/04/2019.
//  Copyright © 2019 ELANKUMARAN Tharsan. All rights reserved.
//

import Foundation

public extension Date {
    
    /// dd Date formatter
    static let ddFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "CEST")
        formatter.dateFormat = "dd"
        return formatter
    }()
    
    var day: String {
        return Date.ddFormatter.string(from: self)
    }
    
    /// EEEE Date formatter
    static let EEEEFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "CEST")
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    var weekDay: String {
        return Date.EEEEFormatter.string(from: self)
    }
    
    /// HHmmss Date formatter
    static let HHmmssFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "CEST")
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    var HHmmss: String {
        return Date.HHmmssFormatter.string(from: self)
    }
    
    /// dd/MM/yyyy Date formatter
    static let ddMMyyyySeparatedBySlashFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "CEST")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    var ddMMyyyySeparatedBySlash: String {
        return Date.ddMMyyyySeparatedBySlashFormatter.string(from: self)
    }
    
    /// iso8601 Date formatter
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    /// short Date formatter
    static let shortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    
    /// Date as String formatted with iso8601 format
    var iso8601: String {
        return Date.iso8601Formatter.string(from: self)
    }
    
    /// Date as String formatted with short format
    var shortStyle: String {
        return Date.shortFormatter.string(from: self)
    }
    
    /// dd MMMM yyyy Date formatter
    static let ddMMMMyyyyFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "CEST")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    var ddMMMMyyyy: String {
        return Date.ddMMMMyyyyFormatter.string(from: self)
    }
}
