import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(PenTests.allTests),
    testCase(BoundsPenTests.allTests),
  ]
}
#endif
