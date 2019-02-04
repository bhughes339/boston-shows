//
//  RsvpTableViewController.swift
//  boston-shows
//
//  Created by William Hughes on 4/5/18.
//  Copyright © 2018 William Hughes. All rights reserved.
//

import UIKit

class FavsTableViewController: UITableViewController {

    var mainTab: MainTabBarController!
    var eventTableViewController: EventTableViewController!
    private var favEvents = [String: [SingleEvent]]()
    private var eventDates = [String]()
    private var formatter = DateFormatter()
    private var sectionHeaderFrameHeight: CGFloat!
    @IBOutlet var sectionHeaderView: UIView!
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Bundle.main.loadNibNamed("FavsTableSectionView", owner: self, options: nil)
        sectionHeaderFrameHeight = sectionHeaderView.frame.height
        formatter.dateFormat = "yyyy-MM"
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainTab.navigationItem.title = "Favorite Shows"
        getFavs()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return favEvents.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favEvents[eventDates[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FavTableCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FavsTableViewCell else {
            fatalError("The dequeued cell is not an instance of \(cellIdentifier).")
        }

        let cellEvent = favEvents[eventDates[indexPath.section]]![indexPath.row]
        cell.eventObject = cellEvent
        cell.dayOfWeekLabel.text = cellEvent.startTime.dateToFormat(format: "E")
        cell.dayLabel.text = cellEvent.startTime.dateToFormat(format: "dd")
        cell.bandsLabel.attributedText = Helper.bandArrayFormat(bands: cellEvent.bands, size: cell.bandsLabel.font.pointSize)
        let timeFormat = (cellEvent.startTime.dateToFormat(format: "m") == "0") ? "ha" : "h:mma"
        let timeString = cellEvent.startTime.dateToFormat(format: timeFormat).lowercased()
        cell.timeVenueLabel.text = "\(timeString) at \(cellEvent.venue)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FavsTableViewCell
        if let eventLink = cell.eventObject.link, navigationController != nil {
            Helper.showSafariFromView(url: URL(string: eventLink)!, view: navigationController!, delegate: mainTab)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        Bundle.main.loadNibNamed("FavsTableSectionView", owner: self, options: nil)
        let sectionFormatter = DateFormatter()
        sectionFormatter.dateFormat = "yyyy-MM"
        guard let sectionDate = sectionFormatter.date(from: eventDates[section]) else {
            fatalError("FavsTable date key incorrect")
        }
        sectionFormatter.dateFormat = "MMMM yyyy"
        sectionHeaderLabel.text = sectionFormatter.string(from: sectionDate)
        return sectionHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderFrameHeight
    }
    
    func getFavs() {
        guard let eventView = eventTableViewController else {
            fatalError("Event Table error")
        }
        favEvents.removeAll()
        let userFavs = eventView.userFavs
        let nowDate = Date()
        for i in userFavs {
            if (i.startTime < nowDate) {
                continue
            }
            let eventDate = formatter.string(from: i.startTime)
            if favEvents[eventDate] != nil {
                favEvents[eventDate]!.append(i)
                favEvents[eventDate]!.sort { $0.startTime < $1.startTime }
            } else {
                favEvents[eventDate] = [i]
            }
        }
        eventDates = Array(favEvents.keys).sorted()
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
