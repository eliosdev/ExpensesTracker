//
//  AddTransactionViewController.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 25/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//

import UIKit

class AddTransactionViewController: UIViewController {
    
    var presenter: TransactionPresenter?
    var commitCallBack: (()->Void)?
    var doneButton: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Transaction"
        setUpNavigationItems()
        setUpViews()
        AddTransactionDIContainer.assembleAddTransactionSceneWith(viewController: self)
        selecTransaction()
        loadSelectablesInTextFields()
    }
    
    func setUpNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissController))
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(commitTransaction))
        navigationItem.rightBarButtonItem = doneButton
        doneButton?.isEnabled = false
    }

    var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Expenses", "Inconmes"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(selecTransaction) , for: .valueChanged)
        return control
    }()
    
    lazy var accountTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 0
        textField.setLeftPaddingPoints(5.0)
        textField.delegate = self
        textField.placeholder = "Select account"
        textField.backgroundColor = .lightGray
        return textField
    }()
    
    lazy var transactionsTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 1
        textField.setLeftPaddingPoints(5.0)
        textField.delegate = self
        textField.placeholder = "Select category"
        textField.backgroundColor = .lightGray
        return textField
    }()
    
    lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter amount"
        textField.tag = 2
        textField.setLeftPaddingPoints(5.0)
        textField.delegate = self
        textField.keyboardType = .decimalPad
        textField.backgroundColor = .lightGray
        return textField
    }()
    
    func setUpViews() {
        let margins = view.layoutMarginsGuide
        
        let verticalStack = UIStackView(arrangedSubviews: [segmentedControl, accountTextField, transactionsTextField, amountTextField])
        verticalStack.spacing = 20
        verticalStack.axis = .vertical
        verticalStack.distribution = .fillEqually
        self.view.addSubview(verticalStack)
        verticalStack.anchor(top: margins.topAnchor, leading: margins.leadingAnchor, bottom: nil, trailing: margins.trailingAnchor, padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16))
    }
    
    func loadSelectablesInTextFields(){
        if var presenter = self.presenter {
            accountTextField.loadSelectedTextFrom(data: presenter.accounts)
            transactionsTextField.loadSelectedTextFrom(data: presenter.categories)
            presenter.selectedCategory = presenter.categories.first ?? ""
        }
    }
    
    @objc func commitTransaction() {
        self.view.endEditing(true)
        guard let presenter = self.presenter else { return  }
        presenter.commitTransaction(transactionType: presenter.selectedAccount, completionHandler: { (error: Error?) in
            if error == nil {
                self.commitCallBack?()
            }
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func selecTransaction() {
        if var presenter = self.presenter {
            presenter.typeOfTransaction = segmentedControl.selectedSegmentIndex == 0 ? "Expenses" : "Incomes"
            transactionsTextField.loadSelectedTextFrom(data: presenter.categories)
            presenter.selectedCategory = presenter.categories.first ?? ""
        }
    }
    
}

extension AddTransactionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText), var presenter = self.presenter else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField.tag {
        case 2:
            presenter.selectedAmmount = textField.text ?? ""
            doneButton?.isEnabled = presenter.doneButtonEnabled(text: updatedText)
        default:
            break
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard var presenter = self.presenter else { return }
        switch textField.tag {
        case 0:
            presenter.selectedAccount = presenter.convertSelectedAccount(text: textField.text ?? "")
        case 1:
            presenter.selectedCategory = textField.text ?? ""
        case 2:
            presenter.selectedAmmount = textField.text ?? ""
        default:
            break
        }
    }
}
