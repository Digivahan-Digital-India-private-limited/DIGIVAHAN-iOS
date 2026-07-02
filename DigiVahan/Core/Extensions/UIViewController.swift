//
//  UIViewController.swift
//  DigiVahan
//
//  Created by Mr Ash on 27/05/26.
//

import UIKit

extension UIViewController {

    func showToast(message: String) {

        let toastLabel = UILabel()

        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 14)

        toastLabel.backgroundColor =
        UIColor.black.withAlphaComponent(0.8)

        toastLabel.numberOfLines = 0
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true

        toastLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toastLabel)

        NSLayoutConstraint.activate([

            toastLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),

            toastLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),

            toastLabel.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -40
            )
        ])

        UIView.animate(withDuration: 0.3) {

            toastLabel.alpha = 1

        } completion: { _ in

            UIView.animate(
                withDuration: 0.3,
                delay: 2,
                options: .curveEaseOut
            ) {

                toastLabel.alpha = 0

            } completion: { _ in

                toastLabel.removeFromSuperview()
            }
        }
    }
    
    
    func enableKeyboardDismissOnTap() {

            let tapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(hideKeyboard)
            )

            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
        }

        @objc func hideKeyboard() {
            view.endEditing(true)
        }
}
