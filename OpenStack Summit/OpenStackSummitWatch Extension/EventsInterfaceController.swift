//
//  EventsInterfaceController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import WatchKit
import Foundation
import CoreSummit

final class EventsInterfaceController: WKInterfaceController {
    
    static let identifier = "Events"
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    // MARK: - Properties
    
    fileprivate(set) var events = [Event]()
    
    fileprivate static let dateFormatter: DateFormatter = {
       
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(name: Store.shared.cache!.timeZone)
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
    
    // MARK: - Loading
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        events = (context as? Context<[Event]?>)?.value ?? Store.shared.cache!.schedule.sort()
        
        updateUI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        /// set user activity
        if let summit = Store.shared.cache {
            
            updateUserActivity(AppActivity.screen.rawValue, userInfo: [AppActivityUserInfo.screen.rawValue: AppActivityScreen.events.rawValue], webpageURL: URL(string: summit.webpageURL + "/summit-schedule"))
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        invalidateUserActivity()
    }
    
    // MARK: - Private Methods
    
    fileprivate func updateUI() {
        
        // configure cells
        
        tableView.setNumberOfRows(events.count, withRowType: EventCellController.identifier)
        
        for (index, event) in events.enumerate() {
            
            let cell = tableView.rowControllerAtIndex(index) as! EventCellController
            
            let dateText = EventsInterfaceController.dateFormatter.stringFromDate(event.start.toFoundation())
            let locationText = EventDetail.getLocation(event, summit: Store.shared.cache!)
            
            cell.nameLabel.setText(event.name)
            cell.dateLabel.setText(" " + dateText)
            cell.locationLabel.setText(locationText)
            cell.locationGroup.setHidden(locationText.isEmpty)
        }
    }
    
    // MARK: - Segue
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        let event = events[rowIndex]
        
        return Context(event)
    }
}

// MARK: - Supporting Types

final class EventCellController: NSObject {
    
    static let identifier = "EventCell"
    
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var dateLabel: WKInterfaceLabel!
    @IBOutlet weak var locationLabel: WKInterfaceLabel!
    @IBOutlet weak var locationGroup: WKInterfaceGroup!
}
