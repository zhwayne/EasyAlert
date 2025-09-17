import XCTest
@testable import EasyAlert
import UIKit

final class ActionTests: XCTestCase {

    @MainActor
    final class DummyActionView: UIControl, ActionContent {
        var title: String?
        var style: Action.Style = .default
    }

    func testIsEnabledPropagatesToRepresentationView() {
        let actionView = DummyActionView()
        let action = Action(view: actionView)
        let representation = ActionCustomViewRepresentationView()
        representation.action = action

        action.isEnabled = false
        XCTAssertFalse(representation.isEnabled)
    }

    func testHandlerCalled() {
        let expectation = XCTestExpectation(description: "handler called")
        let action = Action(title: "Test", style: .default) { _ in
            expectation.fulfill()
        }
        action.handler?(action)
        wait(for: [expectation], timeout: 0.1)
    }
}
