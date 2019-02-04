//
//  EventTableViewController.swift
//  boston-shows
//
//  Created by William Hughes on 3/29/18.
//  Copyright © 2018 William Hughes. All rights reserved.
//

import UIKit
import SafariServices

class EventTableViewController: UITableViewController {
    
    var mainTab: MainTabBarController!
    var allEvents = Set<SingleEvent>()
    var allEventsDateSet = Set<String>()
    var currentEvents = [SingleEvent]()
    var datesForCurrentEvents = [String: Bool]()
    var venueFilter = [String: Bool]()
    var userFavs = Set<SingleEvent>()
    var dateEventDict = [String: [SingleEvent]]()
    var dateKeys = [String]()
    
    let favStarColor = UIColor.init(red: 1, green: 0.8, blue: 0, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.clear

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dateEventDict.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateEventDict[dateKeys[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Helper.convertStringDateFormat(dateString: dateKeys[section], from: "yyyy-MM-dd", to: "EEEE, MMM d")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SingleEventTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SingleEventTableViewCell else {
            fatalError("The dequeued cell is not an instance of \(cellIdentifier).")
        }
//        let singleEvent = currentEvents[indexPath.row]
        let singleEvent = dateEventDict[dateKeys[indexPath.section]]![indexPath.row]
        cell.eventObject = singleEvent
        cell.eventDescription.text = singleEvent.venue
        if singleEvent.soldout == true {
            let stringAttrs = [NSAttributedStringKey.strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue]
            cell.eventTitle.attributedText = NSAttributedString(string: singleEvent.bands.joined(separator: " • "),
                                                                attributes: stringAttrs)
            cell.eventTitle.textColor = UIColor.gray
            cell.eventDescription.text?.append(" (SOLD OUT)")
        } else {
            cell.eventTitle.attributedText = Helper.bandArrayFormat(bands: singleEvent.bands, size: cell.eventTitle.font.pointSize)
            cell.eventTitle.textColor = UIColor.black
        }
        cell.favButton.eventObject = singleEvent
        cell.favButton.addTarget(self, action: #selector(didTapFav(_:)), for: UIControlEvents.touchUpInside)
        cell.favButton.setTitleColor((userFavs.contains(singleEvent)) ? favStarColor : UIColor.gray, for: UIControlState.normal)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SingleEventTableViewCell
        if let eventLink = cell.eventObject.link, navigationController != nil {
            Helper.showSafariFromView(url: URL(string: eventLink)!, view: navigationController!, delegate: mainTab)
        }
    }
    
    func fetchEvents(startDate: Date, endDate: Date) {
        var newEvents = [SingleEvent]()
        var newDates = [String: Bool]()
        var newDateDict = [String: [SingleEvent]]()
        let calendar = Calendar(identifier: .gregorian)
        let fixStartDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)
        let fixEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        for event in self.allEvents {
            if (self.venueFilter[event.venue]!) {
                if (fixStartDate! <= event.startTime && event.startTime <= fixEndDate!) {
                    let dateString = event.startTime.dateToFormat(format: "yyyy-MM-dd")
                    newEvents.append(event)
                    newDates[formatter.string(from: event.startTime)] = true
                    if newDateDict[dateString] != nil {
                        newDateDict[dateString]!.append(event)
                    } else {
                        newDateDict[dateString] = [event]
                    }
                }
            }
        }
        for i in newDateDict.keys {
            let _ = newDateDict[i]!.partition(by: { $0.soldout ?? false })
            let _ = newDateDict[i]!.partition(by: { !userFavs.contains($0) })
        }
        let _ = newEvents.partition(by: { $0.soldout ?? false })
        let _ = newEvents.partition(by: { !userFavs.contains($0) })
        self.currentEvents = newEvents
        self.datesForCurrentEvents = newDates
        self.dateEventDict = newDateDict
        self.dateKeys = Array(newDateDict.keys).sorted()
        self.tableView.reloadData()
    }
    
    func fetchEvents() {
        if let dateRange = mainTab.calendarViewController.selectedDay.date.convertedDate()?.getSingleDayRange() {
            fetchEvents(startDate: dateRange.0, endDate: dateRange.1)
        }
    }
    
    func scrollToDate(date: Date) {
        let dateString = date.dateToFormat(format: "yyyy-MM-dd")
        if let section = dateKeys.index(of: dateString) {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: UITableViewScrollPosition.top, animated: false)
        }
    }
    
    @objc func didTapFav(_ sender: Any) {
        guard let favButton = sender as? EventCellFavButton else {
            fatalError("EventCellFavButton issue.")
        }
        if let event = favButton.eventObject {
            if userFavs.contains(event) {
                userFavs.remove(event)
                favButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
            } else {
                userFavs.insert(event)
                favButton.setTitleColor(favStarColor, for: UIControlState.normal)
            }
            let userFavHashes = userFavs.map { $0.hashValue }
            UserDefaults.standard.set(userFavHashes, forKey: "favsList")
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
