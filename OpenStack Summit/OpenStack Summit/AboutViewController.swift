//
//  AboutViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/07/17.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreSummit
import Predicate
import MessageUI

final class AboutViewController: UITableViewController, RevealViewController, EmailComposerViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet var wirelessNetworksHeaderView: UIView!
    
    @IBOutlet var wirelessNetworksFooterView: UIView!
    
    // MARK: - Properties
    
    private var summitCache: Summit?
    
    private var sections = [Section]()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMenuButton()
        
        // setup table view
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // set user activity for handoff
        let userActivity = NSUserActivity(activityType: AppActivity.screen.rawValue)
        userActivity.title = "About the Summit"
        userActivity.webpageURL = AppEnvironment.configuration.webpage
        userActivity.userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.about.rawValue]
        userActivity.requiredUserInfoKeys = [AppActivityUserInfo.screen.rawValue]
        self.userActivity = userActivity
        
        // setup UI
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userActivity?.becomeCurrent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        userActivity?.resignCurrent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestAppReview()
    }
    
    override func updateUserActivityState(_ userActivity: NSUserActivity) {
        
        let userInfo = [AppActivityUserInfo.screen.rawValue: AppActivityScreen.about.rawValue]
        
        userActivity.addUserInfoEntries(from: userInfo as [AnyHashable: Any])
        
        super.updateUserActivityState(userActivity)
    }
    
    // MARK: - Actions
    
    @IBAction func showLink(_ sender: UIButton) {
        
        let link = Link(rawValue: sender.tag)!
        
        switch link {
            
        case .openStackWebsite:
            
            let url = URL(string: "https://openstack.org")!
            
            open(url)
            
        case .codeOfConduct:
            
            let url = URL(string: "https://www.openstack.org/summit/barcelona-2016/code-of-conduct")!
            
            open(url)
            
        case .appSupport:
            
            let email = "summitapp@openstack.org"
            
            sendEmail(to: email)
            
        case .generalInquiries:
            
            let email = "summitapp@openstack.org"
            
            sendEmail(to: email)
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        
        // setup sections
        
        sections = []
        
        if Store.shared.session.accessToken != nil || Store.shared.session.refreshToken != nil ||
            Store.shared.session.accessTokenExpirationDate != nil || Store.shared.session.refreshTokenExpirationDate != nil {
            
            sections.append(.oauth)
        }
        
        if let summitManagedObject = self.currentSummit {
            
            let summit = Summit(managedObject: summitManagedObject)
            
            summitCache = summit
            
            sections.append(.name)
            
            // fetch wireless networks
            
            #if DEBUG
            let summitActive = true // always show for debug builds
            #else
            let summitActive = NSDate().mt_isBetweenDate(summitManagedObject.start, andDate: summitManagedObject.end)
            #endif
            
            if summitActive {
                
                let sort = [NSSortDescriptor(key: "name", ascending: true)]
                
                let wirelessNetworks = try! WirelessNetwork.filter((#keyPath(WirelessNetworkManagedObject.summit.id) == summit.identifier), sort: sort, context: Store.shared.managedObjectContext)
                
                if wirelessNetworks.isEmpty == false {
                    
                    sections.append(.wirelessNetworks(wirelessNetworks))
                }
            }
            
            // setup handoff
            
            userActivity?.webpageURL = summit.webpage
            
        } else {
            
            summitCache = nil
            
            userActivity?.webpageURL = AppEnvironment.configuration.webpage
        }
        
        var aboutCells = [AboutCell]()
        
        aboutCells += [.links, .description]
        
        sections.append(.about(aboutCells))
        
        // reload table view
        
        self.tableView.reloadData()
    }
    
    @inline(__always)
    private func configure(cell: WirelessNetworkCell, with network: WirelessNetwork) {
        
        cell.nameLabel.text = network.name
        
        cell.passwordLabel.text = network.password
    }
    
    
    @inline(__always)
    private func configure(cell: OAuthDebugCell) {
        
        if let accessToken = Store.shared.session.accessToken {
            
            cell.accessTokenTitleLabel.text = "Access token:"
            cell.accessTokenLabel.text = accessToken
            
        } else {
            
            cell.accessTokenTitleLabel.text = ""
            cell.accessTokenLabel.text = ""
        }
        
        if let accessTokenExpirationDate = Store.shared.session.accessTokenExpirationDate {
            
            cell.accessTokenExpirationDateTitleLabel.text = "Access token expiration date (UTC, calculated on login):"
            cell.accessTokenExpirationDateLabel.text = accessTokenExpirationDate.currentUTCTimeZoneDate
            
        } else {
            
            cell.accessTokenExpirationDateTitleLabel.text = ""
            cell.accessTokenExpirationDateLabel.text = ""
        }
        
        if let refreshToken = Store.shared.session.refreshToken {
            
            cell.refreshTokenTitleLabel.text = "Refresh token:"
            cell.refreshTokenLabel.text = refreshToken
            
        } else {
            
            cell.refreshTokenTitleLabel.text = ""
            cell.refreshTokenLabel.text = ""
        }
        
        if let refreshTokenExpirationDate = Store.shared.session.refreshTokenExpirationDate {
            
            cell.refreshTokenExpirationDateTitleLabel.text = "Refresh token expiration date (UTC, calculated on login):"
            cell.refreshTokenExpirationDateLabel.text = refreshTokenExpirationDate.currentUTCTimeZoneDate
            
        } else {
            
            cell.refreshTokenExpirationDateTitleLabel.text = ""
            cell.refreshTokenExpirationDateLabel.text = ""
        }
    }
    
    @inline(__always)
    private func configure(cell: AboutNameCell) {
        
        guard let summit = self.summitCache
            else { fatalError("No summit cache") }
        
        cell.nameLabel.text = summit.name
        
        if let datesLabel = self.summitCache!.datesLabel {
            
            cell.dateLabel.text = datesLabel
        }
        else {
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(identifier: summit.timeZone)
            dateFormatter.dateFormat = "MMMM dd-"
            let stringDateFrom = dateFormatter.string(from: summit.start)
            
            dateFormatter.dateFormat = "dd, yyyy"
            let stringDateTo = dateFormatter.string(from: summit.end)
            
            cell.dateLabel.text = "\(stringDateFrom)\(stringDateTo)"
        }
        
        cell.buildVersionLabel.text = "Version \(AppVersion)"
        cell.buildNumberLabel.text = "Build \(AppBuild)"
    }
    
    @inline(__always)
    private func open(_ url: URL) {
        
        if UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.openURL(url)
            
        } else {
            
            showErrorAlert("Could open URL.")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection index: Int) -> Int {
        
        let section = sections[index]
        
        switch section {
            
        case .name, .oauth: return 1
            
        case let .wirelessNetworks(networks): return networks.count
            
        case let .about(cells): return cells.count
        
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = sections[indexPath.section]
        
        switch section {
        
        case .name:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.aboutNameCell, for: indexPath)!
            
            configure(cell: cell)
            
            return cell
            
        case let .wirelessNetworks(networks):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.wirelessNetworkCell, for: indexPath)!
            
            let network = networks[indexPath.row]
            
            configure(cell: cell, with: network)
            
            return cell
            
        case let .about(aboutCells):
            
            let data = aboutCells[indexPath.row]
            
            switch data {
            
            case .links:
                
                return tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.aboutLinksCell, for: indexPath)!
                
            case .description:
                
                return tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.aboutDescriptionCell, for: indexPath)!
            }
            
        case .oauth:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.oAuthDebugCell, for: indexPath)!
            
            configure(cell: cell)
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection index: Int) -> CGFloat {
        
        let section = sections[index]
        
        switch section {
        case .wirelessNetworks: return 90
        case .name, .about, .oauth: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection index: Int) -> UIView? {
        
        let section = sections[index]
        
        switch section {
        case .wirelessNetworks: return wirelessNetworksHeaderView
        case .name, .about, .oauth: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection index: Int) -> CGFloat {
        
        let section = sections[index]
        
        switch section {
        case .wirelessNetworks: return 30
        case .name, .about, .oauth: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection index: Int) -> UIView? {
        
        let section = sections[index]
        
        switch section {
        case .wirelessNetworks: return wirelessNetworksFooterView
        case .name, .about, .oauth: return nil
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Swift.Error?) {
        
        dismiss(animated: true) {
            
            if let error = error {
                
                self.showErrorAlert(error.localizedDescription)
            }
        }
    }
}

// MARK: - Supporting Types

private extension AboutViewController {
    
    enum Section {
        
        case name
        case oauth
        case wirelessNetworks([WirelessNetwork])
        case about([AboutCell])
    }
    
    enum AboutCell {
        
        case links
        case description
    }
    
    enum Link: Int {
        
        case openStackWebsite
        case codeOfConduct
        case appSupport
        case generalInquiries
    }
}

final class WirelessNetworkCell: UITableViewCell {
    
    @IBOutlet private(set) weak var nameLabel: CopyableLabel!
    
    @IBOutlet private(set) weak var passwordLabel: CopyableLabel!
}

final class AboutNameCell: UITableViewCell {
    
    @IBOutlet private(set) weak var nameLabel: CopyableLabel!
    
    @IBOutlet private(set) weak var dateLabel: CopyableLabel!
    
    @IBOutlet private(set) weak var buildVersionLabel: CopyableLabel!
    
    @IBOutlet private(set) weak var buildNumberLabel: CopyableLabel!
}

final class OAuthDebugCell: UITableViewCell {
    
    @IBOutlet private(set) weak var accessTokenTitleLabel: UILabel!
    
    @IBOutlet private(set) weak var accessTokenLabel: CopyableLabel!
    
    @IBOutlet private(set) weak var refreshTokenTitleLabel: UILabel!
    
    @IBOutlet private(set) weak var refreshTokenLabel: CopyableLabel!
    
    @IBOutlet private(set) weak var accessTokenExpirationDateTitleLabel: UILabel!
    
    @IBOutlet private(set) weak var accessTokenExpirationDateLabel: CopyableLabel!
    
    @IBOutlet private(set) weak var refreshTokenExpirationDateTitleLabel: UILabel!
    
    @IBOutlet private(set) weak var refreshTokenExpirationDateLabel: CopyableLabel!
}

extension Date {
    
    var currentUTCTimeZoneDate: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss tz"
        
        return formatter.string(from: self)
    }
}
