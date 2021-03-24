import XCTest
@testable import Hashcash

final class HashcashTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Hashcash().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
