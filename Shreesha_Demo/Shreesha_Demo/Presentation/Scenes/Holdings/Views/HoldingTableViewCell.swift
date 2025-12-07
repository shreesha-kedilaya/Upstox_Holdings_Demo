//
//  HoldingTableViewCell.swift
//  HoldingsApp
//
//  Created by Shreesha Kedlaya on 04/12/25.
//

import UIKit
import LayoutKit


final class HoldingRowView: BaseView, ReusableView {
    
    struct HoldingRowViewModel {
        let symbol: String
        let quantityText: String
        let ltpText: String
        let pnlText: String
        let pnlColorIsPositive: Bool
    }
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 1
        return label
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let ltpLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let pnlLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 1
        return label
    }()
    
    private let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .trailing
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private var viewModel: HoldingRowViewModel? {
        didSet {
            displayItem()
        }
    }
    
    // MARK: - BaseView
    
    override func setup() {
        layout()
    }
    
    // MARK: - Public
    
    func configure(with viewModel: HoldingRowViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Private

private extension HoldingRowView {
    
    func displayItem() {
        guard let viewModel = viewModel else { return }
        
        symbolLabel.text = viewModel.symbol
        quantityLabel.text = viewModel.quantityText   // e.g. "NET QTY: 10"
        ltpLabel.text = viewModel.ltpText             // e.g. "LTP: ₹ 123.45"
        
        pnlLabel.text = viewModel.pnlText
        pnlLabel.textColor = viewModel.pnlColorIsPositive ? .systemGreen : .systemRed
        
        // Optional: if you want to de-emphasize negative holdings visually:
        // self.alpha = viewModel.pnlColorIsPositive ? 1.0 : 0.8
        
        backgroundColor = UIColor {
            $0.userInterfaceStyle == .dark
            ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            : UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        }
    }
    
    func layout() {
        // Add subviews
        [containerStackView].forEach { addSubview($0) }
        
        leftStackView.addArrangedSubview(symbolLabel)
        leftStackView.addArrangedSubview(quantityLabel)
        
        rightStackView.addArrangedSubview(ltpLabel)
        rightStackView.addArrangedSubview(pnlLabel)
        
        containerStackView.addArrangedSubview(leftStackView)
        containerStackView.addArrangedSubview(rightStackView)
        
        // Constraints with your makeConstraint DSL
        containerStackView.makeConstraint { make in
            make.leading(self, 20)
            make.trailing(self, 20)
            make.sameTopBottom(self, 10)
        }
        
        backgroundColor = UIColor {
            $0.userInterfaceStyle == .dark
            ? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
            : UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        }
    }
}
