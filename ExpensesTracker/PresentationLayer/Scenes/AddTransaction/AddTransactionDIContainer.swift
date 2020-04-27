//
//  AddTransactionDIContainer.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

final class AddTransactionDIContainer {
    
    static func assembleAddTransactionSceneWith(viewController: AddTransactionViewController) {
        let path = URL(fileURLWithPath: NSTemporaryDirectory())
        let disk = DiskManager(path: path)
        let persist = PersistCodable(disk: disk, decoder: .init(), enconder: .init())
        let addTransaction = AddTransactionManager(persistance: persist)
        let presenter = AddTransactionPresenter(persistanceManager: persist, useCase: addTransaction)
        viewController.presenter = presenter
    }
}
