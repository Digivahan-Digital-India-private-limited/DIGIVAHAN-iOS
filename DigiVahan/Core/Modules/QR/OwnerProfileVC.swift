//
//  EmergencyContactsListVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/06/26.
//


import UIKit
import SDWebImage

class OwnerProfileVC: BaseViewController {

    private var qrItem: QRDataModel?
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var ownerAge: UILabel!
    @IBOutlet weak var ownerGender: UILabel!
    @IBOutlet weak var ownerLocation: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var callBtn: UIButton!
    private var countdownTimer: Timer?
    private var remainingSeconds = 30
    
    
        
    override func viewDidLoad() {
        super.viewDidLoad()

        enableKeyboardDismissOnTap()
        setUI()

    }
    
    @IBAction func callBtnClicked(_ sender: Any) {
        makeCall(receiverNumber: qrItem?.ownerNumber)
    }
    
    private func setUI() {

        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont(name: "Hind-Medium", size: 20)!,
                .foregroundColor: UIColor.black
            ]
        
        
        if let data = receivedData as? [String: Any] {

            self.qrItem = data["qrItem"] as? QRDataModel ?? nil
            
            
        }
        
        
        userProfileImage.layer.cornerRadius =
                userProfileImage.frame.width / 2

            userProfileImage.clipsToBounds = true
            userProfileImage.contentMode = .scaleAspectFill
        
        
        self.ownerName.text = self.qrItem?.nick_name
        self.ownerGender.text = self.qrItem?.gender
        self.ownerLocation.text = self.qrItem?.address
        self.ownerAge.text = "\(self.qrItem?.age ?? "") year old"
        
        self.userProfileImage.sd_setImage(
            with: URL(string: self.qrItem?.public_pic ?? ""),
            placeholderImage: UIImage(named: "defaultProfileIcon")
        )
        
        enableCallButton()
        
       
    }

    
    func makeCall(receiverNumber: String?) {
        
        print("receiverNumber:- \(String(describing: receiverNumber))")

        LoadingManager.shared.show(on: view)


        let params: [String: Any] = [
            "agent": PreferenceManager.shared.getUser()?.phoneNumber ?? "",
            "receiver": receiverNumber ?? ""
        ]

        NetworkManager.shared.callAPI(
            url: APIEndpoints.CONTACT_VIA_CALL,
            method: "POST",
            parameters: params
        ) { response, status, message in

            LoadingManager.shared.hide()

            if status {

                self.showToast(message: "Call initiated successfully")
                
                self.disableCallButton()
                
                self.startCountdown()
            } else {
                self.showToast(message: "Can't initiate a Call")
            }
        }
    }
    
    private func disableCallButton() {

        if #available(iOS 15.0, *) {

            var config = self.callBtn.configuration
            config?.baseBackgroundColor = UIColor(named: "textDescription")
            config?.baseForegroundColor = .white
            self.callBtn.configuration = config
        } else {

            self.callBtn.backgroundColor = UIColor(named: "textDescription")
            self.callBtn.setTitleColor(.white, for: .normal)
        }

        self.callBtn.isEnabled = false
    }
    
    private func enableCallButton() {

        if #available(iOS 15.0, *) {

            var config = self.callBtn.configuration
            config?.baseBackgroundColor = UIColor(named: "iconColor")
            config?.baseForegroundColor = .white
            self.callBtn.configuration = config
        } else {

            self.callBtn.backgroundColor = UIColor(named: "iconColor")
            self.callBtn.setTitleColor(.white, for: .normal)
        }

        self.callBtn.isEnabled = true
    }
    
    private func startCountdown() {

        remainingSeconds = 30

        self.callBtn.setTitle("Wait (\(remainingSeconds))", for: .normal)

        countdownTimer?.invalidate()

        countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] timer in

            guard let self = self else { return }

            self.remainingSeconds -= 1

            self.callBtn.setTitle(
                "Wait (\(self.remainingSeconds))",
                for: .normal
            )

            if self.remainingSeconds <= 0 {

                timer.invalidate()

                self.callBtn.setTitle(
                    "Call",
                    for: .normal
                )
                
                enableCallButton()
            }
        }
    }

}
