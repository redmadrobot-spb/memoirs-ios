//
// main
// memoirs-ios
//
// Created by Alexander Babaev on 09 January 2024.
// Copyright © 2024 Alexander Babaev. All rights reserved.
//

import MemoirMacros
import Memoirs

let appMemoir = PrintMemoir()

@WithTracer
class Test1: @unchecked Sendable {
    private let test2 = Test2()

    @AutoTraced
    func foo() {
        $memoir.debug("Test log 1")
        Task { [self] in
            await bar()
            await barMainActor()
            test2.foo()
        }
    }

    @AutoTraced
    func bar() async {
        $memoir.debug("Test log 2")
        await barMainActor()
    }

    @MainActor @AutoTraced
    func barMainActor() async {
        $memoir.debug("Test log 2")
    }
}

@WithTracer
class Test2: @unchecked Sendable {
    @AutoTraced
    func foo() {
        $memoir.debug("Test log 1")
    }
}

let test = Test1()
test.foo()

try? await Task.sleep(for: .seconds(2))
