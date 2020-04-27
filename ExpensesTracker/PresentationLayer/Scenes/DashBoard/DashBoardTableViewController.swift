//
//  DashBoardTableViewController.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import UIKit

class DashBoardTableViewController: UITableViewController {
    
    var presenter: DashPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dashboard"
        DashBoardDIContainer.assembleDashBoardSceneWith(viewController: self)
        setUpTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddTransaction))
        presenter?.kickOff(completionHandler: { (error: Error?) in
            if error == nil {
                self.tableView.reloadData()
            }
        })
    }
    
    @objc func showAddTransaction() {
        let transactionViewController = AddTransactionViewController()
        transactionViewController.commitCallBack = {
            self.presenter?.fetchAccounts(completionHandler: { (error: Error?) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
        transactionViewController.view.backgroundColor = .white
        let navigationController = UINavigationController(rootViewController: transactionViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view setup
    
    func setUpTableView() {
        self.tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: TransactionTableViewCell.className)
        self.tableView.register(AccountSection.self, forHeaderFooterViewReuseIdentifier: AccountSection.className)
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return presenter?.numberOfSections ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return presenter?.cashAccount?.transactions.count ?? 0
        case 1:
            return presenter?.bankAccount?.transactions.count ?? 0
        case 2:
            return presenter?.creditAccount?.transactions.count ?? 0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let accountSeciontView = tableView.dequeueReusableHeaderFooterView(withIdentifier: AccountSection.className) as? AccountSection else { fatalError("Wrong type of cell") }
        switch section {
        case 0:
            accountSeciontView.populateWithEntity(account: presenter?.cashAccount)
        case 1:
            accountSeciontView.populateWithEntity(account: presenter?.bankAccount)
        case 2:
            accountSeciontView.populateWithEntity(account: presenter?.creditAccount)
        default:
            break
        }
        return accountSeciontView
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.className, for: indexPath) as? TransactionTableViewCell else { fatalError("Wrong type of cell") }
        switch indexPath.section {
        case 0:
            cell.populateCellWith(transaction: presenter?.cashAccount?.transactions[indexPath.row])
        case 1:
            cell.populateCellWith(transaction: presenter?.bankAccount?.transactions[indexPath.row])
        case 2:
            cell.populateCellWith(transaction: presenter?.creditAccount?.transactions[indexPath.row])
        default:
            break
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            switch indexPath.section {
            case 0:
                guard let transaction = presenter?.cashAccount?.transactions[indexPath.row] else { return }
                presenter?.deleteTransaction(transaction: transaction, accountType: .cash, completionHandler: { (error: Error?) in
                    if error == nil {
                        DispatchQueue.main.async {
                            tableView.reloadData()
                        }
                    }
                })
            case 1:
                guard let transaction = presenter?.bankAccount?.transactions[indexPath.row] else { return }
                presenter?.deleteTransaction(transaction: transaction, accountType: .bank, completionHandler: { (error: Error?) in
                    if error == nil {
                        DispatchQueue.main.async {
                            tableView.reloadData()
                        }
                    }
                })
            case 2:
                guard let transaction = presenter?.creditAccount?.transactions[indexPath.row] else { return }
                presenter?.deleteTransaction(transaction: transaction, accountType: .credit, completionHandler: { (error: Error?) in
                    if error == nil {
                        DispatchQueue.main.async {
                            tableView.reloadData()
                        }
                    }
                })
            default:
                break
            }
        }
    }
}
