//
//  HoldingServiceInput.swift
//  Shreesha_Demo
//
//  Created by Shreesha Kedlaya on 05/12/25.
//

import Combine
@testable import Shreesha_Demo
/// Simple UI input mock that lets us trigger `viewLoad`
final class MockHoldingServiceUIInput: HoldingServiceUIInput {

    var viewModel: HoldingServiceUIOutput

    let viewLoadSubject = PassthroughSubject<Void, Never>()
    var viewLoad: AnyPublisher<Void, Never> {
        viewLoadSubject.eraseToAnyPublisher()
    }

    init(viewModel: HoldingServiceUIOutput) {
        self.viewModel = viewModel
    }
}
