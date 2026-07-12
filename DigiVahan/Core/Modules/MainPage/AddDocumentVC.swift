//
//  MainPage.swift
//  DigiVahan
//
//  Created by Mr Ash on 20/05/26.
//

import UIKit
import OneSignalFramework

class AddDocumentVC: BaseViewController {
    
    @IBOutlet weak var docTypePickerField: UITextField!
    @IBOutlet weak var docNumber: UITextField!
    @IBOutlet weak var imagePickerBtn: UIImageView!
    
    private var garageModel: GarageItemModel?
    
    let docTypeList = [
        "Aadhar",
        "Pollution",
        "Insurance",
        "RC",
        "Pancard",
        "Driving Licence"
    ]

    let docTypePicker = UIPickerView()
    
    var selectedDocType: String = "aadhar"
    
    var selectedImage: UIImage?
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Document"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont(name: "Hind-Medium", size: 20)!,
                .foregroundColor: UIColor.black
            ]
        
        if let data = receivedData as? [String: Any] {

            self.garageModel = data["vehicleData"] as? GarageItemModel ?? nil

        }
        
        docTypePicker.delegate = self
        docTypePicker.dataSource = self

        docTypePickerField.delegate = self
        docTypePickerField.inputView = docTypePicker
        docTypePickerField.tintColor = .clear
        docTypePickerField.text = docTypeList[0]

        // Optional toolbar with Done button
        let toolbarForGenderField = UIToolbar()
        toolbarForGenderField.sizeToFit()

        let genderFieldDoneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePicker)
        )

        toolbarForGenderField.setItems([genderFieldDoneButton], animated: false)
        docTypePickerField.inputAccessoryView = toolbarForGenderField
        
        // set updateBasicDetailsBtn
        imagePickerBtn.isUserInteractionEnabled = true

            let imagePickerBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(imagePickerBtnClick)
            )

        imagePickerBtn.addGestureRecognizer(imagePickerBtnTap)
        
    }
    
    @objc private func imagePickerBtnClick() {
        ImagePickerHelper.shared.showImagePicker(from: self) { image in

                guard let image = image else { return }

                self.imagePickerBtn.image = image
            self.selectedImage = image

                // Here you can upload or store the selected image
            }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
    }

    
    @objc func donePicker() {
        docTypePickerField.resignFirstResponder()
        }
    
    @IBAction func uploadDocumentBtnClicked(_ sender: Any) {
        
        let documentNumber = docNumber.text ?? ""
        
        if documentNumber.isEmpty == true {
            showToast(message: "Please enter document number")
            return
        }
        
        if selectedImage == nil {
            showToast(message: "Please pick image")
            return
        }
        
        LoadingManager.shared.show(on: self.view)
        
        NetworkManager.shared.updateDocument(userId: PreferenceManager.shared.getUserId(),
                                             vehicleId: garageModel?.vehicle_id ?? "", docName: selectedDocType, docNumber: documentNumber, docType: selectedDocType, docFile: selectedImage
        ) { [weak self] success, message, response in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                LoadingManager.shared.hide()
                                    
                if success {
                    
                    self.showToast(message: "Document added successfully")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    
                    
                } else {
                    self.showToast(message: message)
                }
            }
        }
        
    }
    
    
}

extension AddDocumentVC: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return docTypeList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return docTypeList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        docTypePickerField.text = docTypeList[row]
        docNumber.text = ""

    }

    // Prevent manual typing
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if textField == docTypePickerField {
            return false
        }

        return true
    }

}
