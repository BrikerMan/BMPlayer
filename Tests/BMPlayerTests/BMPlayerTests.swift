import XCTest
@testable import BMPlayer

final class BMPlayerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BMPlayer().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
