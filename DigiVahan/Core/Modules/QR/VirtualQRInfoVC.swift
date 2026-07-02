//
//  VirtualQRInfoVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 23/06/26.
//

import UIKit
import SDWebImage
import Photos

class VirtualQRInfoVC: BaseViewController {
    
    private var garageModel: GarageItemModel?
    private var qrItem: QRDataModel?
    
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var vehicleNumber: UILabel!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var ownerEmail: UILabel!
    @IBOutlet weak var ownerNumber: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = receivedData as? [String: Any] {

            self.garageModel = data["garageDetails"] as? GarageItemModel ?? nil
           
            
            setData()
        }
        
        setUI()
    }
    
    @IBAction func downloadQrBtnClicked(_ sender: Any) {
        if let qrItem = qrItem,
           let qrId = qrItem.qr_id,
           !qrId.isEmpty {
            downloadImage(qrId: qrId)

        } else {

            showToast(
                message: "Unable to download QR Code."
            )
        }
    }
    
    
    private func setUI() {

        title = "My Virtual QR Code"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont(name: "Hind-Medium", size: 20)!,
                .foregroundColor: UIColor.black
            ]

    }
    
    private func setData() {

        self.vehicleName.text = self.garageModel?.vehicle_name
        self.vehicleNumber.text = self.garageModel?.vehicle_number
        self.ownerName.text = self.garageModel?.owner_name
        self.ownerEmail.text = PreferenceManager.shared.getUser()?.email
        self.ownerNumber.text = PreferenceManager.shared.getUser()?.phoneNumber
        checkQR(vehicleId: self.garageModel?.vehicle_id ?? "")
    }
    
    func checkQR(vehicleId: String) {

        // Params
        let params: [String: Any] = [

            "user_id": PreferenceManager.shared.getUserId(),
            "vehicle_id": vehicleId
        ]

        print("checkQR params: \(params)")

        LoadingManager.shared.show(on: view)

        // API Call
        NetworkManager.shared.callAPI(
            url: APIEndpoints.CHECK_QR_CODE,
            method: "POST",
            parameters: params
        ) { response, status, message in

            LoadingManager.shared.hide()

            print("checkQR response: \(response ?? [:])")

            if status {

                do {

                    guard
                        let data = response?["data"] as? [String: Any]
                    else {
                        return
                    }

                    let jsonData = try JSONSerialization.data(
                        withJSONObject: data,
                        options: []
                    )

                    self.qrItem = try JSONDecoder().decode(
                        QRDataModel.self,
                        from: jsonData
                    )
                    
                    var imageURL: String = self.qrItem?.qr_img ?? ""
                    
                    if imageURL.isEmpty {

                        self.qrImage.image =
                        UIImage(named: "tempQR")

                        return
                    }

                    self.qrImage.sd_setImage(
                        with: URL(string: imageURL),
                        placeholderImage: UIImage(
                            named: "tempQR"
                        )
                    )

                    print("✅ QR Data: \(self.qrItem.debugDescription)")

                } catch {

                    print("❌ QR Data parse error: \(error)")
                }

            } else {

                // QR does not exist -> create it
                self.createQRCode(vehicleId: vehicleId)
            }
        }
    }
    
    
    func createQRCode(vehicleId: String) {

        let params: [String: Any] = [
            "unit": 1
        ]

        print("🚀 createQRCode Params: \(params)")

        LoadingManager.shared.show(on: view)

        NetworkManager.shared.callAPI(
            url: APIEndpoints.CREATE_QR_CODE,
            method: "POST",
            parameters: params
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            if status {

                do {

                    print("✅ Create QR Response: \(response ?? [:])")

                    guard
                        let dataArray = response?["data"] as? [[String: Any]],
                        let qrData = dataArray.first
                    else {

                        LoadingManager.shared.hide()
                        self.showToast(message: "Can't create your Order right now.")
                        return
                    }

                    let jsonData = try JSONSerialization.data(
                        withJSONObject: qrData,
                        options: []
                    )

                    let qrItem = try JSONDecoder().decode(
                        QRDataModel.self,
                        from: jsonData
                    )

                    print("✅ QR Data:", qrItem)

                    self.assignQR(
                        vehicleId: vehicleId,
                        qrItem: qrItem
                    )

                } catch {

                    LoadingManager.shared.hide()
                    print("❌ QR Parse Error:", error)
                }

            } else {

                LoadingManager.shared.hide()
                self.showToast(message: "Failed: \(message)")
            }
        }
    }
    
    func assignQR(
        vehicleId: String,
        qrItem: QRDataModel
    ) {

        let params: [String: Any] = [

            "qr_id": qrItem.qr_id ?? "",
            "assign_to": PreferenceManager.shared.getUserId(),
            "assigned_by": "user",
            "product_type": "vehicle",
            "vehicle_id": vehicleId
        ]

        print("🚀 assignQR Params: \(params)")

        NetworkManager.shared.callAPI(
            url: APIEndpoints.ASSIGN_QR_CODE,
            method: "POST",
            parameters: params
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            LoadingManager.shared.hide()

            if status {

                print("✅ Assign QR Response:", response ?? [:])

                self.qrItem = qrItem

                self.qrImage.sd_setImage(
                    with: URL(string: qrItem.qr_img ?? ""),
                    placeholderImage: UIImage(named: "temp_qr")
                )

            } else {

                self.showToast(
                    message: "QR not created, please try after some time."
                )
            }
        }
    }
    
    
    func downloadImage(qrId: String) {

        LoadingManager.shared.show(on: view)

        var params: [String: Any] = [
            "template_type": ""
        ]

        if (garageModel?.vehicle_class ?? "").lowercased().contains("2wn") {
            params["template_type"] = "bike"
        }

        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_QR_TEMPLATE + qrId,
            method: "POST",
            parameters: params
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            if !status {

                LoadingManager.shared.hide()

                self.showToast(
                    message: "Unable to download QR Code."
                )

                return
            }

            guard
                let data = response?["data"] as? [String: Any],
                let templateUrl = data["template_url"] as? String
            else {

                LoadingManager.shared.hide()

                self.showToast(
                    message: "QR template not found."
                )

                return
            }

            self.downloadImageIfNotExists(
                imageUrl: templateUrl
            )
        }
    }
    
    func downloadImageIfNotExists(imageUrl: String) {

        guard let url = URL(string: imageUrl) else {

            LoadingManager.shared.hide()
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in

            DispatchQueue.main.async {

                if let error = error {

                    LoadingManager.shared.hide()
                    print("❌ Download failed:", error)

                    return
                }

                guard
                    let data = data,
                    let image = UIImage(data: data)
                else {

                    LoadingManager.shared.hide()
                    return
                }

                self.saveImageToGallery(image)
            }

        }.resume()
    }
    
    func saveImageToGallery(_ image: UIImage) {

        PHPhotoLibrary.requestAuthorization { status in

            let isAuthorized: Bool

            if #available(iOS 14, *) {
                isAuthorized = (status == .authorized || status == .limited)
            } else {
                isAuthorized = (status == .authorized)
            }

            guard isAuthorized else {

                DispatchQueue.main.async {

                    LoadingManager.shared.hide()

                    self.showToast(
                        message: "Photo access denied"
                    )
                }

                return
            }

            DispatchQueue.main.async {

                UIImageWriteToSavedPhotosAlbum(
                    image,
                    self,
                    #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)),
                    nil
                )
            }
        }
    }
    
    
    @objc func imageSaved(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer?
    ) {

        LoadingManager.shared.hide()

        if let error = error {

            print("❌ Save error:", error.localizedDescription)

            showToast(
                message: "Failed to save image."
            )

        } else {

            print("✅ Image saved successfully")

            showToast(
                message: "QR Code saved successfully. Please open Photos → Recents to view it."
            )
        }
    }
    
}
