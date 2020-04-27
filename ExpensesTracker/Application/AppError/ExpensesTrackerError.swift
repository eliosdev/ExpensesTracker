//
//  ExpensesTrackerError.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

protocol ExpensesTrackerError: Error {
    var title: String { get set }
    var message: String { get set }
}

struct CoreError: ExpensesTrackerError {
    enum TypeError: Error {
        case encoding
        case decoding
        case readingDisk
        case writingDisk
    }
    
    var title: String
    var message: String
    var errorType: TypeError
}
