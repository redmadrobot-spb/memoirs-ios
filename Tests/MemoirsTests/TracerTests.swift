//
// TracerTests
// Memoirs
//
// Created by Alex Babaev on 15 November 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import XCTest
import Foundation
@testable import Memoirs

// swiftlint:disable line_length
class TracerTests: GenericTestCase {
    @objc class ObjCClass: NSObject {}
    class ObjCClassMangled: NSObject {}
    class SwiftClass {}
    struct SwiftStruct {}
    enum SwiftEnum { case test }
    class SwiftGenericClass<SomeType> {
        var some: SomeType

        init(some: SomeType) {
            self.some = some
        }
    }

    func testTracerGeneration() {
        XCTAssertEqual(tracer(forType: ObjCClass.self), Tracer.type(name: "TracerTests.ObjCClass", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forType: ObjCClassMangled.self), Tracer.type(name: "TracerTests.ObjCClassMangled", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forType: SwiftClass.self), Tracer.type(name: "TracerTests.SwiftClass", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forType: SwiftStruct.self), Tracer.type(name: "TracerTests.SwiftStruct", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forType: SwiftEnum.self), Tracer.type(name: "TracerTests.SwiftEnum", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forType: SwiftGenericClass<Int>.self), Tracer.type(name: "TracerTests.SwiftGenericClass<Swift.Int>", module: "MemoirsTests"))

        XCTAssertEqual(tracer(forObject: ObjCClass()), Tracer.type(name: "TracerTests.ObjCClass", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forObject: ObjCClassMangled()), Tracer.type(name: "TracerTests.ObjCClassMangled", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forObject: SwiftClass()), Tracer.type(name: "TracerTests.SwiftClass", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forObject: SwiftStruct()), Tracer.type(name: "TracerTests.SwiftStruct", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forObject: SwiftEnum.test), Tracer.type(name: "TracerTests.SwiftEnum", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forObject: SwiftGenericClass<Int>(some: 239)), Tracer.type(name: "TracerTests.SwiftGenericClass<Swift.Int>", module: "MemoirsTests"))

        XCTAssertEqual(tracer(forObject: ObjCClass().self), Tracer.type(name: "TracerTests.ObjCClass", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forObject: ObjCClassMangled().self), Tracer.type(name: "TracerTests.ObjCClassMangled", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forObject: SwiftClass().self), Tracer.type(name: "TracerTests.SwiftClass", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forObject: SwiftStruct().self), Tracer.type(name: "TracerTests.SwiftStruct", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forObject: SwiftEnum.test.self), Tracer.type(name: "TracerTests.SwiftEnum", module: "MemoirsTests"))
        XCTAssertEqual(tracer(forObject: SwiftGenericClass<Int>(some: 239).self), Tracer.type(name: "TracerTests.SwiftGenericClass<Swift.Int>", module: "MemoirsTests"))
    }
}
// swiftlint:enable line_length
