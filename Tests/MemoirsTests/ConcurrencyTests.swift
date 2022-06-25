//
// ConcurrencyTests
// memoirs-ios
//
// Created by Alex Babaev on 05 May 2022.
// Copyright © 2022 Alex Babaev. All rights reserved.
//

import Foundation
import XCTest
import Memoirs

class ConcurrencyTests: XCTestCase {
    func testTracedMemoirSendability() {
        let memoir = TracedMemoir(label: "test", memoir: VoidMemoir())
        Task {
            memoir.debug("Some log")
        }
    }
}
