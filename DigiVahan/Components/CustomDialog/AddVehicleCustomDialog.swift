//
//  AddVehicleCustomDialog.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/06/26.
//

import UIKit

class AddVehicleCustomDialog: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dialogView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!

    @IBOutlet weak var proceedBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    var onProceed: ((String) -> Void)?
    var onCancel: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {

        Bundle.main.loadNibNamed(
            "AddVehicleCustomDialog",
            owner: self,
            options: nil
        )

        addSubview(contentView)

        contentView.frame = bounds
        contentView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]

        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        dialogView.layer.cornerRadius = 20
        dialogView.clipsToBounds = true

        proceedBtn.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10
        
        inputField.delegate = self
        inputField.autocapitalizationType = .allCharacters

    }

    // MARK: - Configure Dialog

    func configure(
        title: String,
        description: String,
        hint: String,
        buttonTitle: String,
        defaultValue: String = ""
    ) {

        titleLabel.text = title
        subTitleLabel.text = description
        inputField.placeholder = hint
        inputField.text = defaultValue

        proceedBtn.setTitle(
            buttonTitle,
            for: .normal
        )
    }

    // MARK: - Proceed Button

    @IBAction func proceedBtnClicked(_ sender: UIButton) {

        let value = inputField.text?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

        onProceed?(value)
        
        if value.isEmpty {
            return
        }
        
        removeFromSuperview()
    }
    
    // MARK: - Close Dialog
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        removeFromSuperview()

        onCancel?("closeDialog")
    }

    // MARK: - Close Dialog

}

extension AddVehicleCustomDialog: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        let currentText = textField.text ?? ""

        guard let textRange = Range(range, in: currentText) else {
            return false
        }

        var updatedText = currentText
            .replacingCharacters(in: textRange, with: string)
            .uppercased()

        // Limit vehicle number to 14 characters
        if textField == inputField && updatedText.count > 14 {
            updatedText = String(updatedText.prefix(20))
        }

        textField.text = updatedText

        return false
    }
}
