//
//  OTPView.swift
//  DigiVahan
//
//  Created by Mr Ash on 29/05/26.
//

//
//  OTPView.swift
//

// OTPView.swift
import UIKit

class OTPView: UIView, UITextFieldDelegate {

    var otpLength = 6 { didSet { buildBoxes() } }
    var boxSpacing: CGFloat = 12 { didSet { stack.spacing = boxSpacing } }
    var onOtpComplete: ((String)->Void)?

    private let stack = UIStackView()
    private let hiddenField = UITextField()
    private var labels:[UILabel] = []
    private var boxes:[UIView] = []
    private var editable = true

    override init(frame:CGRect){ super.init(frame:frame); setup() }
    required init?(coder:NSCoder){ super.init(coder:coder)!; setup() }

    private func setup(){
        stack.axis = .horizontal
        stack.spacing = boxSpacing
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo:centerXAnchor),
            stack.centerYAnchor.constraint(equalTo:centerYAnchor)
        ])

        hiddenField.keyboardType = .numberPad
        hiddenField.textContentType = .oneTimeCode
        hiddenField.tintColor = .clear
        hiddenField.textColor = .clear
        hiddenField.delegate = self
        hiddenField.addTarget(self, action:#selector(changed), for:.editingChanged)
        addSubview(hiddenField)

        addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(beginInput)))
        buildBoxes()
    }

    private func buildBoxes(){
        labels.removeAll(); boxes.removeAll()
        stack.arrangedSubviews.forEach{$0.removeFromSuperview()}
        for _ in 0..<otpLength{
            let v = UIView()
            v.layer.cornerRadius = 10
            v.layer.borderWidth = 1
            v.layer.borderColor = UIColor.systemGray4.cgColor
            NSLayoutConstraint.activate([
                v.widthAnchor.constraint(equalToConstant:42),
                v.heightAnchor.constraint(equalToConstant:46)
            ])
            let l = UILabel()
            l.font = .systemFont(ofSize:20,weight:.semibold)
            l.textAlignment = .center
            v.addSubview(l)
            l.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                l.centerXAnchor.constraint(equalTo:v.centerXAnchor),
                l.centerYAnchor.constraint(equalTo:v.centerYAnchor)
            ])
            stack.addArrangedSubview(v)
            boxes.append(v)
            labels.append(l)
        }
        refresh()
    }

    @objc private func beginInput(){ if editable { hiddenField.becomeFirstResponder() } }

    @objc private func changed(){
        hiddenField.text = String((hiddenField.text ?? "").filter{$0.isNumber}.prefix(otpLength))
        refresh()
        if getOTP().count == otpLength{
            hiddenField.resignFirstResponder()
            onOtpComplete?(getOTP())
        }
    }

    private func refresh(){
        let chars = Array(getOTP())
        for i in 0..<otpLength{
            labels[i].text = i < chars.count ? String(chars[i]) : ""
            boxes[i].layer.borderColor = (editable && i == chars.count) ? UIColor.systemBlue.cgColor : UIColor.systemGray4.cgColor
        }
    }

    func getOTP()->String{ hiddenField.text ?? "" }
    func setOTP(_ otp:String){ hiddenField.text = String(otp.prefix(otpLength)); refresh() }
    func clearOTP(){ hiddenField.text = ""; refresh() }
    func enableEditing(){ editable = true; hiddenField.isEnabled = true; refresh() }
    func disableEditing(){ editable = false; hiddenField.isEnabled = false; hiddenField.resignFirstResponder() }

    func textField(_ textField:UITextField, shouldChangeCharactersIn range:NSRange, replacementString string:String)->Bool{
        guard editable else { return false }
        if string.count > 1{
            hiddenField.text = String(string.filter{$0.isNumber}.prefix(otpLength))
            changed()
            return false
        }
        return true
    }
}
