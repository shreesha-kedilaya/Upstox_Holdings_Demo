//
//  HoldingSummaryView.swift
//  Holdings_upstox
//
//  Created by Shreesha Kedlaya on 04/12/25.
//

import UIKit
import LayoutKit

final class HoldingSummaryView: BaseView {
    
    struct SummaryViewModel {
        let currentValueText: String
        let investmentText: String
        let totalPnLText: String
        let todaysPnLText: String
        let totalPnLColorIsPositive: Bool
        let todaysPnLColorIsPositive: Bool
        let percentageText: String
    }

    // MARK: - UI

    private let currentValueTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "Current value"
        return label
    }()

    
    private let currentValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private let investmentTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "Total investment"
        return label
    }()
    
    private let investmentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private let totalPnLTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "Total P&L"
        return label
    }()
    
    private let topView = UIView()
    
    private let totalPnLLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let todaysPnLTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "Today's P&L"
        return label
    }()
    
    private let todaysPnLLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    private var isShown = true
    
    // MARK: - State
    
    private var viewModel: SummaryViewModel? {
        didSet {
            displayItem()
        }
    }
    
    // MARK: - BaseView
    
    override func setup() {
        layout()
    }
    
    // MARK: - Public
    
    func configure(with viewModel: SummaryViewModel) {
        self.viewModel = viewModel
    }
    
    func toggle() {
        isShown.toggle()
        if isShown {
            showSummary()
        } else {
            hideSummary()
        }
    }
    
    func hideSummary() {
        self.stackView.fadeOut()
        self.topView.fadeOut()
    }

    func showSummary() {
        self.stackView.fadeIn()
        self.topView.fadeIn()
    }
}

// MARK: - Private

private extension HoldingSummaryView {
    
    func displayItem() {
        guard let viewModel else { return }
        
        currentValueLabel.text = viewModel.currentValueText
        investmentLabel.text = viewModel.investmentText
        
        totalPnLLabel.text = viewModel.totalPnLText
        totalPnLLabel.textColor = viewModel.totalPnLColorIsPositive ? .systemGreen : .systemRed
        
        todaysPnLLabel.text = viewModel.todaysPnLText
        todaysPnLLabel.textColor = viewModel.todaysPnLColorIsPositive ? .systemGreen : .systemRed
    }
    
    func layout() {
        
        clipsToBounds = true
        
//        self.roundCorners([.topLeft, .topRight], radius: 12)
        // Source - https://stackoverflow.com/a
        // Posted by Sergei Belous, modified by community. See post 'Timeline' for change history
        // Retrieved 2025-12-04, License - CC BY-SA 3.0

        clipsToBounds = true
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        // Rows
        let row1 = UIStackView(arrangedSubviews: [currentValueTitleLabel, currentValueLabel])
        let row2 = UIStackView(arrangedSubviews: [investmentTitleLabel, investmentLabel])
        let row3 = UIStackView(arrangedSubviews: [todaysPnLTitleLabel, todaysPnLLabel])
        
        [row1, row2, row3].forEach {
            $0.axis = .horizontal
            $0.makeConstraint {
                $0.height(24)
            }
            $0.distribution = .equalSpacing
        }
        
        // Top stack (3 rows)
        [row1, row2, row3].forEach {
            stackView.addArrangedSubview($0)
        }
        
        addSubview(topView)
        topView.addSubview(stackView)
        
        topView.makeConstraint { make in
            make.sameLeadingTrailing(self)
            make.top(self)
            make.bottom(self)
        }
        // StackView constraints
        addSubview(stackView)
        stackView.makeConstraint { make in
            make.leading(topView, 16)
            make.trailing(topView, 16)
            make.sameTopBottom(topView, 12)
        }

        topView.backgroundColor = UIColor(hex: "0010C4")
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        // Source - https://stackoverflow.com/a
        // Posted by Yunus Nedim Mehel, modified by community. See post 'Timeline' for change history
        // Retrieved 2025-12-04, License - CC BY-SA 4.0

        let path = UIBezierPath(roundedRect:self.bounds, byRoundingCorners:[.topRight, .topLeft], cornerRadii: CGSize(width: 12, height: 12))
        let maskLayer = CAShapeLayer()

        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
}
