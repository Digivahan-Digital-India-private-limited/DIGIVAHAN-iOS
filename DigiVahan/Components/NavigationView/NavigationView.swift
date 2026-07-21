//
//  NavigationView.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/06/26.
//

import UIKit

class NavigationView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dialogView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!

    @IBOutlet weak var proceedBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    var onProceed: ((String) -> Void)?

    // MARK: - Init

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

        Bundle.main.loadNibNamed(
            "NavigationView",
            owner: self,
            options: nil
        )

        addSubview(contentView)

        contentView.frame = bounds
        contentView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]

        backgroundColor = UIColor.black.withAlphaComponent(0)

        dialogView.layer.cornerRadius = 20
        dialogView.clipsToBounds = true

        proceedBtn.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10

        cancelBtn.addTarget(
            self,
            action: #selector(closeDialog),
            for: .touchUpInside
        )
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

    // MARK: - Show Animation

    func showAnimated() {

        dialogView.transform = CGAffineTransform(
            translationX: -UIScreen.main.bounds.width,
            y: 0
        )

        dialogView.alpha = 0

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {

            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.dialogView.transform = .identity
            self.dialogView.alpha = 1
        }
    }

    // MARK: - Hide Animation

    func hideAnimated(
        completion: (() -> Void)? = nil
    ) {

        UIView.animate(
            withDuration: 0.25,
            animations: {

                self.backgroundColor = UIColor.black.withAlphaComponent(0)

                self.dialogView.transform = CGAffineTransform(
                    translationX: -UIScreen.main.bounds.width,
                    y: 0
                )

                self.dialogView.alpha = 0

            },
            completion: { _ in

                self.removeFromSuperview()

                completion?()
            }
        )
    }

    // MARK: - Proceed Button

    @IBAction func proceedBtnClicked(_ sender: UIButton) {

        let value = inputField.text?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ) ?? ""

        if value.isEmpty {
            return
        }

        hideAnimated {

            self.onProceed?(value)
        }
    }

    // MARK: - Close Dialog

    @objc func closeDialog() {

        hideAnimated()
    }
}
