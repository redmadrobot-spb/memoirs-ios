//
//  EnvironmentInfo.swift
//  Robologs
//
//  Created by Vladislav Maltsev on 19.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation
import UIKit

struct IosApplicationEnvironmentInfo {
    let appId: String
    let appName: String?
    let appVersion: String?
    let appBuild: String?
    let operationSystem: String?
    let operationSystemVersion: String?
    let deviceModel: String?

    static var current: IosApplicationEnvironmentInfo {
        guard
            let infoPlist = Bundle.main.infoDictionary,
            let appId = infoPlist["CFBundleIdentifier"] as? String
        else { fatalError("Can't load ios application environment") }

        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = Mirror(reflecting: systemInfo.machine)
            .children
            .reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }

                return identifier + String(UnicodeScalar(UInt8(value)))
            }

        return IosApplicationEnvironmentInfo(
            appId: appId,
            appName: infoPlist["CFBundleName"] as? String,
            appVersion: infoPlist["CFBundleShortVersionString"] as? String,
            appBuild: infoPlist["CFBundleVersion"] as? String,
            operationSystem: UIDevice.current.systemName,
            operationSystemVersion: UIDevice.current.systemVersion,
            deviceModel: identifier
        )
    }
}
