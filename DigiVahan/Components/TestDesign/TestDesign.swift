//
//  TestDesign.swift
//  DigiVahan
//
//  Created by Mr Ash on 19/05/26.
//

import UIKit

class TestDesign: UIView, UITextFieldDelegate {

    // MARK: - Outlets

    @IBOutlet weak var mainContentView: UIView!

    @IBOutlet weak var fieldTitle: UILabel!

    @IBOutlet weak var errorStackViewLayout: UIStackView!
    @IBOutlet weak var imgError: UIImageView!
    @IBOutlet weak var lblError: UILabel!

    @IBOutlet weak var borderView: UIView!

    @IBOutlet weak var fieldIcon: UIImageView!
    @IBOutlet weak var txtInputField: UITextField!
    @IBOutlet weak var passwordEyeIcon: UIImageView!

    // MARK: - Variables

    private var isPasswordVisible = false
    var fieldType: FieldType = .normal

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - Common Init
    private func commonInit() {

        Bundle.main.loadNibNamed(
            "CustomInputFieldView",
            owner: self,
            options: nil
        )

        guard let contentView = mainContentView else { return }

        contentView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentView)

        NSLayoutConstraint.activate([

            contentView.topAnchor.constraint(equalTo: topAnchor),

            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),

            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)

        ])

        setupUI()
    }

    // MARK: - Setup UI

    private func setupUI() {

        // Hide Error Initially
        errorStackViewLayout.isHidden = true

        // Password Secure
        txtInputField.isSecureTextEntry = false

        // Right Icon Click
        passwordEyeIcon.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(togglePasswordVisibility)
        )

        passwordEyeIcon.addGestureRecognizer(tap)

        // Text Changed
        txtInputField.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )
    }
    
    func getValue() -> String {

        return txtInputField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    // MARK: - Configure

    func setUpField(
        title: String,
        placeholder: String,
        leftIcon: UIImage?,
        keyboardType: UIKeyboardType = .default, inputType: FieldType
    ) {
        
        self.fieldType = inputType

        fieldTitle.text = title
        
        

        txtInputField.placeholder = placeholder

        fieldIcon.image = leftIcon

        txtInputField.keyboardType = keyboardType
        
        txtInputField.delegate = self
        
        txtInputField.tintColor = UIColor(named: "iconColor")
        
        // Apply Delegate
            txtInputField.delegate = self
        
        setFieldType(inputType)
    }

    // MARK: - Show Error

    func showError(_ message: String) {

        errorStackViewLayout.isHidden = false

        lblError.text = message
        
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor =
        UIColor.red.cgColor

        lblError.textColor = .red

        imgError.tintColor = .red
    }

    // MARK: - Clear Error

    func clearError() {

        errorStackViewLayout.isHidden = true

        borderView.layer.borderColor =
        UIColor.white.cgColor
    }

    // MARK: - Text Changed

    @objc func textDidChange() {

        clearError()
    }

    // MARK: - Password Toggle

    @objc func togglePasswordVisibility() {

        isPasswordVisible.toggle()

        txtInputField.isSecureTextEntry =
        !isPasswordVisible

        if isPasswordVisible {

            passwordEyeIcon.image =
            UIImage(named: "eyeOpenIcon")

        } else {

            passwordEyeIcon.image =
            UIImage(named: "eyeCloseIcon")
        }
    }
    
    func setFieldType(_ type: FieldType) {

        txtInputField.autocorrectionType = .no

        switch type {

        case .email:
            txtInputField.keyboardType = .emailAddress
            txtInputField.autocapitalizationType = .none


        case .phone:
            txtInputField.keyboardType = .numberPad


        case .number:
            txtInputField.keyboardType = .numberPad


        case .name:
            txtInputField.keyboardType = .default
            txtInputField.autocapitalizationType = .words


        case .pan:
            txtInputField.keyboardType = .asciiCapable
            txtInputField.autocapitalizationType = .allCharacters


        case .pincode:
            txtInputField.keyboardType = .numberPad


        case .aadhar:
            txtInputField.keyboardType = .numberPad


        case .pollution:
            txtInputField.keyboardType = .asciiCapable
            txtInputField.autocapitalizationType = .allCharacters


        case .insurance:
            txtInputField.keyboardType = .asciiCapable
            txtInputField.autocapitalizationType = .allCharacters


        case .rc:
            txtInputField.keyboardType = .asciiCapable
            txtInputField.autocapitalizationType = .allCharacters


        case .drivingLicence:
            txtInputField.keyboardType = .asciiCapable
            txtInputField.autocapitalizationType = .allCharacters


        case .password:
            passwordEyeIcon.isHidden = false
            txtInputField.keyboardType = .default
            txtInputField.isSecureTextEntry = true


        case .normal, .age:

            txtInputField.keyboardType = .default
        }
    }
    
}

extension TestDesign {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else {
            return false
        }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        switch fieldType {

        case .phone:

            let isNumber =
            string.allSatisfy { $0.isNumber } || string.isEmpty

            return isNumber && updatedText.count <= 10

        case .aadhar:

            let isNumber =
            string.allSatisfy { $0.isNumber } || string.isEmpty

            return isNumber && updatedText.count <= 12

        case .pincode:

            let isNumber =
            string.allSatisfy { $0.isNumber } || string.isEmpty

            return isNumber && updatedText.count <= 6

        default:
            return updatedText.count <= 30
        }
    }
    
    func validateField() -> Bool {

        let text = txtInputField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if text.isEmpty {
            showError("Field can't be empty")
            return false
        }
        
        switch fieldType {
            
        case .email:
            
            if !isValidEmail(text) {
                showError("Please enter valid email")
                return false
            }
            
        case .name:
            if text.count < 3 {
                showError("Name must be at least 3 characters")
                return false
            }
            
        case .phone:
            if text.count < 10 || !text.allSatisfy(\.isNumber) ||
                !isValidPhone(text){
                showError("Invalid Number")
                return false
            }
        
        case .password:
            if text.count < 5 {
                showError("Must be at least 5 characters")
                return false
            }
        

        default:
            break
        }

        return true
    }
    
    func isValidEmail(_ email: String) -> Bool {

        let emailRegex =
        "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailPredicate =
        NSPredicate(format: "SELF MATCHES %@", emailRegex)

        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPhone(_ phone: String) -> Bool {

        let phone = phone.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        // 1️⃣ Must be exactly 10 digits
        let phoneRegex = "^[0-9]{10}$"

        let phonePredicate =
        NSPredicate(format: "SELF MATCHES %@", phoneRegex)

        if !phonePredicate.evaluate(with: phone) {
            return false
        }

        // 2️⃣ All digits same
        let firstChar = phone.first

        let allSame = phone.allSatisfy {
            $0 == firstChar
        }

        if allSame {
            return false
        }

        // 3️⃣ Sequential numbers
        let asc = "0123456789"
        let desc = "9876543210"

        if asc.contains(phone) || desc.contains(phone) {
            return false
        }

        // 4️⃣ Indian mobile numbers start from 6–9
        guard let firstDigit = phone.first else {
            return false
        }

        if let digit = Int(String(firstDigit)),
           digit < 6 {

            return false
        }

        return true
    }
    
    func setText(_ text: String) {
        txtInputField.text = text
    }
}



