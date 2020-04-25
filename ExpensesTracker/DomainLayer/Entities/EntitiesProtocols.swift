//
//  Protocols.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

protocol Transactionable {
    var ammount: String { get set }
    var title: String { get set }
    var date: String { get set }
}

protocol Accountable {
    var title: String { get set}
    var totalAmount: String { get set }
    var transactions: [Transactionable] { get set }
}
