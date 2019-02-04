//
//  ViewController.swift
//  boston-shows
//
//  Created by William Hughes on 3/28/18.
//  Copyright © 2018 William Hughes. All rights reserved.
//

import UIKit
import CVCalendar
import SwiftIconFont

class CalendarViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var dayLabel: UILabel!
    
    private var mainNavBar: UINavigationItem!
    var mainTab: MainTabBarController!
    
    private var currentCalendar: Calendar! = Calendar(identifier: .gregorian)
    var selectedDay: DayView!
    var weekRange: (Date, Date)?
    var eventViewController: EventTableViewController!
    var favViewController: FavsTableViewController!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favViewController = mainTab.favViewController
        eventViewController.mainTab = mainTab
        mainNavBar = mainTab.navigationItem
        mainNavBar.title = CVDate(date: Date(), calendar: currentCalendar).globalDescription
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedDay = self.selectedDay {
            self.dayChangeRefresh(dayView: selectedDay)
            mainNavBar.title = selectedDay.date.globalDescription
        }
        mainTab.buttonCalendarMode.title = (calendarView.calendarMode == .monthView) ? "Week" : "Month"
        mainTab.showCalendarMode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mainNavBar.rightBarButtonItem = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier) {
        case "EventTableSegue":
            self.eventViewController = segue.destination as! EventTableViewController
            self.mainTab.favViewController.eventTableViewController = self.eventViewController
            fetchData()
        default:
            return
        }
    }
}

extension CalendarViewController {
    func fetchData() {
        let url = URL(string: "https://whughes.co/concerts/events.json")!
        let loadingView = UIView(frame: navigationController!.view.frame)
        loadingView.backgroundColor = UIColor.white
        navigationController!.view.addSubview(loadingView)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                return
            }
            if let data = data {
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any] else { return }
                DispatchQueue.main.sync {
                    var userFavsSet = Set<Int>()
                    if let favArray = UserDefaults.standard.object(forKey: "favsList") as? [Int] {
                        userFavsSet = Set(favArray)
                    }
                    var userFavsEvents = Set<SingleEvent>()
                    var allEvents = Set<SingleEvent>()
                    var venueFilter = [String: Bool]()
                    for i in json! {
                        if let object = i as? [String: Any] {
                            guard let eventStart = object["datetime"] as? String else { continue }
                            guard let eventVenue = object["venue"] as? String else { continue }
                            guard let eventBands = object["bands"] as? [String] else { continue }
                            let eventLink = object["link"] as? String ?? ""
                            let eventSoldout = object["soldout"] as? Bool ?? false
                            let event = SingleEvent(startTime: ISO8601DateFormatter().date(from: eventStart)!, venue: eventVenue, bands: eventBands, link: eventLink, soldout: eventSoldout)
                            allEvents.insert(event)
                            if userFavsSet.contains(event.hashValue) {
                                userFavsEvents.insert(event)
                            }
                            venueFilter[eventVenue] = true
                        }
                    }
                    self.eventViewController.allEvents = allEvents
                    self.eventViewController.userFavs = userFavsEvents
                    self.eventViewController.allEventsDateSet = Set(allEvents.compactMap { $0.startTime.dateToFormat(format: "yyyy-MM-dd") })
                    if let userVenues = UserDefaults.standard.object(forKey: "venueFilter") as? [String: Bool] {
                        for v in venueFilter.keys {
                            venueFilter[v] = userVenues[v] ?? true
                        }
                    }
                    UserDefaults.standard.set(venueFilter, forKey: "venueFilter")
                    self.eventViewController.venueFilter = venueFilter
                    if let selectedDay = self.selectedDay {
                        self.dayChangeRefresh(dayView: selectedDay)
                    }
                    if let calV = self.calendarView {
                        calV.changeMode(.weekView) {
                            calV.changeMode(.monthView) {
                                loadingView.removeFromSuperview()
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
}

// MARK: - CVCalendarViewDelegate & CVCalendarMenuViewDelegate

extension CalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    // MARK: Required methods
    
    func presentationMode() -> CalendarMode { return .monthView }
    
    func firstWeekday() -> Weekday { return .sunday }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool { return true }
    
    func shouldScrollOnOutDayViewSelection() -> Bool { return calendarView.calendarMode == .monthView }
    
    //    func shouldSelectDayView(_ dayView: DayView) -> Bool {
    //        if let eventView = eventViewController {
    //            let dateString = dayView.date.convertedDate()!.dateToFormat(format: "yyyy-MM-dd")
    //            return eventView.allEventsDateSet.contains(dateString)
    //        } else {
    //            return false
    //        }
    //    }
    
    func shouldSelectRange() -> Bool { return false }
    
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        self.selectedDay = dayView
        if let weekV = dayView.weekView, let dayV = weekV.dayViews {
            if (dayV.count > 0) {
                weekRange = (dayV.first!.date.convertedDate()!,
                             dayV.last!.date.convertedDate()!)
            }
        }
        if let calendarV = calendarView {
            if calendarV.calendarMode == .monthView {
                dayChangeRefresh(dayView: dayView)
            } else {
                updateWeekViewEvents(dayView)
            }
        } else {
            dayChangeRefresh(dayView: dayView)
        }
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        mainNavBar.title = date.globalDescription
    }
    
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        let dateKey = dayView.date.toFormat(format: "yyyy-MM-dd")
        if let eventViewController = eventViewController {
            let favsMap = eventViewController.userFavs.map { $0.startTime.dateToFormat(format: "yyyy-MM-dd") }
            return favsMap.contains(dateKey)
        } else {
            return false
        }
    }
    
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        return [UIColor.init(red: 0, green: 0.5, blue: 1, alpha: 1)]
    }
    
    // MARK: Custom methods
    
    func dayChangeRefresh(dayView: DayView) {
        if let eventViewController = self.eventViewController {
            if let dateObject = dayView.date.convertedDate() {
                eventViewController.fetchEvents(startDate: dateObject, endDate: dateObject)
            }
        }
        if (self.dayLabel) != nil {
            self.dayLabel.text = dayView.date.toFormat(format: "EEEE, MMM d")
        }
    }
    
    func updateWeekViewEvents(_ dayView: DayView) {
        if let weekRange = weekRange {
            eventViewController.fetchEvents(startDate: weekRange.0, endDate: weekRange.1)
            eventViewController.scrollToDate(date: dayView.date.convertedDate()!)
        }
    }
    
    @objc func toggleCalendarView(_ sender: UIBarButtonItem) {
        if calendarView.calendarMode == .monthView {
            calendarView.changeMode(.weekView)
            updateWeekViewEvents(selectedDay)
            sender.title = "Month"
        } else {
            calendarView.changeMode(.monthView)
            dayChangeRefresh(dayView: selectedDay)
            sender.title = "Week"
        }
    }
}
