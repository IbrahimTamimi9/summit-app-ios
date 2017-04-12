//
//  SummitActivityHandling.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import CoreSummit

protocol SummitActivityHandling {
    
    func view(_ data: AppActivitySummitDataType, identifier: Identifier) -> Bool
    
    func view(_ screen: AppActivityScreen)
    
    func search(_ searchTerm: String)
}

extension SummitActivityHandling {
    
    /// Opens URL of universal domain.
    func openWebURL(_ url: Foundation.URL) -> Bool {
        
        // perform search
        if url.pathComponents?.last == "global-search",
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let searchQuery = urlComponents.queryItems?.firstMatching({ $0.name == "t" && ($0.value ?? "").isEmpty == false }),
            let searchTerm = searchQuery.value {
            
            self.search(searchTerm)
            return true
        }
        
        // show data
        guard let components = url.pathComponents
            where components.count >= 6
            else { return false }
        
        let typeString = components[4]
        let identifierString = components[5]
        
        guard let identifier = Int(identifierString),
            let type = WebPathComponent(rawValue: typeString)
            else { return false }
        
        let dataType = AppActivitySummitDataType(webPathComponent: type)
        
        return self.view(dataType, identifier: identifier)
    }
    
    /// Opens URL of custom scheme.
    func openSchemeURL(_ url: Foundation.URL) -> Bool {
        
        guard let typeString = url.host, let components = url.pathComponents
            where components.count >= 2
            else { return false }
        
        let identifierString = components[1]
        
        guard let identifier = Int(identifierString),
            let type = WebPathComponent(rawValue: typeString)
            else { return false }
        
        let dataType = AppActivitySummitDataType(webPathComponent: type)
        
        return self.view(dataType, identifier: identifier)
    }
}

#if os(iOS)

// MARK: - View Controller

protocol SummitActivityHandlingViewController: class, SummitActivityHandling {
    
    func showViewController(_ vc: UIViewController, sender: AnyObject?)
    
    func playVideo(_ video: Video)
    
    func showLocationDetail(_ location: Identifier)
}

extension SummitActivityHandlingViewController {
    
    func view(_ data: AppActivitySummitDataType, identifier: Identifier) -> Bool  {
        
        let context = Store.shared.managedObjectContext
        
        // find in cache
        guard let managedObject = try! data.managedObject.find(identifier, context: context)
            else { return false }
        
        switch data {
            
        case .event:
            
            let eventDetailVC = R.storyboard.event.eventDetailViewController()!
            eventDetailVC.event = identifier
            self.showViewController(eventDetailVC, sender: nil)
            
        case .speaker:
            
            let memberProfileVC = MemberProfileViewController(profile: .speaker(identifier))
            self.showViewController(memberProfileVC, sender: nil)
            
        case .video:
            
            let video = Video(managedObject: managedObject as! VideoManagedObject)
            
            self.playVideo(video)
            
        case .venue, .venueRoom:
            
            self.showLocationDetail(identifier)
        }
        
        return true
    }
    
    func view(_ screen: AppActivityScreen) {
        
        AppDelegate.shared.view(screen)
    }
    
    func search(_ searchTerm: String) {
        
        AppDelegate.shared.search(searchTerm)
    }
}

#endif
