//
//  GeneralScheduleViewController.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//


import UIKit
import XLPagerTabStrip
import Foundation
import CoreSummit

final class GeneralScheduleViewController: ScheduleViewController, RevealViewController, IndicatorInfoProvider {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var noConnectivityView: UIView!
    
    @IBOutlet weak var retryButton: UIButton!
    
    // MARK: - Properties
    
    fileprivate(set) var filterButton: UIBarButtonItem!
    
    fileprivate(set) var activeFilterIndicator = false {
        
        didSet {
            
            filterButton?.tintColor = activeFilterIndicator ? UIColor(hexString: "#F8E71C") : UIColor.white
            navigationController?.toolbar.barTintColor = UIColor(hexString: "#F8E71C")
            navigationController?.toolbar.isTranslucent = false
            navigationController?.setToolbarHidden(!activeFilterIndicator, animated: !activeFilterIndicator)
        }
    }
    
    fileprivate var filterObserver: Int?
    
    // MARK: - Loading
    
    deinit {
        
        if let observer = filterObserver { FilterManager.shared.filter.remove(observer) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMenuButton()
        
        navigationItem.title = "EVENTS"
        
        filterButton = UIBarButtonItem()
        filterButton.target = self
        filterButton.action = #selector(showFilters)
        filterButton.image = R.image.filter()!
        
        navigationItem.rightBarButtonItem = filterButton
        
        let message = UIBarButtonItem()
        message.title = "CLEAR ACTIVE FILTERS"
        message.style = .plain
        message.target = self
        message.action = #selector(clearFilters)
        message.tintColor = UIColor(hexString: "#4A4A4A")
        message.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 15)], for: UIControlState())
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(clearFilters))
        
        let clear = UIBarButtonItem()
        clear.target = self
        clear.action = #selector(clearFilters)
        clear.image = R.image.cancel()!
        clear.tintColor = UIColor.black
        
        toolbarItems = [message, spacer, clear]
        
        filterObserver = FilterManager.shared.filter.observe(filterChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activeFilterIndicator = FilterManager.shared.filter.value.active
        
        userActivity?.becomeCurrent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isToolbarHidden = true
        
        userActivity?.resignCurrent()
    }
    
    override func updateUserActivityState(_ userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.events.rawValue]
        
        userActivity.addUserInfoEntries(from: userInfo as [AnyHashable: Any])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Actions
    
    @IBAction func showFilters(_ sender: UIBarButtonItem) {
        
        guard isDataLoaded else {
            
            showInfoMessage("Info", message: "No summit data available")
            return
        }
        
        let generalScheduleFilterViewController = R.storyboard.scheduleFilter.generalScheduleFilterViewController()!
        let navigationController = UINavigationController(rootViewController: generalScheduleFilterViewController)
        navigationController.modalPresentationStyle = .formSheet
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func clearFilters(_ sender: UIBarButtonItem) {
        
        FilterManager.shared.filter.value.clear()
    }
    
    @IBAction func retryButtonPressed(_ sender: UIButton) {
        
        loadData()
    }
    
    // MARK: - Methods
    
    override func toggleEventList(_ show: Bool) {
        
        scheduleView!.isHidden = !show
    }
    
    override func toggleNoConnectivityMessage(_ show: Bool) {
        
        noConnectivityView!.isHidden = !show
    }
    
    internal override func loadData() {
        
        if try! Store.shared.managedObjectContext.managedObjects(Summit).isEmpty
            && Reachability.connected == false {
            
            self.toggleNoConnectivityMessage(true)
            self.toggleEventList(false)
            return
        }
        
        if let summit = self.currentSummit {
            
            // set user activity for handoff
            let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
            userActivity.title = "Summit Schedule"
            userActivity.webpageURL = Foundation.URL(string: summit.webpageURL + "/summit-schedule")
            userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.events.rawValue]
            userActivity.requiredUserInfoKeys = [AppActivityUserInfo.screen.rawValue]
            
            self.userActivity = userActivity
        }
        
        self.toggleNoConnectivityMessage(false)
        self.toggleEventList(true)
        
        super.loadData()
    }
    
    override func scheduleAvailableDates(from startDate: Foundation.Date, to endDate: Foundation.Date) -> [Foundation.Date] {
        
        let scheduleFilter = FilterManager.shared.filter.value
        let summit = SummitManager.shared.summit.value
        
        var trackGroups = [Identifier]()
        var venues = [Identifier]()
        var levels = [String]()
        
        for filter in scheduleFilter.activeFilters {
            
            switch filter {
            case let .trackGroup(identifier): trackGroups.append(identifier)
            case let .venue(identifier): venues.append(identifier)
            case let .level(name): levels.append(name)
            case .activeTalks: break
            }
        }
        
        let date = DateFilter.interval(start: Date(foundation: startDate), end: Date(foundation: endDate))
        
        let events = try! EventManagedObject.filter(date, tracks: nil, trackGroups: trackGroups, levels: levels, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
        var activeDates: [Foundation.Date] = []
        for event in events {
            let timeZone = NSTimeZone(name: event.summit.timeZone)!
            let startDate = event.start.mt_dateSecondsAfter(timeZone.secondsFromGMT).mt_startOfCurrentDay()
            if !activeDates.contains(startDate) {
                activeDates.append(startDate)
            }
            
        }
        return activeDates
    }
    
    override func scheduledEvents(_ filter: DateFilter) -> [ScheduleItem] {
        
        let scheduleFilter = FilterManager.shared.filter.value
        let summit = SummitManager.shared.summit.value
        
        var trackGroups = [Identifier]()
        var venues = [Identifier]()
        var levels = [String]()
        
        for filter in scheduleFilter.activeFilters {
            
            switch filter {
            case let .trackGroup(identifier): trackGroups.append(identifier)
            case let .venue(identifier): venues.append(identifier)
            case let .level(name): levels.append(name)
            case .activeTalks: break
            }
        }
        
        let events = try! EventManagedObject.filter(filter, tracks: nil, trackGroups: trackGroups, levels: levels, venues: venues, summit: summit, context: Store.shared.managedObjectContext)
        
        return ScheduleItem.from(managedObjects: events)
    }
    
    // MARK: - Private Methods
    
    fileprivate func filterChanged(_ filter: ScheduleFilter, oldValue: ScheduleFilter) {
        
        if self.navigationController?.topViewController === self {
            
            self.activeFilterIndicator = filter.active
        }
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfoForPagerTabStrip(_ pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        
        return IndicatorInfo(title: "Schedule")
    }
}
