//
//  Date.swift
//  XLProjectName
//
//  Created by XLAuthorName ( XLAuthorWebsite )
//  Copyright © 2020 XLOrganizationName. All rights reserved.
//

import Foundation

extension Date {

    func dblog() -> String {
        return Constants.Formatters.debugConsoleDateFormatter.string(from: self)
    }

}
