//
//  DashBoardDIContainer.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

final class DashBoardDIContainer {
    
    static func assembleDashBoardSceneWith(viewController: DashBoardTableViewController) {
        let path = URL(fileURLWithPath: NSTemporaryDirectory())
        let disk = DiskManager(path: path)
        let persist = PersistCodable(disk: disk, decoder: .init(), enconder: .init())
        let removeTransaction = RemoveTransactionManager(persistance: persist)
        let populateAccounts = PopulateAccounts(persist: persist)
        let presenter = DashBoardPresenter(populateAccountsUseCase: populateAccounts, removeTransactionUseCase: removeTransaction)
        viewController.presenter = presenter
    }
}
