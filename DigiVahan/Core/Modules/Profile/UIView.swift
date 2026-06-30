//
//  UIView.swift
//  DigiVahan
//
//  Created by Mr Ash on 03/06/26.
//

import UIKit

extension UIView {

    var parentViewController: UIViewController? {

        var parentResponder: UIResponder? = self

        while let responder = parentResponder {

            if let vc = responder as? UIViewController {
                return vc
            }

            parentResponder = responder.next
        }

        return nil
    }
}
