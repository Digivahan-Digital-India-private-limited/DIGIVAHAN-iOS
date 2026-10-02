//
//  AddEditDeliveryAddressVC.swift
//  DigiVahan
//
//  Created for DigiVahan Address Book Module.
//

import UIKit

class AddEditDeliveryAddressVC: BaseViewController {

    // MARK: - Properties
    var hitType: String = "add" // "add" or "edit"
    var addressToEdit: AddressBookModel?
    var onSaveSuccess: (() -> Void)?

    // MARK: - UI Elements
    private let topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config) ?? UIImage(named: "leftArrow")
        btn.setImage(image, for: .normal)
        btn.tintColor = .black
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add Delivery Address"
        label.font = UIFont(name: "Hind-SemiBold", size: 19) ?? UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = UIColor(red: 247/255.0, green: 248/255.0, blue: 250/255.0, alpha: 1.0)
        sv.keyboardDismissMode = .onDrag
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let formStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // Text Fields
    private let nameField = AddEditDeliveryAddressVC.createFormField(label: "Full Name *", placeholder: "Enter recipient's full name")
    private let phoneField = AddEditDeliveryAddressVC.createFormField(label: "Contact Number *", placeholder: "10-digit mobile number", keyboardType: .phonePad)
    private let houseNoField = AddEditDeliveryAddressVC.createFormField(label: "House / Flat / Building No. *", placeholder: "e.g. Flat 402, Sunshine Heights")
    private let streetField = AddEditDeliveryAddressVC.createFormField(label: "Street Name *", placeholder: "e.g. 5th Main Road")
    private let roadAreaField = AddEditDeliveryAddressVC.createFormField(label: "Road / Area / Colony *", placeholder: "e.g. Indiranagar")
    private let landmarkField = AddEditDeliveryAddressVC.createFormField(label: "Landmark (Optional)", placeholder: "e.g. Near Metro Station")
    private let pincodeField = AddEditDeliveryAddressVC.createFormField(label: "PIN Code *", placeholder: "6-digit PIN code", keyboardType: .numberPad)
    private let cityField = AddEditDeliveryAddressVC.createFormField(label: "City *", placeholder: "Enter city")
    private let stateField = AddEditDeliveryAddressVC.createFormField(label: "State *", placeholder: "Enter state")

    // Pincode loading spinner
    private let pincodeIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // Default address toggle card
    private let defaultToggleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let defaultToggleLabel: UILabel = {
        let label = UILabel()
        label.text = "Set as default address"
        label.font = UIFont(name: "Hind-Medium", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let defaultSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()

    // Save Button
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save Address", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Hind-SemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        btn.backgroundColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private var isPinCodeCorrect = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        setupActions()
        populateDataIfEditing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - UI Setup
    private func setupUI() {
        titleLabel.text = (hitType == "add") ? "Add Delivery Address" : "Edit Delivery Address"
        saveButton.setTitle((hitType == "add") ? "Save Address" : "Update Address", for: .normal)

        view.addSubview(topBarView)
        topBarView.addSubview(backButton)
        topBarView.addSubview(titleLabel)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(formStackView)

        // Setup Pincode Indicator inside pincodeField container
        pincodeField.containerView.addSubview(pincodeIndicator)

        // Setup default address toggle container
        defaultToggleContainer.addSubview(defaultToggleLabel)
        defaultToggleContainer.addSubview(defaultSwitch)

        // Add form components
        formStackView.addArrangedSubview(nameField.containerView)
        formStackView.addArrangedSubview(phoneField.containerView)
        formStackView.addArrangedSubview(houseNoField.containerView)
        formStackView.addArrangedSubview(streetField.containerView)
        formStackView.addArrangedSubview(roadAreaField.containerView)
        formStackView.addArrangedSubview(landmarkField.containerView)
        formStackView.addArrangedSubview(pincodeField.containerView)
        formStackView.addArrangedSubview(cityField.containerView)
        formStackView.addArrangedSubview(stateField.containerView)
        formStackView.addArrangedSubview(defaultToggleContainer)
        formStackView.addArrangedSubview(saveButton)

        saveButton.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            // Top Bar
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: 52),

            backButton.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: topBarView.trailingAnchor, constant: -16),

            // ScrollView
            scrollView.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // Form StackView
            formStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            formStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            formStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            formStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),

            // Pincode indicator
            pincodeIndicator.trailingAnchor.constraint(equalTo: pincodeField.containerView.trailingAnchor, constant: -14),
            pincodeIndicator.centerYAnchor.constraint(equalTo: pincodeField.textField.centerYAnchor),

            // Default toggle
            defaultToggleContainer.heightAnchor.constraint(equalToConstant: 56),
            defaultToggleLabel.leadingAnchor.constraint(equalTo: defaultToggleContainer.leadingAnchor, constant: 16),
            defaultToggleLabel.centerYAnchor.constraint(equalTo: defaultToggleContainer.centerYAnchor),
            defaultSwitch.trailingAnchor.constraint(equalTo: defaultToggleContainer.trailingAnchor, constant: -16),
            defaultSwitch.centerYAnchor.constraint(equalTo: defaultToggleContainer.centerYAnchor),

            // Save Button
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            loadingIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)

        // Contact Number formatting (only digits, max 10)
        phoneField.textField.addTarget(self, action: #selector(phoneFieldDidChange(_:)), for: .editingChanged)

        // PIN Code text changed -> auto fetch city & state
        pincodeField.textField.addTarget(self, action: #selector(pincodeFieldDidChange(_:)), for: .editingChanged)
    }

    private func populateDataIfEditing() {
        if hitType != "add", let model = addressToEdit {
            nameField.textField.text = model.name
            phoneField.textField.text = model.contact_no
            houseNoField.textField.text = model.house_no_building
            streetField.textField.text = model.street_name
            roadAreaField.textField.text = model.road_or_area
            landmarkField.textField.text = model.landmark
            pincodeField.textField.text = model.pincode
            cityField.textField.text = model.city
            stateField.textField.text = model.state
            defaultSwitch.isOn = (model.default_status == true)
            isPinCodeCorrect = (model.pincode?.count == 6)
        }
    }

    // MARK: - Handlers
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func phoneFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let digits = text.filter { $0.isNumber }
        if digits.count > 10 {
            let truncated = String(digits.suffix(10))
            textField.text = truncated
        } else if text != digits {
            textField.text = digits
        }
    }

    @objc private func pincodeFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let digits = text.filter { $0.isNumber }
        if digits.count > 6 {
            textField.text = String(digits.prefix(6))
        } else if text != digits {
            textField.text = digits
        }

        if let cleanPin = textField.text, cleanPin.count == 6 {
            fetchCityStateFromPin(pincode: cleanPin)
        } else {
            isPinCodeCorrect = false
        }
    }

    // MARK: - Postal Pincode Lookup
    private func fetchCityStateFromPin(pincode: String) {
        pincodeIndicator.startAnimating()

        guard let url = URL(string: "https://api.postalpincode.in/pincode/\(pincode)") else {
            pincodeIndicator.stopAnimating()
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.pincodeIndicator.stopAnimating()

                guard let self = self, error == nil, let data = data else { return }

                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                       let first = jsonArray.first,
                       let status = first["Status"] as? String,
                       status.lowercased() == "success",
                       let postOffices = first["PostOffice"] as? [[String: Any]],
                       let postOffice = postOffices.first {

                        let district = postOffice["District"] as? String ?? ""
                        let state = postOffice["State"] as? String ?? ""

                        self.cityField.textField.text = district
                        self.stateField.textField.text = state
                        self.isPinCodeCorrect = true
                    } else {
                        self.isPinCodeCorrect = false
                        self.showToast(message: "Invalid PIN Code")
                    }
                } catch {
                    print("Error parsing postal pincode:", error)
                }
            }
        }.resume()
    }

    // MARK: - Save Address
    @objc private func didTapSave() {
        let name = nameField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phone = phoneField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let houseNo = houseNoField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let street = streetField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let roadArea = roadAreaField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let landmark = landmarkField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pincode = pincodeField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let city = cityField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let state = stateField.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isDefault = defaultSwitch.isOn

        // Validations
        if name.isEmpty {
            showToast(message: "Please enter name")
            nameField.textField.becomeFirstResponder()
            return
        }
        if name.count < 2 {
            showToast(message: "Invalid Name")
            nameField.textField.becomeFirstResponder()
            return
        }
        if phone.isEmpty {
            showToast(message: "Please enter contact number")
            phoneField.textField.becomeFirstResponder()
            return
        }
        if phone.count != 10 {
            showToast(message: "Please enter valid 10-digit phone number")
            phoneField.textField.becomeFirstResponder()
            return
        }
        if houseNo.isEmpty {
            showToast(message: "Please enter house details")
            houseNoField.textField.becomeFirstResponder()
            return
        }
        if street.isEmpty {
            showToast(message: "Please enter street")
            streetField.textField.becomeFirstResponder()
            return
        }
        if roadArea.isEmpty {
            showToast(message: "Please enter area")
            roadAreaField.textField.becomeFirstResponder()
            return
        }
        if pincode.isEmpty {
            showToast(message: "Please enter your PIN code")
            pincodeField.textField.becomeFirstResponder()
            return
        }
        if pincode.count != 6 {
            showToast(message: "PIN Code must be 6 digits")
            pincodeField.textField.becomeFirstResponder()
            return
        }
        if city.isEmpty {
            showToast(message: "Please enter your city")
            cityField.textField.becomeFirstResponder()
            return
        }
        if state.isEmpty {
            showToast(message: "Please enter your state")
            stateField.textField.becomeFirstResponder()
            return
        }

        let userId = PreferenceManager.shared.getUserId()
        guard !userId.isEmpty else {
            showToast(message: "User session expired. Please log in again.")
            return
        }

        var params: [String: Any] = [
            "user_id": userId,
            "name": name,
            "contact_no": phone,
            "house_no_building": houseNo,
            "street_name": street,
            "road_or_area": roadArea,
            "landmark": landmark,
            "city": city,
            "state": state,
            "pincode": pincode,
            "default_status": isDefault
        ]

        let isEditing = (hitType != "add")
        let endpoint = isEditing ? APIEndpoints.UPDATE_USER_ADDRESS : APIEndpoints.ADD_USER_ADDRESS
        let method = isEditing ? "PUT" : "POST"

        if isEditing, let addressId = addressToEdit?._id {
            params["address_id"] = addressId
        }

        saveButton.isEnabled = false
        saveButton.setTitle("", for: .normal)
        loadingIndicator.startAnimating()

        NetworkManager.shared.callAPI(
            url: endpoint,
            method: method,
            parameters: params
        ) { [weak self] _, status, message in
            guard let self = self else { return }

            self.saveButton.isEnabled = true
            self.saveButton.setTitle(isEditing ? "Update Address" : "Save Address", for: .normal)
            self.loadingIndicator.stopAnimating()

            let displayMsg = message.isEmpty ? (status ? "Address saved successfully" : "Failed to save address") : message
            self.showToast(message: displayMsg)

            if status {
                self.onSaveSuccess?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    // MARK: - Helper UI Builders
    struct FormField {
        let containerView: UIView
        let label: UILabel
        let textField: UITextField
    }

    static func createFormField(label: String, placeholder: String, keyboardType: UIKeyboardType = .default) -> FormField {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let lbl = UILabel()
        lbl.text = label
        lbl.font = UIFont(name: "Hind-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = UIColor(white: 0.3, alpha: 1.0)
        lbl.translatesAutoresizingMaskIntoConstraints = false

        let tf = UITextField()
        tf.placeholder = placeholder
        tf.font = UIFont(name: "Hind-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        tf.textColor = .black
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(white: 0.88, alpha: 1.0).cgColor
        tf.keyboardType = keyboardType
        tf.autocorrectionType = .no
        tf.autocapitalizationType = (keyboardType == .phonePad || keyboardType == .numberPad) ? .none : .words

        // Left padding
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 48))
        tf.leftView = padding
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(lbl)
        container.addSubview(tf)

        NSLayoutConstraint.activate([
            lbl.topAnchor.constraint(equalTo: container.topAnchor),
            lbl.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            lbl.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            tf.topAnchor.constraint(equalTo: lbl.bottomAnchor, constant: 6),
            tf.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tf.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tf.heightAnchor.constraint(equalToConstant: 48),
            tf.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return FormField(containerView: container, label: lbl, textField: tf)
    }
}
