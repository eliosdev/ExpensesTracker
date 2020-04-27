//
//  Account.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 26/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

struct Account: Codable {
    var title: String
    var totalAmount: Float
    var transactions: [Transaction]
}
