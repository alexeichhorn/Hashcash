import XCTest
@testable import Hashcash

final class HashcashTests: XCTestCase {
    
    func testExample() {
        let hashcash = Hashcash(bits: 22, datePrecision: .seconds)
        
        let stamp = hashcash.mint(resource: "test")
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
    
    func testStampCheck() {
        
        let hashcash = Hashcash(bits: 22)
        let stamp = try! Stamp(encodedValue: "1:22:210325:test::CAXaidriI2b2oYhh:5C901")
        
        let comparingDate = Date(timeIntervalSince1970: 1616629155)
        XCTAssertTrue(hashcash.check(stamp: stamp, resource: "test", currentDate: comparingDate))
        
        let secondStamp = try! Stamp(encodedValue: "1:22:210325003802:test::5CwGOLBtiowpxjkW:19DE17")
        
        XCTAssertTrue(hashcash.check(stamp: secondStamp, currentDate: comparingDate))
        
        let secondInvalidDate = Date(timeIntervalSince1970: 1616628834)
        XCTAssertTrue(hashcash.check(stamp: stamp, currentDate: secondInvalidDate))
        XCTAssertFalse(hashcash.check(stamp: secondStamp, currentDate: secondInvalidDate))
        
    }

    static var allTests = [
        ("testExample", testExample),
        ("testStampParser", testStampParser),
        ("testStampCheck", testStampCheck)
    ]
}
