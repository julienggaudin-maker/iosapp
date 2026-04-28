import XCTest
@testable import Lumio

final class AboutViewModelTests: XCTestCase {
    func testContentCounts() {
        let viewModel = AboutViewModel()

        XCTAssertEqual(viewModel.missions.count, 4)
        XCTAssertEqual(viewModel.values.count, 4)
    }
}
