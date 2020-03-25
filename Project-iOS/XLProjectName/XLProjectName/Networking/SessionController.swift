//
//  SessionController.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2016 'XLOrganizationName'. All rights reserved.
//

import Foundation
import Alamofire
import Crashlytics
import KeychainAccess
import RxSwift

class SessionController {
    static let sharedInstance = SessionController()
    fileprivate let keychain = Keychain(service: Constants.Keychain.SERVICE_IDENTIFIER)
    fileprivate init() { }
    
    var user: User?

    // MARK: - Session variables
    var token: String? {
        get { return keychain[Constants.Keychain.SESSION_TOKEN] }
        set { keychain[Constants.Keychain.SESSION_TOKEN] = newValue }
    }

    // MARK: - Session handling
    func logOut() {
        clearSession()
        //TODO: Logout: App should transition to login / onboarding screen
    }

    func isLoggedIn() -> Bool {
        invalidateIfNeeded()
        return token != nil
    }

    func invalidateIfNeeded() {
        if token != nil && user == nil {
            clearSession()
        }
    }

    // MARK: - Auxiliary functions
    func clearSession() {
        token = nil

//        Analytics.reset()
//        Analytics.registerUnidentifiedUser()
        Crashlytics.sharedInstance().setUserEmail(nil)
        Crashlytics.sharedInstance().setUserIdentifier(nil)
        Crashlytics.sharedInstance().setUserName(nil)
    }

    deinit {
        
    }
}
