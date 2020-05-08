//
//  main.swift
//  BonjourClientTest
//
//  Created by Alex Babaev on 28.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Robologs

let client = BonjourClient(logger: PrintLogger(onlyTime: true))
let subscription = client.subscribeOnSDKsListUpdate { list in
    print("\nFound!\n\(list)\n")
}

RunLoop.main.run()
