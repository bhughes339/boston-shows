//
//  Helper.swift
//  boston-shows
//
//  Created by William Hughes on 4/7/18.
//  Copyright © 2018 William Hughes. All rights reserved.
//

import Foundation
import UIKit
import CVCalendar
import SafariServices

class Helper {
    static func bandArrayFormat(bands: [String], size: CGFloat) -> NSAttributedString {
        let boldAttrs = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: size)]
        var bandsArray = bands
        let headliner = bandsArray.remove(at: 0)
        let titleString = NSMutableAttributedString(string: headliner, attributes: boldAttrs)
        if bandsArray.count > 0 {
            let supporters = bandsArray.joined(separator: " • ")
            titleString.append(NSAttributedString(string: " • \(supporters)"))
        }
        return titleString
    }
    
    static func showSafariFromView(url: URL, view: UIViewController, delegate: Any) {
        let safariOptions = SFSafariViewController.Configuration()
        safariOptions.barCollapsingEnabled = true
        let safariController = SFSafariViewController(url: url, configuration: safariOptions)
        safariController.delegate = delegate as? SFSafariViewControllerDelegate
        view.showDetailViewController(safariController, sender: view)
    }
    
    static func convertStringDateFormat(dateString: String, from: String, to: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = from
        let date = formatter.date(from: dateString)
        formatter.dateFormat = to
        return formatter.string(from: date!)
    }
}

extension Date {
    public func getSingleDayRange(calendar: Calendar = Calendar(identifier: .gregorian)) -> (Date, Date) {
        let tomorrow = Date(timeInterval: 86400, since: self)
        return (calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self)!, calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow)!)
    }
    
    public func dateToFormat(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension CVDate {
    public func toFormat(format: String) -> String {
        let date = self.convertedDate()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date!)
    }
}

