import XCTest
@testable import Curator

class UtilityTests: XCTestCase {
    func testFileManager() {
        let fileManager = CuratorFileManager
        let defaultFileManager = FileManager.default
        XCTAssertNotEqual(fileManager, defaultFileManager)
    }
    
    func testURLComponents_CuratorLocation() {
        var goodURLComponents = URLComponents()
        goodURLComponents.scheme = "file"
        goodURLComponents.host = ""
        goodURLComponents.path = "/file"
        let _ = try! (goodURLComponents as CuratorLocation).asURL()
        
        var badURLComponents = URLComponents()
        badURLComponents.path = "//"
        do {
            let _ = try (badURLComponents as CuratorLocation).asURL()
            XCTFail()
        } catch Curator.Error.invalidLocation(_) {}
        catch { XCTFail() }
    }
}
