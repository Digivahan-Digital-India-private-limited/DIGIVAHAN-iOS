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

        // Close Button (top-right)
        let closeIconView = UIImageView()
        closeIconView.image = UIImage(named: "closeIcon")
        closeIconView.contentMode = .scaleAspectFit
        closeIconView.isUserInteractionEnabled = true
        closeIconView.translatesAutoresizingMaskIntoConstraints = false

        dialogView.addSubview(closeIconView)

        NSLayoutConstraint.activate([
            closeIconView.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 16),
            closeIconView.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor, constant: -16),
            closeIconView.widthAnchor.constraint(equalToConstant: 26),
            closeIconView.heightAnchor.constraint(equalToConstant: 26)
        ])

        let closeTap = UITapGestureRecognizer(target: self, action: #selector(cancelBtnClicked(_:)))
        closeIconView.addGestureRecognizer(closeTap)

    }

    // MARK: - Configure Dialog

    func configure(
        title: String,
        description: String,
        hint: String = "",
        buttonTitle: String,
        cancelButtonTitle: String = "Cancel",
        defaultValue: String = "",
        isInputFieldHidden: Bool = false
    ) {

        titleLabel.text = title
        subTitleLabel.text = description
        inputField.placeholder = hint
        inputField.text = defaultValue
        inputField.isHidden = isInputFieldHidden

        proceedBtn.setTitle(
            buttonTitle,
            for: .normal
        )
        
        cancelBtn.setTitle(
            cancelButtonTitle,
            for: .normal
        )

        if isInputFieldHidden {
            // Remove top constraint and center vertically
            if let topConstraint = contentView.constraints.first(where: {
                ($0.firstItem as? UIView == dialogView && $0.firstAttribute == .top) ||
                ($0.secondItem as? UIView == dialogView && $0.secondAttribute == .top)
            }) {
                topConstraint.isActive = false
            }
            dialogView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

            // Adjust height constraint when input field is hidden
            if let heightConstraint = dialogView.constraints.first(where: { $0.firstAttribute == .height }) {
                heightConstraint.constant = 390
            }
        }
    }

    // MARK: - Proceed Button

    @IBAction func proceedBtnClicked(_ sender: UIButton) {

        let value = inputField.text?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

        if !inputField.isHidden && value.isEmpty {
            return
        }

        onProceed?(value)
        
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
