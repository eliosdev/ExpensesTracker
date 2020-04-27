//
//  AddTransactionPresenter.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

protocol AddTransactionInput {
    func commitTransaction(transactionType: Accounts, completionHandler: @escaping(Error?)->Void)
    var typeOfTransaction: String { get set}
    var selectedAccount: Accounts { get set }
    var selectedCategory: String { get set }
    var selectedAmmount: String { get set}
}

protocol AddTransactionOutput {
    var accounts: [String] { get }
    var categories: [String] { get }
    func doneButtonEnabled(text: String) -> Bool
    func convertSelectedAccount(text: String) -> Accounts
}

typealias TransactionPresenter = AddTransactionInput & AddTransactionOutput

final class AddTransactionPresenter {
    fileprivate var persistance: Persistable
    fileprivate var usecase: AddTransactionUseCase
    fileprivate var transactionType: String = ""
    fileprivate var accountSelected: Accounts = .cash
    fileprivate var amountSelected: String = ""
    fileprivate var categorySelected: String = ""
    
    init(persistanceManager: Persistable, useCase: AddTransactionUseCase) {
        self.persistance = persistanceManager
        self.usecase = useCase
    }
}

extension AddTransactionPresenter: TransactionPresenter {
    var typeOfTransaction: String {
        get {
            return transactionType
        }
        set {
            transactionType = newValue
        }
    }
    
    var selectedAccount: Accounts {
        get {
            return accountSelected
        }
        set {
            accountSelected = newValue
        }
    }
    
    var selectedCategory: String {
        get {
            return categorySelected
        }
        set {
            categorySelected = newValue
        }
    }
    
    var selectedAmmount: String {
        get {
            return amountSelected
        }
        set {
            amountSelected = newValue
        }
    }
    
    var accounts: [String] {
        return ["Cash", "Bank Account", "Credit Card"]
    }
    
    var categories: [String] {
        return typeOfTransaction == "Expenses" ?  ["Tax", "Grocery", "Entertaiment", "Gym", "Health"] : ["Salary", "Dividends"]
    }
    
    func commitTransaction(transactionType: Accounts, completionHandler: @escaping(Error?)->Void) {
        let amount = self.converSelectedAmmount(text: selectedAmmount, typeOfTransacion: self.typeOfTransaction)
        let transaction = Transaction(id: UUID().uuidString, ammount: amount , title: selectedCategory, date: Date(),isIncome: typeOfTransaction == "Expenses" ? false : true)
        self.usecase.addTransaction(transaction: transaction, accountType: transactionType) { (account: Account?, error: Error?) in
            completionHandler(error)
        }
    }
    
    func converSelectedAmmount(text: String, typeOfTransacion: String) -> Float {
        let quantity = Float(text.replacingOccurrences(of: ",", with: ".")) ?? 0.00
        return typeOfTransaction == "Expenses" ? -quantity : quantity
    }
    
    func convertSelectedAccount(text: String) -> Accounts {
        switch text {
        case "Cash":
            return .cash
        case "Bank Account":
            return .bank
        case "Credit Card":
            return .credit
        default:
            return .cash
        }
    }
    
    func doneButtonEnabled(text: String) -> Bool {
        let quantity = Float(text.replacingOccurrences(of: ",", with: "."))
        if let _ = quantity?.isLess(than: 0.5) {
            return true
        } else {
            return false
        }
    }
}

