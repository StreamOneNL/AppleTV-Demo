//
//  NSDate+Decodable.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 09-01-16.
//  Copyright © 2016 StreamOne. All rights reserved.
//

import Foundation
import Argo

extension String {
    /// Helper function to convert a string into a NSDate for a given format
    private func timeStringToDate(formatString: String) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = formatString
        return formatter.dateFromString(self)
    }

    /// converts a string representing a date in the API format to NSDate
    var apiDateStringToDate: NSDate? {
        if self.characters.count == 19 {
            return timeStringToDate("yyyy-MM-dd HH:mm:ss")
        }
        return nil
    }

    /// Convert a date string into a display date using the Dutch locale
    var displayDate: String? {
        return apiDateStringToDate?.displayDate
    }
}

extension NSDate {
    /// Format a date usin a format and a locale
    private func dateToTimeStringInLocale(locale: NSLocale) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .ShortStyle
        formatter.locale = locale
        return formatter.stringFromDate(self)
    }

    /// Convert a date into a display date using the Dutch locale
    var displayDate: String {
        return self.dateToTimeStringInLocale(NSLocale(localeIdentifier: "nl"))
    }
}