//
//  UseCasesTest.swift
//  ExpensesTrackerTests
//
//  Created by Carlos Fernandez López on 27/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import XCTest
@testable import ExpensesTracker

class UseCasesTest: ExpensesTrackerTests {
    var documentURL: URL! = nil
    var disk: DiskManager! = nil
    var persist: PersistCodable! = nil
    var removeTranscation: RemoveTransactionManager! = nil
    var addTransaction: AddTransactionManager! = nil
    var populateAccounts: PopulateAccounts! = nil
    
    override func setUpWithError() throws {
        documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        disk = DiskManager(path: documentURL)
        persist = PersistCodable(disk: disk, decoder: .init(), enconder: .init())
        removeTranscation = RemoveTransactionManager(persistance: persist)
        addTransaction = AddTransactionManager(persistance: persist)
        populateAccounts = PopulateAccounts(persist: persist)
    }
    
    override func tearDownWithError() throws {
        documentURL = nil
        disk = nil
        persist = nil
    }
    
    func testRemoveTransaction() {
        let expect = expectation(description: "Account saved")
        let expect2 = expectation(description: "Transacion removed")
        let semaphore = DispatchSemaphore(value: 0)
        let transaction = Transaction(id: UUID().uuidString, ammount: 50, title: "Grocery", date: Date(), isIncome: false)
        let account = Account(title: "Cash", totalAmount: 100, transactions: [transaction])
        
        persist.save(value: account, for: .cash) { (error: Error?) in
            if error != nil {XCTFail("Could not save account")}
            expect.fulfill()
            semaphore.signal()
        }
        semaphore.wait()
        
        removeTranscation.removeTransaction(transaction: transaction, accountType: .cash) { (account: Account?, error: Error?) in
            if error != nil {XCTFail("Could not remove transaction")}
            if let account = account {
                XCTAssertTrue(account.transactions.count == 0)
                XCTAssertTrue(account.title == "Cash")
                XCTAssertTrue(account.totalAmount.isEqual(to: 50.0))
                expect2.fulfill()
            }
            
            semaphore.signal()
        }
        semaphore.wait()
        wait(for: [expect, expect2], timeout: 5)
    }
    
    func testAddTransaction() {
        let expect = expectation(description: "Account saved")
        let expect2 = expectation(description: "Transacion removed")
        let semaphore = DispatchSemaphore(value: 0)
        
        let account = Account(title: "Cash", totalAmount: 100, transactions: [])
        
        persist.save(value: account, for: .cash) { (error: Error?) in
            if error != nil {XCTFail("Could not save account")}
            expect.fulfill()
            semaphore.signal()
        }
        semaphore.wait()
        
        let transaction = Transaction(id: UUID().uuidString, ammount: -50, title: "Grocery", date: Date(), isIncome: false)
        addTransaction.addTransaction(transaction: transaction, accountType: .cash) { (account: Account?, error: Error?) in
            if error != nil {XCTFail("Could not add transaction")}
            if let account = account {
                XCTAssertTrue(account.transactions.count == 1)
                XCTAssertTrue(account.title == "Cash")
                XCTAssertTrue(account.totalAmount.isEqual(to: 50.0))
                expect2.fulfill()
            }
            semaphore.signal()
        }
        semaphore.wait()
        wait(for: [expect, expect2], timeout: 5)
    }
    
    func testKickOff() {
        let expect = expectation(description: "Accounts created")
        populateAccounts.kickOff { (error: Error?, accounts: [Account]?) in
            if error != nil {XCTFail("Could not star accounts")}
            XCTAssertTrue(accounts?.count == 3)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
    }
    
    func testFetchAccount() {
        let expect = expectation(description: "Accounts created")
        populateAccounts.fetchAccounts { (error: Error?, accounts) in
            if error != nil {XCTFail("Could not find accounts")}
            XCTAssertTrue(accounts?.count == 3)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5)
    }
}
