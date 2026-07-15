//
//  BaseViewController.swift
//  DigiVahan
//
//  Created by Mr Ash on 14/05/26.
//

import UIKit

class BaseViewController: UIViewController {

    var receivedData: Any?
    
    override func viewDidLoad() {
            super.viewDidLoad()

            enableKeyboardDismissOnTap()
        
        }
    
    func enableAutoScroll(
        textField: UITextField,
        scrollView: UIScrollView,
        scrollTargetView: UIView
    ) {

        NotificationCenter.default.addObserver(
            forName: UITextField.textDidBeginEditingNotification,
            object: textField,
            queue: .main
        ) { _ in

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

                let rect = scrollTargetView.convert(
                    scrollTargetView.bounds,
                    to: scrollView
                )

                scrollView.scrollRectToVisible(rect, animated: true)
            }
        }
    }
    
    
//    enableKeyboardAvoiding(scrollView: mainScrollView)
    func enableKeyboardAvoiding(
        scrollView: UIScrollView
    ) {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        self.keyboardScrollView = scrollView
    }

    private struct AssociatedKeys {
        static var keyboardScrollView = "keyboardScrollView"
    }

    private var keyboardScrollView: UIScrollView? {
        get {
            objc_getAssociatedObject(
                self,
                &AssociatedKeys.keyboardScrollView
            ) as? UIScrollView
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.keyboardScrollView,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {

        guard
            let keyboardFrame =
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                    as? CGRect
        else { return }

        keyboardScrollView?.contentInset.bottom = keyboardFrame.height
        keyboardScrollView?.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
    }

    @objc func keyboardWillHide(_ notification: Notification) {

        keyboardScrollView?.contentInset.bottom = 0
        keyboardScrollView?.verticalScrollIndicatorInsets.bottom = 0
    }
}
