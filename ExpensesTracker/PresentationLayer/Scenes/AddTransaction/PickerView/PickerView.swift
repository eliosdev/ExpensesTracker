//
//  PickerView.swift
//  ExpensesTracker
//
//  Created by Carlos Fernandez López on 26/04/2020.
//  Copyright © 2020 Carlos Fernandez López. All rights reserved.
//
import UIKit

class PickerView: UIPickerView {

    private var pickerData: [String]?
    private var textFieldWithPicker: UITextField?

    init(pickerData: [String], textField: UITextField) {
        super.init(frame: .zero)

        self.pickerData = pickerData
        self.textFieldWithPicker = textField

        self.delegate = self
        self.dataSource = self

        DispatchQueue.main.async {
            if pickerData.count > 0 {
                self.textFieldWithPicker?.text = self.pickerData?[0]
                self.textFieldWithPicker?.isEnabled = true
            } else {
                self.textFieldWithPicker?.text = nil
                self.textFieldWithPicker?.isEnabled = false
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("required initilizer not implemented")
    }
}

extension PickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData?.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData?[row] ?? ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textFieldWithPicker?.text = pickerData?[row] ?? ""
        perform(#selector(delayedResingFirstResponder), with: nil, afterDelay: 0.2)
    }

    @objc private func delayedResingFirstResponder() {
        self.textFieldWithPicker?.resignFirstResponder()
    }
}
