//
// Storage
// Robologs
//
// Created by Alex Babaev on 27 May 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

enum Storage {
    static let bundleDirectory: URL = URL(fileURLWithPath: Bundle.main.bundlePath)
    static let temporaryDirectory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    static let documentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}
