//
//  UseCases.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

class TransactionManager {
    func arithmeticTransaction(accountAmount: String, transactionAmount: String) -> String {
        let aamount = Float(accountAmount) ?? 0.0
        let tamount = Float(transactionAmount) ?? 0.0
        let totalAmount = aamount - tamount
        return totalAmount.stringValue
    }
}

protocol RemoveTransactionUseCase {
    func removeTransaction(transaction: Transactionable, fromAccount: Accountable, handler: @escaping (Accountable)->Void)
}

final class RemoveTransactionManager: TransactionManager, RemoveTransactionUseCase {
    func removeTransaction(transaction: Transactionable, fromAccount: Accountable, handler: @escaping (Accountable) -> Void) {
        var account = fromAccount
        account.totalAmount = arithmeticTransaction(accountAmount: fromAccount.totalAmount, transactionAmount: transaction.ammount)
        account.transactions.removeAll { $0.id == transaction.id}
        handler(account)
    }
}

protocol AddTransactionUseCase {
    func addTransaction(transaction: Transactionable, toAccount: Accountable, handler: @escaping (Accountable) -> Void)
}

final class AddTransactionManager: TransactionManager, AddTransactionUseCase {
    func addTransaction(transaction: Transactionable, toAccount: Accountable, handler: @escaping (Accountable) -> Void) {
        var account = toAccount
        account.totalAmount = arithmeticTransaction(accountAmount: toAccount.totalAmount, transactionAmount: transaction.ammount)
        account.transactions.append(transaction)
        handler(account)
    }
}
