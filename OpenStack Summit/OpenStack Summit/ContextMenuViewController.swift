//
//  ContextMenuViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/26/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit

protocol ContextMenuViewController: class {
    
    var contextMenu: ContextMenu { get }
}

extension ContextMenuViewController {
    
    func showContextMenu(sender: UIBarButtonItem) {
        
        guard let viewController = self as? UIViewController
            else { fatalError("\(self) is not a view controller") }
        
        let menu = self.contextMenu
        
        let actionActivities = menu.actions.map { ContextMenuActionActivity(action: $0) }
        
        let activityVC = UIActivityViewController(activityItems: menu.shareItems, applicationActivities: actionActivities)
        
        viewController.presentViewController(activityVC, animated: true, completion: nil)
    }
}

struct ContextMenu {
    
    var actions = [Action]()
    
    var shareItems = [AnyObject]()
}

extension ContextMenu {
    
    struct Action {
        
        let activityType: String
        
        let image: () -> UIImage?
        
        let title: String
        
        let handler: Handler
        
        enum Handler {
            
            case modal((Bool -> ()) -> UIViewController?)
            case background((Bool -> ()) -> ())
        }
    }
}

@objc final class ContextMenuActionActivity: UIActivity {
    
    let action: ContextMenu.Action
    
    init(action: ContextMenu.Action) {
        
        self.action = action
        
        super.init()
    }
    
    override class func activityCategory() -> UIActivityCategory {
        
        return .Action
    }
    
    override func activityType() -> String? {
        
        return action.activityType
    }
    
    override func activityTitle() -> String? {
        
        return action.title
    }
    
    override func activityImage() -> UIImage? {
        
        return action.image()
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        
        return true
    }
    
    override func activityViewController() -> UIViewController? {
        
        switch action.handler {
            
        case let .modal(handler):
            
            return handler({ [weak self] in self?.activityDidFinish($0) })
            
        case .background:
            
            return nil
        }
    }
    
    override func performActivity() {
        
        switch action.handler {
            
        case .modal: super.performActivity()
            
        case let .background(handler):
            
            handler({ [weak self] in self?.activityDidFinish($0) })
        }
    }
}
