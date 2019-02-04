//
//  MainTabBarController.swift
//  boston-shows
//
//  Created by William Hughes on 4/4/18.
//  Copyright © 2018 William Hughes. All rights reserved.
//

import UIKit
import SafariServices

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var calendarModeToggle: UIBarButtonItem!
    
    var buttonCalendarMode: UIBarButtonItem!
        
    lazy var slideInTransitioningDeligate = SlideInPresentationManager()
    
    var calendarViewController: CalendarViewController!
    var favViewController: FavsTableViewController!
    
    var currentViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        attachControllers()
        buttonCalendarMode = calendarModeToggle
        settingsButton.icon(from: .FontAwesome, code: "bars", ofSize: 24)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = true
        if (currentViewController == calendarViewController) {
            showCalendarMode()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier) {
        case "VenueFilterSegue":
            let controller = segue.destination as! VenueFilterTableViewController
            controller.eventViewController = self.calendarViewController.eventViewController
        case "MainSettingsSegue":
            let controller = segue.destination as! SettingsTableViewController
            controller.mainTab = self
            slideInTransitioningDeligate.direction = .left
            controller.transitioningDelegate = slideInTransitioningDeligate
            controller.modalPresentationStyle = .custom
        default:
            return
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if (viewController == currentViewController) {
            if viewController is CalendarViewController {
                calendarViewController.calendarView.toggleCurrentDayView()
            } else if viewController is FavsTableViewController {
                favViewController.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
            }
        }
        currentViewController = viewController
    }
    
    @IBAction func toggleCalendarView(_ sender: UIBarButtonItem) {
        guard let calV = calendarViewController else {
            fatalError()
        }
        if calV.calendarView.calendarMode == .monthView {
            calV.calendarView.changeMode(.weekView)
            calV.updateWeekViewEvents(calV.selectedDay)
            sender.title = "Month"
        } else {
            calV.calendarView.changeMode(.monthView)
            calV.dayChangeRefresh(dayView: calV.selectedDay)
            sender.title = "Week"
        }
    }

    func attachControllers() {
        calendarViewController = viewControllers![0] as! CalendarViewController
        calendarViewController.mainTab = self
        favViewController = viewControllers![1] as! FavsTableViewController
        favViewController.mainTab = self
        currentViewController = viewControllers![0]
    }
    
    func showCalendarMode() {
//        self.navigationItem.rightBarButtonItem = calendarModeToggle
        calendarModeToggle = buttonCalendarMode
        self.navigationItem.rightBarButtonItem = buttonCalendarMode
    }

}

extension MainTabBarController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.navigationController?.popViewController(animated: true)
    }
}
