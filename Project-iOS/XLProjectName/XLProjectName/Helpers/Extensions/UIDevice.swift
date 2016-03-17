//
//  UIDevice.swift
//  XLProjectName
//
//  Created by Martin Barreto on 3/16/16.
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
import UIKit
import KeychainAccess
import Crashlytics

extension UIDevice {
    
    private static let keychainKey = "device_id"
    private static let keychain = Keychain(service: UIApplication.bundleIdentifier)
    
    static var uniqueId: String {
        if try! keychain.contains(keychainKey) {
            return try! keychain.get(keychainKey)!
        }
        let newDeviceId = UIDevice.currentDevice().identifierForVendor!.UUIDString
        try! keychain.set(newDeviceId, key: keychainKey)
        return newDeviceId
    }
}
