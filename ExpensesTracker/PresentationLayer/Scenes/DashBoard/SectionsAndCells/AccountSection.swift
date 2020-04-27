//
//  AccountSection.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import UIKit

class AccountSection: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    func setupViews() {
        let marginGuide = contentView.layoutMarginsGuide
        let horizontalStack = UIStackView(arrangedSubviews: [titleLabel, amountLabel])
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
    
    func populateWithEntity(account: Account?) {
        if let currentAccount = account {
            titleLabel.text = currentAccount.title
            amountLabel.text = currentAccount.totalAmount.localizedCurrency
        }
    }
}
