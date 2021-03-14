import XCTest

import PensTests

var tests = [XCTestCaseEntry]()
tests += PenTests.allTests()
tests += BoundsPenTests.allTests()
XCTMain(tests)
