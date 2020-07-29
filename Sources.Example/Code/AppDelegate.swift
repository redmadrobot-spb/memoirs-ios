//
// AppDelegate
// Example
//
// Created by Roman Mazeev on 27.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import UIKit
import Robologs

struct Test: Loggable {
    struct Inner: Loggable {
        @SafeToLog
        var publicString: String
        var privateString: String
    }

    @SafeToLog
    var publicString: String
    var privateString: String
    @NeverLog
    var veryBadString: String

    var subClass: Inner
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Level.stringVerbose = "👻"
        Level.stringDebug = "👣"
        Level.stringInfo = "🌵"
        Level.stringWarning = "🖖"
        Level.stringError = "⛑"
        Level.stringCritical = "👿"

        #if DEBUG
        LogString.isSensitive = false
        #else
        LogString.isSensitive = true
        #endif

        return true
    }

    private func testDifferentLoggingCases() {
        let logger = LabeledLogger(label: "Test", logger: NSLogLogger(isSensitive: true))

        let test = Test(
            publicString: "all know",
            privateString: "secret data",
            veryBadString: "top secret info",
            subClass: .init(
                publicString: "inner all know",
                privateString: "inner secret data"
            )
        )

        logger.debug(" -> Constant String")
        logger.info("Constant String")

        let string = "String Variable"
        logger.debug(" -> String Variable")
        logger.info("\(string)")

        logger.debug(" -> (default) Loggable output")
        logger.info("\(test)")
        logger.debug(" -> (default) Loggable public property output")
        logger.info("\(test.publicString)")
        logger.debug(" -> (default) Loggable private property output")
        logger.info("\(test.privateString)")

        logger.debug(" -> (safe) Loggable output")
        logger.info("\(safe: test)")
        logger.debug(" -> (safe) Loggable public property output")
        logger.info("\(safe: test.publicString)")
        logger.debug(" -> (safe) Loggable private property output")
        logger.info("\(safe: test.privateString)")
    }
}
