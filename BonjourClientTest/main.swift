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
RunLoop.main.run()
