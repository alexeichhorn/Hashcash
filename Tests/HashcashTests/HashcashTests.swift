import XCTest
@testable import Hashcash

final class HashcashTests: XCTestCase {
    
    func testExample() {
        let hashcash = Hashcash()
        
        let stamp = hashcash.mint(resource: "hello")
        print(stamp)
        XCTAssertNotNil(stamp)
    }
    
    func testStampParser() {
        
        let encoded = "1:20:210324:hello::gemqijJM/8VRm6ij:1C2EB1"
        
        XCTAssertNoThrow(try Stamp(encodedValue: encoded))
        
        let stamp = try! Stamp(encodedValue: encoded)
        
        XCTAssert(stamp.version == "1")
        XCTAssert(stamp.bits == 20)
        XCTAssert(stamp.resource == "hello")
        XCTAssert(stamp.ext == "")
        XCTAssert(stamp.salt == "gemqijJM/8VRm6ij")
        XCTAssert(stamp.counter == "1C2EB1")
        XCTAssert(stamp.encodedValue == encoded)
        
        // TODO: check date
        
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
