//
//  VenueFilterTableViewController.swift
//  boston-shows
//
//  Created by William Hughes on 3/31/18.
//  Copyright © 2018 William Hughes. All rights reserved.
//

import UIKit
import BEMCheckBox

class VenueFilterTableViewController: UITableViewController {

    var eventViewController: EventTableViewController?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = true
        if let eventViewController = self.eventViewController {
            UserDefaults.standard.set(eventViewController.venueFilter, forKey: "venueFilter")
            eventViewController.fetchEvents()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func venueSelectAll(_ sender: Any) {
        if var venueFilter = eventViewController?.venueFilter {
            for i in venueFilter {
                venueFilter[i.key] = true
            }
            eventViewController?.venueFilter = venueFilter
            self.tableView.reloadData()
        }
    }
    
    @IBAction func venueSelectNone(_ sender: Any) {
        if var venueFilter = eventViewController?.venueFilter {
            for i in venueFilter {
                venueFilter[i.key] = false
            }
            eventViewController?.venueFilter = venueFilter
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventViewController?.venueFilter.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "VenueFilterTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? VenueFilterTableViewCell else {
            fatalError("The dequeued cell is not an instance of \(cellIdentifier).")
        }
        
        let singleVenue = eventViewController!.venueFilter.keys.sorted()[indexPath.row]
        cell.setVenue(venue: singleVenue)
        cell.cellCheckBox.on = eventViewController!.venueFilter[singleVenue]!

        return cell
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

extension VenueFilterTableViewController: BEMCheckBoxDelegate {
    
    func didTap(_ checkBox: BEMCheckBox) {
        let venueCheckBox = checkBox as! VenueFilterTableViewCellCheckbox
        if let eventViewController = self.eventViewController {
            eventViewController.venueFilter[venueCheckBox.venueText!] = checkBox.on
        }
    }
}
