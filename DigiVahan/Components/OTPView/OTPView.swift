//
//  OTPView.swift
//  DigiVahan
//
//  Created by Mr Ash on 29/05/26.
//

//
//  OTPView.swift
//

import UIKit

class OTPView: UIView {

    // MARK: - Public Properties

    var otpLength: Int = 6 {
        didSet {
            setupFields()
        }
    }

    var boxSpacing: CGFloat = 12 {
        didSet {
            stackView.spacing = boxSpacing
        }
    }

    var onOtpComplete: ((String) -> Void)?

    // MARK: - Private Properties

    private let stackView = UIStackView()
    private var textFields: [UITextField] = []

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - Setup

    private func commonInit() {

        backgroundColor = .clear

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = boxSpacing

        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        setupFields()
    }

    private func setupFields() {

        textFields.removeAll()

        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for index in 0..<otpLength {

            let textField = OTPTextField()

            textField.tag = index
            textField.delegate = self
            textField.keyboardType = .numberPad
            textField.textAlignment = .center
            textField.font = UIFont.systemFont(ofSize: 20, weight: .semibold)

            textField.layer.cornerRadius = 10
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.systemGray4.cgColor

            textField.layer.shadowColor = UIColor.black.cgColor
            textField.layer.shadowOpacity = 0.08
            textField.layer.shadowRadius = 4
            textField.layer.shadowOffset = CGSize(width: 0, height: 2)

            textField.backgroundColor = .white

            textField.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                textField.widthAnchor.constraint(equalToConstant: 40),
                textField.heightAnchor.constraint(equalToConstant: 40)
            ])

            textField.addTarget(
                self,
                action: #selector(textDidChange(_:)),
                for: .editingChanged
            )

            stackView.addArrangedSubview(textField)
            textFields.append(textField)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textFields.first?.becomeFirstResponder()
        }
    }

    // MARK: - Text Changed

    @objc private func textDidChange(_ textField: UITextField) {

        guard let text = textField.text else { return }

        if text.count > 1 {
            textField.text = String(text.prefix(1))
        }

        if text.count == 1 {

            let nextTag = textField.tag + 1

            if nextTag < otpLength {
                textFields[nextTag].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }

        checkOTPCompletion()
    }

    // MARK: - Public Methods

    func getOTP() -> String {

        return textFields.compactMap {
            $0.text
        }.joined()
    }

    func setOTP(_ otp: String) {

        for (index, char) in otp.enumerated() {

            if index < textFields.count {
                textFields[index].text = String(char)
            }
        }

        checkOTPCompletion()
    }

    func clearOTP() {

        textFields.forEach {
            $0.text = ""
        }

        textFields.first?.becomeFirstResponder()
    }

    // MARK: - Private

    private func checkOTPCompletion() {

        let otp = getOTP()

        if otp.count == otpLength {
            onOtpComplete?(otp)
        }
    }
}

// MARK: - UITextFieldDelegate

extension OTPView: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        // Backspace pressed
        if string.isEmpty {

            let currentText = textField.text ?? ""

            // If current field has value, clear it and move back
            if !currentText.isEmpty {

                textField.text = ""

                let previousTag = textField.tag - 1

                if previousTag >= 0 {
                    textFields[previousTag].becomeFirstResponder()
                }

                return false
            }

            // If already empty, move back
            let previousTag = textField.tag - 1

            if previousTag >= 0 {
                textFields[previousTag].text = ""
                textFields[previousTag].becomeFirstResponder()
            }

            return false
        }

        return true
    }
}

// MARK: - Custom TextField

class OTPTextField: UITextField {

    override func deleteBackward() {

        super.deleteBackward()

        sendActions(for: .editingChanged)
    }
}
