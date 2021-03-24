import XCTest
@testable import Hashcash

final class HashcashTests: XCTestCase {
    
    func testExample() {
        let hashcash = Hashcash()
        
        let stamp = hashcash.mint(resource: "hello")
        print(stamp)
        XCTAssertNotNil(stamp)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
