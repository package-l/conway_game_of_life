import XCTest
@testable import FunctionalProgramming

final class FunctionalProgrammingTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FunctionalProgramming().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
