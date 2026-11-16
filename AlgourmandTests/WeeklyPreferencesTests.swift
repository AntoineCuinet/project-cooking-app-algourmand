@testable import AlgourmandCore
import XCTest

final class WeeklyPreferencesTests: XCTestCase {
    @MainActor
    func testWeeklyPreferencesViewModelAndStorage() {
        let userId = UUID()
        let viewModel = WeeklyPreferencesViewModel()

        XCTAssertEqual(viewModel.maxPreparationTime, 30)
        XCTAssertFalse(viewModel.hasNoTimeLimit)
        viewModel.maxPreparationTime = 45
        XCTAssertEqual(viewModel.maxPreparationTime, 45)

        XCTAssertTrue(viewModel.isCuisineSelected("Méditerranéenne"))
        viewModel.toggleCuisine("Italienne")
        XCTAssertTrue(viewModel.isCuisineSelected("Italienne"))
        viewModel.toggleCuisine("Italienne")
        XCTAssertFalse(viewModel.isCuisineSelected("Italienne"))

        viewModel.addIngredient("Courgettes")
        viewModel.addIngredient("Riz")
        viewModel.addIngredient("courgettes")
        XCTAssertEqual(viewModel.availableIngredients.count, 2)
        viewModel.removeIngredient("Riz")
        XCTAssertEqual(viewModel.availableIngredients, ["Courgettes"])

        XCTAssertTrue(viewModel.savePreferences(for: userId))
        XCTAssertTrue(viewModel.isSaved)
        XCTAssertNotNil(viewModel.feedbackMessage)

        let loaded = LocalWeeklyPreferencesStorage.shared.loadPreferences(for: userId)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.maxPreparationTime, 45)
        XCTAssertEqual(loaded?.availableIngredients, ["Courgettes"])

        XCTAssertTrue(LocalWeeklyPreferencesStorage.shared.deletePreferences(for: userId))
        XCTAssertNil(LocalWeeklyPreferencesStorage.shared.loadPreferences(for: userId))
    }
}
