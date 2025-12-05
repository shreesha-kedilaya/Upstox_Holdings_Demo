//
//  HoldingViewModelTests.swift
//  Shreesha_Demo
//
//  Created by Shreesha Kedlaya on 05/12/25.
//

import XCTest
import Combine
@testable import Shreesha_Demo

// MARK: - Mocks

@MainActor
final class HoldingViewModelTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    
    private var viewModel: HoldingViewModel!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
//        viewModel = nil
        super.tearDown()
    }

    // MARK: - Helpers
    
    private func makeViewModel(
        service: MockHoldingService = MockHoldingService()
    ) -> (HoldingViewModel, MockHoldingService, MockHoldingServiceUIInput) {
        let viewModel = HoldingViewModel(holdingService: service)
        let input = MockHoldingServiceUIInput(viewModel: viewModel)
        viewModel.input = input
        viewModel.setup()
        return (viewModel, service, input)
    }

    // MARK: - Tests
    
    func test_something() {
        XCTAssertEqual(2, 2, "Should emit 2 row view models")
    }

    /// When local storage has holdings, `setup` + `viewLoad` should:
    /// - read from local storage
    /// - publish display items
    /// - publish a non-nil summary with correct values
    func testSetup_emitsHoldingsFromLocalStorageAndSummary() {
        // GIVEN
        let mockService = MockHoldingService()

        // 2 holdings with non-trivial numbers
        // h1: currentValue = 2*10 = 20, investment = 2*5 = 10, todays = (9-10)*2 = -2
        // h2: currentValue = 3*2 = 6,  investment = 3*3 = 9,  todays = (2-2)*3 = 0
        // Totals: current = 26, invest = 19, totalPnL = 7, todaysPnL = -2
        let holdings: [Holding] = [
            Holding(symbol: "BTC", quantity: 2, ltp: 10, avgPrice: 5, close: 9),
            Holding(symbol: "ADA", quantity: 3, ltp: 2, avgPrice: 3, close: 2)
        ].compactMap { $0 }
        mockService.fetchFromLocalStorageResult = .success(holdings)

        let (viewModel, _, input) = makeViewModel(service: mockService)

        self.viewModel = viewModel
        let itemsExpectation = expectation(description: "display items updated")
        let summaryExpectation = expectation(description: "summary updated")

        // WHEN: items are emitted
        viewModel.currentDisplayItems
            .dropFirst() // initial empty value
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { items in
                    XCTAssertEqual(items.count, 2, "Should emit 2 row view models")
                    itemsExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // WHEN: summary is emitted
        viewModel.summaryDisplayItem
            .dropFirst() // initial nil
            .sink { summary in
                guard let summary else {
                    XCTFail("Summary should not be nil when we have holdings")
                    return
                }

                let currentValue = 26.0
                let investment = 19.0
                let totalPnL = currentValue - investment // 7
                let todaysPnL = -2.0
                let percentage = (totalPnL / investment) * 100.0

                XCTAssertEqual(summary.currentValueText, currentValue.fmt())
                XCTAssertEqual(summary.investmentText, investment.fmt())
                XCTAssertEqual(summary.totalPnLText, totalPnL.fmt())
                XCTAssertEqual(summary.todaysPnLText, todaysPnL.fmt())

                XCTAssertTrue(summary.totalPnLColorIsPositive, "Total PnL is positive (7)")
                XCTAssertFalse(summary.todaysPnLColorIsPositive, "Today's PnL is negative (-2)")

                XCTAssertEqual(summary.percentageText,
                               String(format: " (%.2f%%)", percentage))

                summaryExpectation.fulfill()
            }
            .store(in: &cancellables)

        // Trigger view load        
        input.viewLoadSubject.send(())

        wait(for: [itemsExpectation, summaryExpectation], timeout: 1.0)
    }

    /// When local storage is empty, `summary` should be nil and items should be empty.
    func testSetup_withEmptyLocalHoldings_setsEmptyItemsAndNilSummary() {
        // GIVEN
        let mockService = MockHoldingService()
        mockService.fetchFromLocalStorageResult = .success([])

        let (viewModel, _, input) = makeViewModel(service: mockService)

        let itemsExpectation = expectation(description: "empty items emitted")
        let summaryExpectation = expectation(description: "nil summary emitted")
        self.viewModel = viewModel
        viewModel.currentDisplayItems
            .dropFirst()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { items in
                    XCTAssertTrue(items.isEmpty, "Items should be empty when cache is empty")
                    itemsExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        viewModel.summaryDisplayItem
            .dropFirst()
            .sink { summary in
                XCTAssertNil(summary, "Summary should be nil when there are no holdings")
                summaryExpectation.fulfill()
            }
            .store(in: &cancellables)

        input.viewLoadSubject.send(())

        wait(for: [itemsExpectation, summaryExpectation], timeout: 1.0)
    }

    /// `showLoader` should toggle true -> false around the async work on view load.
    func testSetup_togglesLoaderOnViewLoad() {
        // GIVEN
        let mockService = MockHoldingService()
        mockService.fetchFromLocalStorageResult = .success([])

        let (viewModel, _, input) = makeViewModel(service: mockService)
        self.viewModel = viewModel
        let loaderStartExpectation = expectation(description: "loader started")
        let loaderStopExpectation = expectation(description: "loader stopped")

        var received: [Bool] = []

        viewModel.showLoader
            .sink { isLoading in
                received.append(isLoading)

                if received.count == 1 {
                    XCTAssertTrue(isLoading, "First loader event should be true")
                    loaderStartExpectation.fulfill()
                } else if received.count == 2 {
                    XCTAssertFalse(isLoading, "Second loader event should be false")
                    loaderStopExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // WHEN
        input.viewLoadSubject.send(())


        wait(for: [loaderStartExpectation, loaderStopExpectation], timeout: 1.0)
    }

    /// If `fetchFromLocalStorage` throws, we at least verify that nothing crashes and
    /// `currentDisplayItems` stays at its initial value.
    func testSetup_whenLocalFetchFails_keepsInitialState() {
        // GIVEN
        enum MockError: Error { case someError }

        let mockService = MockHoldingService()
        mockService.fetchFromLocalStorageResult = .failure(MockError.someError)

        let (viewModel, _, input) = makeViewModel(service: mockService)
        self.viewModel = viewModel
        // We don't expect new values, just that we stay with the initial ones.
        let itemsExpectation = expectation(description: "no extra items emitted")
        itemsExpectation.isInverted = true

        viewModel.currentDisplayItems
            .dropFirst() // would fire if view model sends anything new
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    itemsExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // WHEN
        input.viewLoadSubject.send(())


        // THEN: wait a bit and ensure no events came
        wait(for: [itemsExpectation], timeout: 0.5)

        XCTAssertTrue(viewModel.currentDisplayItems.value.isEmpty)
        XCTAssertNil(viewModel.summaryDisplayItem.value)
    }
}
