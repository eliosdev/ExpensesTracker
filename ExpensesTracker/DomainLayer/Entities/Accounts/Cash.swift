//
//  Cash.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

struct Cash: Accountable {
    var title: String
    
    var totalAmount: String
    
    var transactions: [Transactionable]
    
    
}
