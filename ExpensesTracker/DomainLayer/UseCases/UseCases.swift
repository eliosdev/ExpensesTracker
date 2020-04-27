//
//  UseCases.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import Foundation

protocol RemoveTransactionUseCase {
    func removeTransaction(transaction: Transaction, accountType: Accounts, handler: @escaping (Account?, Error?)->Void)
}

final class RemoveTransactionManager: RemoveTransactionUseCase {
    
    fileprivate var persistance: Persistable
    
    init(persistance:Persistable) {
        self.persistance = persistance
    }
    
    func removeTransaction(transaction: Transaction, accountType: Accounts, handler: @escaping (Account?, Error?) -> Void) {
        var toDeleteAccount: Account?
        var fetchError: Error?
        
        // Get Account
        let semaphore = DispatchSemaphore(value: 0)
        self.persistance.fetch(for: accountType) { (error: Error?, account: Account?) in
            fetchError = error
            toDeleteAccount = account
            semaphore.signal()
        }
        semaphore.wait()
        
        // Operate Account
        guard var account = toDeleteAccount else {
            handler(nil, CoreError(title: "Missing Account", message: "Could no get Account instance", errorType: .writingDisk))
            return
        }
        account.totalAmount = account.totalAmount - transaction.ammount
        account.transactions.removeAll { $0.id == transaction.id}
        
        // Commit Saving
        self.persistance.save(value: account, for: accountType) { (error: Error?) in
            fetchError = error
            semaphore.signal()
        }
        semaphore.wait()
        
        handler(account, fetchError)
    }
}

protocol AddTransactionUseCase {
    func addTransaction(transaction: Transaction, accountType: Accounts, handler: @escaping (Account?, Error?) -> Void)
}

final class AddTransactionManager: AddTransactionUseCase {
    
    fileprivate var persistance: Persistable
    
    init(persistance:Persistable) {
        self.persistance = persistance
    }
    
    func addTransaction(transaction: Transaction, accountType: Accounts, handler: @escaping (Account?, Error?) -> Void) {
        var toAddAccount: Account?
        var fetchError: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        // Get Account
        self.persistance.fetch(for: accountType) { (error: Error?, account: Account?) in
            toAddAccount = account
            fetchError = error
            semaphore.signal()
        }
        semaphore.wait()
        
        // Operate Account
        guard var addAccount = toAddAccount else {
            handler(nil, CoreError(title: "Could not get Account", message: "There has been an error getting account", errorType: .writingDisk))
            return
        }
        addAccount.totalAmount = addAccount.totalAmount + transaction.ammount
        addAccount.transactions.append(transaction)
        
        // Commit Saving
        self.persistance.save(value: addAccount, for: accountType) { (error: Error?) in
            fetchError = error
            semaphore.signal()
        }
        semaphore.wait()
        
        handler(addAccount, fetchError)
        
    }
}

protocol PopulateAccountsUseCase {
    func kickOff(completionHanler: @escaping (Error?, [Account]?)->Void)
    func fetchAccounts(completionHandler:@escaping (Error?, [Account]?)->Void)
}

final class PopulateAccounts: PopulateAccountsUseCase {
    
    fileprivate var persistance: Persistable
    
    init(persist: Persistable) {
        self.persistance = persist
    }
    
    func kickOff(completionHanler: @escaping (Error?, [Account]?)->Void) {
        self.persistance.fetch(for: .cash) { (error: Error?, account: Account?) in
            if error != nil {
                self.populateAccounts { (error: Error?, accounts:[Account]?) in
                    completionHanler(error, accounts)
                }
            } else {
                self.fetchAccounts { (error: Error?, accounts:[Account]?) in
                    completionHanler(error, accounts)
                }
            }
        }
    }
    
    func populateAccounts(completionHandler:@escaping (Error?, [Account]?)->Void) {
        let dispatchGroup = DispatchGroup()
        var populateError: Error?
        var accountsArray = [Account]()
        
        dispatchGroup.enter()
        let cashAccount = Account(title:"Cash", totalAmount: 0.00, transactions: [])
        accountsArray.append(cashAccount)
        self.persistance.save(value: cashAccount,for: .cash) { (error: Error?) in
            populateError = error
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let bankAccount = Account(title:"Bank Account", totalAmount:0.00, transactions: [])
        accountsArray.append(bankAccount)
        self.persistance.save(value: bankAccount, for: .bank) { (error: Error?) in
            populateError = error
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        let creditCardAccount = Account(title: "Credit Card", totalAmount: 0.00, transactions: [])
        accountsArray.append(creditCardAccount)
        self.persistance.save(value: creditCardAccount, for: .credit) { (error: Error?) in
            populateError = error
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completionHandler(populateError, accountsArray)
        }
    }
    
    func fetchAccounts(completionHandler:@escaping (Error?, [Account]?)->Void) {
        let dispatchGroup = DispatchGroup()
        var fetchError: Error?
        var accountsArray = [Account]()
        
        dispatchGroup.enter()
        self.persistance.fetch(for: .cash) { (error:Error?, account: Account?) in
            if let cashAccount = account { accountsArray.append(cashAccount) }
            fetchError = error
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.persistance.fetch(for: .bank) { (error: Error?, account: Account?) in
            if let bankAccount = account { accountsArray.append(bankAccount) }
            fetchError = error
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.persistance.fetch(for: .credit) { (error:Error?, account: Account?) in
            if let creditAccount = account { accountsArray.append(creditAccount) }
            fetchError = error
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completionHandler(fetchError, accountsArray)
        }
    }
}
