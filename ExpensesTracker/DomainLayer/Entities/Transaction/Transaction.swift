//
//  Transaction.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 26/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

struct Transaction: Codable {
    var id: String
    var ammount: Float
    var title: String
    var date: Date
    var isIncome: Bool
}
