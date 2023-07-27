import XCTest
@testable import RAWG_API

final class RAWG_APITests: XCTestCase {
    func testBasicCache() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let capacity = 10
        
        let cache = BasicCache<Int, Int>(capacity: capacity)
        
        for i in 1 ..< capacity {
            cache.cache((key: i, value: i))
        }
        
        for _ in 1 ..< capacity * 2 {
            let random = Int.random(in: 1 ..< capacity * 2)
            
            XCTAssertTrue(
                random >= capacity
                ? cache.get(random) != random
                : cache.get(random) == random
            )
        }
    }
}
