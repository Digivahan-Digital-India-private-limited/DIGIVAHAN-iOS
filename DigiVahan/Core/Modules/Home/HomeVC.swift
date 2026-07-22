//
//  ProfileVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 03/06/26.
//

import UIKit
import SDWebImage
import OneSignalFramework

class HomeVC: UIView, UITextFieldDelegate {
    
    @IBOutlet var mainContentView: UIView!
    @IBOutlet weak var navigationProfileBtn: UIView!
    @IBOutlet weak var scanBtn: UIView!
    
    @IBOutlet weak var scanQRIconLayout: UIView!
    @IBOutlet weak var checkVehicleLayout: UIView!
    @IBOutlet weak var checkChallanLayout: UIView!
    @IBOutlet weak var challanPayLayout: UIView!
    @IBOutlet weak var activateQRLayout: UIView!
    @IBOutlet weak var myGarageLayout: UIView!
    @IBOutlet weak var downQRLayout: UIView!
    @IBOutlet weak var orderQRLayout: UIView!
    
    
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
            "Home",
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
        
        setUI()

    }
    
    func setUI() {
        
        setViewBg(myView: scanQRIconLayout)
        setViewBg(myView: checkVehicleLayout)
        setViewBg(myView: checkChallanLayout)
        setViewBg(myView: challanPayLayout)
        setViewBg(myView: activateQRLayout)
        setViewBg(myView: myGarageLayout)
        setViewBg(myView: downQRLayout)
        setViewBg(myView: orderQRLayout)
        
        // set aboutBtn
        navigationProfileBtn.isUserInteractionEnabled = true

            let navigationProfileBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(showNavigation)
            )

        navigationProfileBtn.addGestureRecognizer(navigationProfileBtnTap)
        
        // set scanBtn
        scanBtn.isUserInteractionEnabled = true

            let scanBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onScanBtnClick)
            )

        scanBtn.addGestureRecognizer(scanBtnTap)
    }
    
    func setViewBg(myView : UIView){
        myView.layer.cornerRadius = myView.frame.width / 2

           myView.layer.shadowColor = UIColor.black.cgColor
           myView.layer.shadowOpacity = 0.25
           myView.layer.shadowOffset = CGSize(width: 0, height: 3)
           myView.layer.shadowRadius = 8

           myView.layer.masksToBounds = false
    }
    
    @objc private func onScanBtnClick() {
        if let vc = parentViewController {
            NavigationManager.pushScreen(
                from: vc,
                storyboardName: "Main",
                viewControllerID: "ScanVC"
            )
        }
        
    }
    
    
    @objc private func showNavigation() {

        let dialog = NavigationView(
            frame: UIScreen.main.bounds
        )

        dialog.configure(
            title: "Verify Owner",
            description: "Please verify the vehicle owner before adding this vehicle.",
            hint: "Enter owner name",
            buttonTitle: "Verify"
        )

        dialog.onProceed = { value in
            print(value)
        }

        if let vc = parentViewController {
            vc.view.addSubview(dialog)
            dialog.showAnimated()
        }
    }

   
}
