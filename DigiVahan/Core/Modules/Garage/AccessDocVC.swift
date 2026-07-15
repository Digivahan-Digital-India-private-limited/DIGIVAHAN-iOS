//
//  MainPage.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/05/26.
//

import UIKit
import OneSignalFramework
import SDWebImage

class AccessDocVC: BaseViewController {
        
    var vehicleDocumentsArrayList: [VehicleDocuments] = []
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var otpView: OTPView!
    @IBOutlet weak var alertMessage: UILabel!
    
    @IBOutlet weak var viewImageLayout: UIView!
    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var viewImageCloseIcon: UIImageView!
    
    var userId = ""
    var vehicleId = ""
    var taskType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(backPressed)
            )
        
        // Receive Data
        if let data = receivedData as? [String: Any] {
            userId = data["userId"] as? String ?? ""
            vehicleId = data["vehicleId"] as? String ?? ""
            taskType = data["taskType"] as? String ?? ""
        }
        
        otpView.otpLength = 4
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90

        tableView.separatorStyle = .none
        tableView.reloadData()
        
        
        if taskType == "check"{
            checkVerifyDoc(taskType: taskType, userId: userId, vehicleId: vehicleId, verificationCode: "")
        } else{
            otpView.onOtpComplete = { [weak self] otp in

                    guard let self = self else { return }

                    self.checkVerifyDoc(
                        taskType: self.taskType,
                        userId: self.userId,
                        vehicleId: self.vehicleId,
                        verificationCode: otp
                    )
                }
        }
        
        viewImageCloseIcon.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(closeViewImageBtnClicked(_:))
        )
        viewImageCloseIcon.addGestureRecognizer(tap)
        
    }
    
    @objc func closeViewImageBtnClicked(_ sender: UITapGestureRecognizer) {
        viewImageLayout.isHidden = true
    }
    
    @objc func backPressed() {

        if !viewImageLayout.isHidden {
            viewImageLayout.isHidden = true
        } else {
            let alert = UIAlertController(
                        title: "Cancel Verification",
                        message: "Do you want to cancel the security code verification process?",
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: "No", style: .cancel))

                    alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                        
                        self.navigationController?.popViewController(animated: true)
                        
                    })
            
                    present(alert, animated: true)
        }
    }
    
    func checkVerifyDoc(taskType: String, userId: String, vehicleId: String, verificationCode: String) {
        
        vehicleDocumentsArrayList.removeAll()

        LoadingManager.shared.show(on: view)
        
        var docUtl = APIEndpoints.DOC_CHECK
        
        if taskType == "verify"{
            docUtl = APIEndpoints.DOC_VERIFY
        }
        
        // Params
        var params: [String: Any] = [
            "user_id": userId,
            "vehicle_id": vehicleId
        ]
        
        if taskType == "verify"{
            params["security_code"] = verificationCode
        }

        NetworkManager.shared.callAPI(
            url: docUtl,
            method: "POST",
            parameters: params
        ) { [weak self] response, status, message in

            guard let self = self else { return }

            LoadingManager.shared.hide()

            if status {

                guard let response = response else {
                    self.showToast(message: "Invalid Response")
                    return
                }

                var documentList: [VehicleDocuments] = []

                if taskType == "check" {

                    // -----------------------------
                    // CHECK DOCUMENT API
                    // -----------------------------
                
                    
                    alertMessage.text = "Please share your security code only with trusted requesters. Your safety and security are our top priority. security code will expire in 1 minutes."

                    let securityCode = response["security_code"] as? String ?? ""
                    otpView.setOTP(securityCode)
                    let expiresIn = response["expires_in"] as? Int ?? 0

                    print("Security Code:", securityCode)
                    print("Expires In:", expiresIn)

                    if let documents = response["vehicle_doc_data"] as? [[String: Any]] {

                        for document in documents {

                            var model = VehicleDocuments()

                            model.doc_name = document["doc_name"] as? String ?? ""
                            model.doc_type = document["doc_type"] as? String ?? ""
                            model.doc_number = document["doc_number"] as? String ?? ""
                            model.doc_url = document["doc_url"] as? String ?? ""
                            model.public_id = document["public_id"] as? String ?? ""
                            model.uploaded_at = document["uploaded_at"] as? String ?? ""

                            documentList.append(model)
                        }
                    }

                } else {

                    // -----------------------------
                    // VERIFY DOCUMENT API
                    // -----------------------------

                    if let data = response["data"] as? [String: Any] {

                        let vehicleId = data["vehicle_id"] as? String ?? ""

                        print("Vehicle ID:", vehicleId)

                        if let documents = data["documents"] as? [[String: Any]] {

                            for document in documents {

                                var model = VehicleDocuments()

                                model.doc_name = document["doc_name"] as? String ?? ""
                                model.doc_type = document["doc_type"] as? String ?? ""
                                model.doc_number = document["doc_number"] as? String ?? ""
                                model.doc_url = document["doc_url"] as? String ?? ""
                                model.public_id = document["public_id"] as? String ?? ""
                                model.uploaded_at = document["uploaded_at"] as? String ?? ""

                                documentList.append(model)
                            }
                        }
                    }
                    
                    otpView.disableEditing()
                }
                
                self.vehicleDocumentsArrayList = documentList
                print("Total Documents:", self.vehicleDocumentsArrayList.count)

                self.tableView.reloadData()

            } else {

                self.showToast(message: message)
            }
        }
    }
    
}

extension AccessDocVC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        print("Rows:", vehicleDocumentsArrayList.count)
        return vehicleDocumentsArrayList.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        print("cellForRowAt:", indexPath.row)

        let document = vehicleDocumentsArrayList[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "DocumentListCell",
            for: indexPath
        ) as! DocumentListCell

        cell.selectionStyle = .none

        // Vehicle details
        cell.documentNumber.text = document.doc_number
        
        if document.doc_type == "aadhar"{
            cell.documentName.text = "Aadhar"
            cell.documentImage.image = UIImage(named: "infoDocIcon")
        }
        else if document.doc_type == "insurance"{
            cell.documentName.text = "Insurance"
            cell.documentImage.image = UIImage(named: "insuranceDocIcon")
        }
        else if document.doc_type == "pollution"{
            cell.documentName.text = "Pollution"
            cell.documentImage.image = UIImage(named: "pollutionDocIcon")
        }
        else if document.doc_type == "rc"{
            cell.documentName.text = "Registration Certificate"
            cell.documentImage.image = UIImage(named: "infoDocIcon")
        }
        else if document.doc_type == "pancard"{
            cell.documentName.text = "Pancard"
            cell.documentImage.image = UIImage(named: "infoDocIcon")
        }
        else if document.doc_type == "driving licence"{
            cell.documentName.text = "Driving Licence"
            cell.documentImage.image = UIImage(named: "infoDocIcon")
        }
        else {
            cell.documentName.text = document.doc_name
            cell.documentImage.image = UIImage(named: "documentIcon")
        }
        
        if taskType == "check"{
            cell.deleteBtn.isHidden = false
        }else {cell.deleteBtn.isHidden = true}
        
        cell.deleteAction = { [weak self] in
            
            print("🗑 Delete button tapped")
                print("Row:", indexPath.row)
                print("Document:", document.doc_name ?? "")
            
            self?.deleteDocument(document, at: indexPath.row)
        }
        
        cell.previewAction = { [weak self] in
            self?.viewDocBtnClick(document)
        }

        return cell
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        let currentText = textField.text ?? ""

        if let textRange = Range(range, in: currentText) {

            let updatedText = currentText
                .replacingCharacters(in: textRange, with: string)
                .uppercased()

            textField.text = updatedText
        }

        return false
    }
    
    func deleteDocument(_ document: VehicleDocuments, at index: Int) {

        let alert = UIAlertController(
            title: "Remove Document",
            message: "Are you sure you want to remove it?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))

        alert.addAction(UIAlertAction(
            title: "Yes, Delete",
            style: .destructive
        ) { [weak self] _ in

            guard let self = self else { return }
            
            LoadingManager.shared.show(on: view)

            let params: [String: Any] = [
                "user_id": PreferenceManager.shared.getUserId(),
                "vehicle_id": vehicleId,
                "doc_type": document.doc_type ?? ""
            ]

            NetworkManager.shared.callAPI(
                url: APIEndpoints.DELETE_DOCUMENT,
                method: "POST",
                parameters: params
            ) { response, status, message in

                LoadingManager.shared.hide()
                
                self.showToast(message: message)

                if status {

                    self.vehicleDocumentsArrayList.remove(at: index)

                    self.tableView.deleteRows(
                        at: [IndexPath(row: index, section: 0)],
                        with: .automatic
                    )
                    
                    if self.vehicleDocumentsArrayList.isEmpty {
                        self.alertMessage.text = "Please add document first."
                        self.otpView.setOTP("0000")
                    }
                    

                } else {

                    self.showToast(message: message)
                }
            }
        })

        present(alert, animated: true)
    }
    
    func viewDocBtnClick(_ document: VehicleDocuments) {
        
        if let imageUrl = document.doc_url, !imageUrl.isEmpty {

            viewImage.sd_setImage(
                with: URL(string: imageUrl),
                placeholderImage: UIImage(named: "emptyImage")
            )

        } else {

            viewImage.image = UIImage(named: "emptyImage")
        }
        
        viewImageLayout.isHidden = false
    }
}

