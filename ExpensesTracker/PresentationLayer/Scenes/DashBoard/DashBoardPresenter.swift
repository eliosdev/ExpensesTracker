//
//  DashBoardPresenter.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

protocol DashBoardInput {
    func deleteTransaction(transaction: Transaction, accountType: Accounts, completionHandler: @escaping (Error?)->Void)
    func kickOff(completionHandler: @escaping (Error?)->Void)
}

protocol DashBoardOutPut {
    var numberOfSections: Int { get }
    var cashAccount: Account? { get set }
    var creditAccount: Account? { get set }
    var bankAccount: Account? { get set }
    var isIncome: Bool { get }
    func fetchAccounts(completionHandler:@escaping (Error?)->Void)
}

typealias DashPresenter = DashBoardInput & DashBoardOutPut

final class DashBoardPresenter {
    
    fileprivate var remove: RemoveTransactionUseCase
    fileprivate var populate: PopulateAccountsUseCase
    fileprivate let sections: Int = 3
    fileprivate var cash: Account?
    fileprivate var bank: Account?
    fileprivate var credit: Account?
    
    init(populateAccountsUseCase: PopulateAccountsUseCase, removeTransactionUseCase: RemoveTransactionUseCase) {
        self.populate = populateAccountsUseCase
        self.remove = removeTransactionUseCase
    }
}

extension DashBoardPresenter: DashPresenter {

    var numberOfSections: Int {
        return sections
    }
    
    var cashAccount: Account? {
        get {
            return cash
        }
        set {
            cash = newValue
        }
    }
    
    var creditAccount: Account? {
        get {
            return credit
        }
        set {
            credit = newValue
        }
    }
    
    var bankAccount: Account? {
        get {
            return bank
        }
        set {
            bank = newValue
        }
    }
    
    var isIncome: Bool {
        return false
    }
        
    func assignAccountsWith(accounts:[Account]?){
        // To improve and create mapping to identify accounts
        guard let accountsArray = accounts else { return }
        accountsArray.forEach {
            switch $0.title {
            case "Cash":
                self.cash = $0
            case "Bank Account":
                self.bank = $0
            case "Credit Card":
                self.credit = $0
            default:
                break
            }
        }
    }
    
    func kickOff(completionHandler: @escaping (Error?)->Void) {
        self.populate.kickOff { (error: Error?, account:[Account]?) in
            if let error = error {
                completionHandler(error)
            } else {
                self.assignAccountsWith(accounts: account)
                completionHandler(error)
            }
        }
    }
    
    func fetchAccounts(completionHandler: @escaping (Error?) -> Void) {
        self.populate.fetchAccounts { (error: Error?, account: [Account]?) in
            if let error = error {
                completionHandler(error)
            } else {
                self.assignAccountsWith(accounts: account)
                completionHandler(error)
            }
        }
    }
    
    func deleteTransaction(transaction: Transaction, accountType: Accounts, completionHandler: @escaping (Error?)->Void) {
        self.remove.removeTransaction(transaction: transaction, accountType: accountType) { (account:Account?, error: Error?) in
            if error == nil {
                switch accountType {
                case .bank:
                    self.bankAccount = account
                case .credit:
                    self.creditAccount = account
                case .cash:
                    self.cashAccount = account
                }
                completionHandler(error)
            } else {
                completionHandler(error)
            }
        }
    }

}
