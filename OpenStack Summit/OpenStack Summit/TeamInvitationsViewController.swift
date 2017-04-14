//
//  TeamInvitationsViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/5/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Foundation
import CoreSummit
import JGProgressHUD

final class TeamInvitationsViewController: UITableViewController, PagingTableViewController {
    
    typealias Invitation = ListTeamInvitations.Response.Invitation
    
    // MARK: - Properties
    
    var completion: ((TeamInvitationsViewController) -> ())?
    
    lazy var pageController = PageController<Invitation>(fetch: { Store.shared.invitations($0.0, perPage: $0.1, filter: .pending, completion: $0.2) })
    
    lazy var progressHUD: JGProgressHUD = JGProgressHUD(style: .dark)
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 98
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(R.nib.loadingTableViewCell)
        
        pageController.callback.reloadData = { [weak self] in self?.tableView.reloadData() }
        
        pageController.callback.willLoadData = { [weak self] in self?.willLoadData() }
        
        pageController.callback.didLoadNextPage = { [weak self] in self?.didLoadNextPage($0) }
        
        refresh()
    }
    
    // MARK: - Actions
    
    @IBAction func refresh(_ sender: AnyObject? = nil) {
        
        pageController.refresh()
    }
        
    @IBAction func cancel(_ sender: AnyObject? = nil) {
        
        self.completion?(self)
    }
    
    // MARK: - Private Methods
    
    fileprivate func configure(cell: TeamInvitationTableViewCell, with invitation: Invitation) {
        
        cell.teamLabel.text = invitation.team.name
        
        cell.inviterLabel.text = "Invited by: " + invitation.inviter.name
        
        cell.dateLabel.text = dateFormatter.stringFromDate(invitation.created.toFoundation())
    }
    
    fileprivate func accept(_ invitation: Invitation) {
        
        showActivityIndicator()
        
        Store.shared.accept(invitation: invitation.identifier) { (response) in
            
            OperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                if let error = response {
                    
                    controller.dismissActivityIndicator()
                    
                    controller.showErrorMessage(error)
                    
                } else {
                    
                    Store.shared.fetch(team: invitation.team.identifier) { [weak self] (response) in
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                            
                            guard let controller = self else { return }
                            
                            controller.dismissActivityIndicator()
                            
                            switch response {
                                
                            case let .Error(error):
                                
                                controller.showErrorMessage(error)
                                
                            case .Value:
                                
                                controller.refresh()
                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func decline(_ invitation: Invitation) {
        
        showActivityIndicator()
        
        Store.shared.decline(invitation: invitation.identifier) { (response) in
            
            OperationQueue.mainQueue().addOperationWithBlock { [weak self] in
                
                guard let controller = self else { return }
                
                controller.dismissActivityIndicator()
                
                if let error = response {
                    
                    controller.showErrorMessage(error)
                    
                } else {
                    
                    controller.refresh()
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pageController.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = pageController.items[indexPath.row]
        
        switch data {
            
        case let .item(item):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.teamInvitationCell)!
            
            configure(cell: cell, with: item)
            
            return cell
            
        case .loading:
            
            pageController.loadNextPage()
            
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.loadingTableViewCell, forIndexPath: indexPath)!
            
            cell.activityIndicator.isHidden = false
            
            cell.activityIndicator.startAnimating()
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let data = pageController.items[indexPath.row]
        
        switch data {
            
        case let .item(item):
            
            let accept = UITableViewRowAction(style: .Normal, title: "Accept") { [weak self] (_,_) in self?.accept(item) }
            
            let decline = UITableViewRowAction(style: .Destructive, title: "Decline") { [weak self] (_,_) in self?.decline(item)  }
            
            return [decline, accept]
            
        case .loading:
            
            return nil
        }
    }
}

// MARK: - Supporting Types

final class TeamInvitationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var teamLabel: UILabel!
    
    @IBOutlet weak var inviterLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
}
