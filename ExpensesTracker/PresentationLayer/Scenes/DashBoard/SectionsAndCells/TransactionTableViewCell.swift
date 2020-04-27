//
//  TransactionTableViewCell.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    var amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.textColor = .black
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        let marginGuide = contentView.layoutMarginsGuide
        let leftStackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        leftStackView.axis = .vertical
        leftStackView.spacing = 8
        leftStackView.distribution = .fillEqually
        leftStackView.alignment = .fill
        
        let horizontalStack = UIStackView(arrangedSubviews: [leftStackView, amountLabel])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 20
        horizontalStack.distribution = .fill
        horizontalStack.alignment = .fill
        contentView.addSubview(horizontalStack)

        horizontalStack.anchor(top: marginGuide.topAnchor,
                             leading: marginGuide.leadingAnchor,
                             bottom: marginGuide.bottomAnchor,
                             trailing: marginGuide.trailingAnchor,
                             padding: UIEdgeInsets(top: 5, left: 8, bottom: 8, right: 8))
    }
    
    func populateCellWith(transaction: Transaction?) {
        if let currentTransaction = transaction {
            self.titleLabel.text = currentTransaction.title
            self.dateLabel.text = currentTransaction.date.formattedDate
            self.amountLabel.text = currentTransaction.ammount.localizedCurrency
            self.amountLabel.textColor = currentTransaction.isIncome ? .green : .red
            
        }
    }
    
    
}
