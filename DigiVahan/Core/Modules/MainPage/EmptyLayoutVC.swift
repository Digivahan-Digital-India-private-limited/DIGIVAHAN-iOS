//
//  EmptyLayoutVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 06/09/26.
//

import UIKit

class EmptyLayoutVC: BaseViewController {

    @IBOutlet weak var backBtn: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        backBtn.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(onBackBtnClick)
        )

        backBtn.addGestureRecognizer(tapGesture)
    }

    @objc private func onBackBtnClick() {
        NavigationManager.moveToNavigationController(
            from: self,
            storyboardName: "Main",
            navigationControllerID: "MainNavigationController"
        )
    }
}

