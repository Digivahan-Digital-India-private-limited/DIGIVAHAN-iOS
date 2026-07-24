//
//  ScanVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 13/06/26.
//

import UIKit
import AVFoundation

class ScanVC: BaseViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
        var onCodeScanned: ((String) -> Void)?
    
        private let captureSession = AVCaptureSession()
        private var previewLayer: AVCaptureVideoPreviewLayer!
        private var isScanning = true
    
    @IBOutlet weak var qrScanView: UIView!
    @IBOutlet weak var galleryBtn: UIImageView!
    @IBOutlet weak var flashBtn: UIImageView!
    
    var qrItem : QRDataModel!
    
    private var scanType: String = "connect"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
        
        // set galleryBtn
        galleryBtn.isUserInteractionEnabled = true

            let galleryBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(galleryBtnClick)
            )

        galleryBtn.addGestureRecognizer(galleryBtnTap)
        
        // set flashBtn
        flashBtn.isUserInteractionEnabled = true

            let flashBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(flashBtnClick)
            )

        flashBtn.addGestureRecognizer(flashBtnTap)
        
        if let data = receivedData as? [String: Any] {

            self.scanType = data["scanType"] as? String ?? ""
            
        }
        
    }
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
    
            print("🟢 ScannerVC viewWillAppear")
    
            if !captureSession.isRunning {

                DispatchQueue.global(qos: .userInitiated).async {

                    self.captureSession.startRunning()

                    DispatchQueue.main.async {
                        print("🟢 Camera started")
                    }
                }
            }
    
            isScanning = true
        }
    
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
    
            print("🟢 ScannerVC viewWillDisappear")
    
            if captureSession.isRunning {
                captureSession.stopRunning()
                print("🟢 Camera stopped")
            }
        }
    
    
    @objc private func flashBtnClick() {

        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }

        do {
            try device.lockForConfiguration()

            device.torchMode =
                device.torchMode == .on ? .off : .on

            device.unlockForConfiguration()

        } catch {
            print(error)
        }
    }
    
    
    @objc private func galleryBtnClick() {

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self

        present(picker, animated: true)
    }
    
}


extension ScanVC: AVCaptureMetadataOutputObjectsDelegate {
    
    private func setupCamera() {
        
        print("🟢 setupCamera called")
        
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            print("🔴 No camera found")
            return
        }
        
        do {
            
            print("🟢 Camera device found")
            
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                print("🟢 Camera input added")
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if captureSession.canAddOutput(metadataOutput) {
                
                captureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(
                    self,
                    queue: .main
                )
                
                metadataOutput.metadataObjectTypes = [
                    .qr,
                    .code39,
                    .aztec
                ]
                
                print("🟢 Metadata output added")
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            previewLayer.frame = qrScanView.bounds
            previewLayer.videoGravity = .resizeAspectFill
            
            qrScanView.layer.insertSublayer(previewLayer, at: 0)
            
            print("🟢 Preview layer added")
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()

                DispatchQueue.main.async {
                    print("🟢 Capture session started")
                }
            }
            
        } catch {
            
            print("🔴 setupCamera error: \(error)")
        }
    }
    
    
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        
        print("🟢 Barcode detected")
        
        guard isScanning else {
            print("🔴 isScanning = false")
            return
        }
        
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = object.stringValue else {
            
            print("🔴 Could not read barcode value")
            return
        }
        
        print("🟢 Scanned value: \(value)")
        
        handleQRCodeResult(value)
        
        isScanning = false
        
        captureSession.stopRunning()
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        onCodeScanned?(value)
        
//        navigationController?.popViewController(animated: true)
    }
    
    private func handleQRCodeResult(_ qrData: String) {

        let qrData = qrData.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)

        print("🟢 QR Code Scanned: \(qrData)")

        guard let lastPart = qrData.components(separatedBy: "/").last else {
            showAlert(message: "Invalid QR Code, Please try again.")
            return
        }

        let qrId = lastPart

        print("🟢 qrId: \(qrId)")

        LoadingManager.shared.show(on: view)

        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_QR_CODE_BY_ID + qrId,
            method: "GET",
            parameters: nil
        ) { response, status, message in

            LoadingManager.shared.hide()

            if status {

                print("🟢 API Success")

                guard let response = response,
                      let data = response["data"] as? [String: Any] else {

                    self.showAlert(message: "Invalid QR Code, Please try again.")
                    return
                }

                do {

                    let jsonData = try JSONSerialization.data(withJSONObject: data)

                    self.qrItem = try JSONDecoder().decode(QRDataModel.self, from: jsonData)

                    print("🟢 QR Status = \(self.qrItem.qr_status)")
                    print("🟢 Assigned To = \(self.qrItem.assigned_to ?? "")")

                    self.handleQRItem(self.qrItem)

                } catch {

                    print(error)
                    self.showAlert(message: "Invalid QR Code, Please try again.")
                }

            } else {

                self.showAlert(message: message)
            }
        }
    }
    
    private func handleQRItem(_ qrItem: QRDataModel) {
        if(scanType == "activate"){
            if qrItem.qr_status == "assigned" {
                self.showScannedDialog(qrItem: qrItem, vehicleNumber: "", responseType: "error")
            } else {
                checkGarageVehicle()
            }
            
        } else if(qrItem.assigned_to != nil && qrItem.assigned_to != "" && qrItem.assigned_to == PreferenceManager.shared.getUserId()){
            self.showAlert(message: "This user already login into your device.")
            
        } else if(scanType == "connect" && qrItem.qr_status == "assigned" && qrItem.assigned_to != nil && qrItem.assigned_to != ""){
            
            NavigationManager.pushScreen(
                from: self,
                storyboardName: "Main",
                viewControllerID: "NotificationAlertListVC",
                closeCurrentScreen: true,
                data: [
                        "qrItem": qrItem,
                        "scanType": scanType
                    ]
            )
            
        } else {
            self.showAlert(message: "This qr is invalid or not active.")
            
        }
    }
    
    func showScannedDialog(
        qrItem: QRDataModel,
        vehicleNumber: String = "",
        responseType: String
    ) {

        LoadingManager.shared.hide()

        var message = ""
        var cancelTitle = "Cancel"
        var confirmTitle = "OK"

        switch responseType.lowercased() {

        case "assign":
            message = "Are you sure you want to connect this (\(vehicleNumber)) vehicle?"
            cancelTitle = "Cancel"
            confirmTitle = "Connect"

        case "novehicle":
            message = "There is no (\(vehicleNumber)) vehicle in your garage. Please add it first."
            cancelTitle = "Retry"
            confirmTitle = "Add Vehicle"

        case "error":
            message = "Either the QR code is invalid or it has already been used by another user."
            cancelTitle = "Quit"
            confirmTitle = "Retry"

        default:
            return
        }

        let alert = UIAlertController(
            title: "Alert",
            message: message,
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in

            if responseType.lowercased() == "error" {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.refreshScanner()
            }
        }

        let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in

            switch responseType.lowercased() {

            case "assign":
                self.assignQR(vehicleId: vehicleNumber, qrItem: qrItem)

            case "error":
                self.refreshScanner()

            case "novehicle":

                NavigationManager.pushScreen(
                    from: self,
                    storyboardName: "Main",
                    viewControllerID: "GarageListVC",
                    data: [
                            "qrItem": qrItem
                        ]
                )

            default:
                break
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)

        present(alert, animated: true)
    }
    
    
    
    func showAlert(message: String, onRetry: (() -> Void)? = nil) {

        let alert = UIAlertController(
            title: "Alert",
            message: message,
            preferredStyle: .alert
        )

        let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
            self.refreshScanner()
        }

        let quitAction = UIAlertAction(title: "Quit", style: .destructive) { _ in

            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }

        alert.addAction(retryAction)
        alert.addAction(quitAction)

        present(alert, animated: true)
    }
    
    private func refreshScanner() {

        isScanning = true

        if captureSession.isRunning {
            captureSession.stopRunning()
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()

            DispatchQueue.main.async {
                print("🟢 Scanner refreshed")
            }
        }
    }
    
    
    private func checkGarageVehicle() {
        
        let dialog = AddVehicleCustomDialog(
            frame: UIScreen.main.bounds
        )
        
        dialog.configure(
            title: "Activate QR Code",
            description: "Please add vehicle number to activate this QR code.",
            hint: "Vehicle Number",
            buttonTitle: "Verify"
        )
        
        dialog.onProceed = { vehicleNumber in
            
            var vehicleExist = false
            
            if vehicleNumber.isEmpty {
                self.showToast(message: "Please enter vehicle Number")
                return
            }
            
            LoadingManager.shared.show(on: self.view)
            
            NetworkManager.shared.callAPI(
                url: APIEndpoints.GET_VEHICLE_LIST + PreferenceManager.shared.getUserId(),
                method: "GET",
                parameters: nil
            ) { [weak self] response, status, message in

                guard let self = self else { return }

                LoadingManager.shared.hide()

                if status {

                    do {

                        guard
                            let response = response,
                            let data = response["data"] as? [String: Any],
                            let vehicles = data["vehicles"] as? [[String: Any]]
                        else {

                            self.showToast(message: "Vehicle not found")
                            return
                        }

                        _ = try JSONSerialization.data(
                            withJSONObject: vehicles,
                            options: []
                        )

                        for vehicle in vehicles {
    
                            if let vehicle_number = vehicle["vehicle_id"] as? String {
                                if vehicle_number == vehicleNumber {
                                    vehicleExist = true
                                }
                            }
                        
                        }
                        
                        if vehicleExist {
                            self.showScannedDialog(qrItem: self.qrItem, vehicleNumber: vehicleNumber, responseType: "assign")
                        } else {
                            self.showScannedDialog(qrItem: self.qrItem, vehicleNumber: vehicleNumber, responseType: "novehicle")
                        }


                    } catch {

                        print("🔥 Decode Error:", error.localizedDescription)
                        self.showToast(message: "Parsing Error")
                    }

                } else {

                    if message.lowercased() == "no internet connection" {

    //                    self.showNoInternetDialog()

                    } else {

                        self.showToast(message: "Vehicle not found")
                    }
                }
            }
            
        }
        
        dialog.onCancel = { vehicleNumber in
            self.refreshScanner()
        }
        
        
        
        view.addSubview(dialog)
        
    }
    
    
    private func assignQR(vehicleId : String, qrItem: QRDataModel) {
        
        let params: [String: Any] = [
            "qr_id": qrItem.qr_id ?? "empty",
            "assign_to": PreferenceManager.shared.getUserId(),
            "assigned_by": "user",
            "product_type": "vehicle",
            "vehicle_id": vehicleId
        ]
        
        LoadingManager.shared.show(on: self.view)
        
        NetworkManager.shared.callAPI(
            url: APIEndpoints.ASSIGN_QR_CODE,
            method: "POST",
            parameters: params
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            LoadingManager.shared.hide()

            if status {

                self.showToast(message: "QR Code activated successfully")
                navigationController?.popViewController(animated: true)

            } else {

                if message.lowercased() == "no internet connection" {

//                    self.showNoInternetDialog()

                } else {

                    self.showToast(message: "Vehicle not found")
                }
            }
        }
        
    }
    
    
 }
