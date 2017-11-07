//
//  Session.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

/// Provides the storage for session values
public protocol SessionStorage {
    
    /// The authenticated member.
    var member: Identifier?  { get set }
    
    var accessToken: String?  { get set }
    
    var accessTokenExpirationDate: Date?  { get set }
    
    var refreshToken: String?  { get set }
    
    var refreshTokenExpirationDate: Date?  { get set }
    
    /// Whether the device previously had a passcode.
    var hadPasscode: Bool { get set }
}

public extension SessionStorage {
    
    /// Resets the session storage.
    mutating func clear() {
        
        self.member = nil
        self.accessToken = nil
        self.accessTokenExpirationDate = nil
        self.refreshToken = nil
        self.refreshTokenExpirationDate = nil
    }
}

// MARK: - Implementations

public final class UserDefaultsSessionStorage: SessionStorage {
    
    public let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        
        self.userDefaults = userDefaults
    }
    
    public var member: Identifier? {
        
        get { return (userDefaults.object(forKey: Key.member.rawValue) as? NSNumber)?.int64Value }
        
        set {
            
            guard let member = newValue
                else { userDefaults.removeObject(forKey: Key.member.rawValue); return }
            
            userDefaults.set(NSNumber(value: member), forKey: Key.member.rawValue)
            
            userDefaults.synchronize()
        }
    }
    
    public var accessToken: String? {
        
        get { return userDefaults.string(forKey: Key.accessToken.rawValue) }
        
        set { userDefaults.set(newValue, forKey: Key.accessToken.rawValue) }
    }
    
    
    public var accessTokenExpirationDate: Date? {
        
        get {
            let expiration = userDefaults.double(forKey: Key.accessTokenExpirationDate.rawValue)
            
            if expiration != 0 {
                
                return Date(timeIntervalSince1970: expiration)
            }
            else {
                return nil
            }
        }
        
        set { userDefaults.set(newValue?.timeIntervalSince1970, forKey: Key.accessTokenExpirationDate.rawValue) }
    }
    
    
    public var refreshToken: String? {
        
        get { return userDefaults.string(forKey: Key.refreshToken.rawValue) }
        
        set { userDefaults.set(newValue, forKey: Key.refreshToken.rawValue) }
    }
    
    public var refreshTokenExpirationDate: Date? {
        
        get {
            
            let expiration = userDefaults.double(forKey: Key.refreshTokenExpirationDate.rawValue)
            
            if expiration != 0 {
                
                return Date(timeIntervalSince1970: expiration)
            }
            else {
                return nil
            }
        }
        
        set { userDefaults.set(newValue?.timeIntervalSince1970, forKey: Key.refreshTokenExpirationDate.rawValue) }
    }
    
    
    public var hadPasscode: Bool {
        
        get { return userDefaults.bool(forKey: Key.hadPasscode.rawValue) }
        
        set { userDefaults.set(newValue, forKey: Key.hadPasscode.rawValue) }
    }
    
    private enum Key: String {
        
        case member = "CoreSummit.UserDefaultsSessionStorage.Key.Member"
        case accessToken = "CoreSummit.UserDefaultsSessionStorage.Key.AccessToken"
        case accessTokenExpirationDate = "CoreSummit.UserDefaultsSessionStorage.Key.AccessTokenExpirationDate"
        case refreshToken = "CoreSummit.UserDefaultsSessionStorage.Key.RefreshToken"
        case refreshTokenExpirationDate = "CoreSummit.UserDefaultsSessionStorage.Key.RefreshTokenExpirationDate"
        case hadPasscode = "CoreSummit.UserDefaultsSessionStorage.Key.HadPasscode"
    }
}
