//
//  Unique.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

/// A data type that can be uniquely identified.
public protocol Unique {
    
    var identifier: Identifier { get }
}

public typealias Identifier = Int

// MARK: - Extensions

public extension CollectionType where Generator.Element: Unique {
    
    var identifiers: [Identifier] {
        
        return self.map { $0.identifier }
    }
    
    @inline(__always)
    func with(identifier: Identifier) -> Self.Generator.Element? {
        
        return firstMatching { $0.identifier == identifier }
    }
}