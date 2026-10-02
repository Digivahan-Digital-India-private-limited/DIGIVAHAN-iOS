//
//  SetDefaultAddressVC.swift
//  DigiVahan
//
//  Created for DigiVahan Address Book Module.
//

import UIKit

class SetDefaultAddressVC: BaseViewController {

    // MARK: - Properties
    private var addressList: [AddressBookModel] = []
    private var filteredList: [AddressBookModel] = []
    private var selectedAddress: AddressBookModel?

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
        label.text = "Set Default"
        label.font = UIFont(name: "Hind-SemiBold", size: 19) ?? UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Search Bar
    private let searchContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 0.88, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let searchIconImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        iv.image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        iv.tintColor = UIColor(white: 0.5, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search by name or mobile number"
        tf.font = UIFont(name: "Hind-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        tf.textColor = .black
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // Table View
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 120
        tv.keyboardDismissMode = .onDrag
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let refreshControl = UIRefreshControl()

    // Empty View
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emptyImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "address_empty_image")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Address Found"
        label.font = UIFont(name: "Hind-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emptySubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add an address in Address Book first to set as default."
        label.font = UIFont(name: "Hind-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(white: 0.45, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Bottom Save Button Container
    private let bottomButtonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        view.layer.shadowRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save as Default", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Hind-SemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        btn.backgroundColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let buttonIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 247/255.0, green: 248/255.0, blue: 250/255.0, alpha: 1.0)

        setupUI()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        fetchAddresses()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(topBarView)
        topBarView.addSubview(backButton)
        topBarView.addSubview(titleLabel)

        view.addSubview(searchContainerView)
        searchContainerView.addSubview(searchIconImageView)
        searchContainerView.addSubview(searchTextField)

        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(bottomButtonContainer)
        bottomButtonContainer.addSubview(saveButton)
        saveButton.addSubview(buttonIndicator)
        view.addSubview(loadingView)

        emptyView.addSubview(emptyImageView)
        emptyView.addSubview(emptyTitleLabel)
        emptyView.addSubview(emptySubtitleLabel)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SetDefaultAddressCell.self, forCellReuseIdentifier: SetDefaultAddressCell.identifier)

        refreshControl.addTarget(self, action: #selector(didPullRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

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

            // Search Bar
            searchContainerView.topAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: 12),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainerView.heightAnchor.constraint(equalToConstant: 44),

            searchIconImageView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 12),
            searchIconImageView.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 20),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 20),

            searchTextField.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -12),
            searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),

            // Table View
            tableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomButtonContainer.topAnchor),

            // Empty View
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            emptyImageView.topAnchor.constraint(equalTo: emptyView.topAnchor),
            emptyImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 120),
            emptyImageView.heightAnchor.constraint(equalToConstant: 120),

            emptyTitleLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 16),
            emptyTitleLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor),
            emptyTitleLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor),

            emptySubtitleLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 8),
            emptySubtitleLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor),
            emptySubtitleLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor),
            emptySubtitleLabel.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor),

            // Bottom Save Button Container
            bottomButtonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButtonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButtonContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            saveButton.topAnchor.constraint(equalTo: bottomButtonContainer.topAnchor, constant: 12),
            saveButton.leadingAnchor.constraint(equalTo: bottomButtonContainer.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: bottomButtonContainer.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            saveButton.heightAnchor.constraint(equalToConstant: 48),

            buttonIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            buttonIndicator.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor, constant: -20),

            // Loading View
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        searchTextField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
    }

    // MARK: - Handlers
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didPullRefresh() {
        fetchAddresses(showLoader: false)
    }

    @objc private func searchTextChanged(_ textField: UITextField) {
        let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        if query.isEmpty {
            filteredList = addressList
        } else {
            filteredList = addressList.filter { item in
                let nameMatches = (item.name?.lowercased().contains(query) == true)
                let phoneMatches = (item.contact_no?.contains(query) == true)
                return nameMatches || phoneMatches
            }
        }
        tableView.reloadData()
        updateEmptyState()
    }

    // MARK: - API Calls
    private func fetchAddresses(showLoader: Bool = true) {
        let userId = PreferenceManager.shared.getUserId()
        guard !userId.isEmpty else {
            refreshControl.endRefreshing()
            return
        }

        if showLoader {
            loadingView.startAnimating()
        }

        let params: [String: Any] = [
            "user_id": userId,
            "details_type": "address_book"
        ]

        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_USER_DETAILS,
            method: "POST",
            parameters: params
        ) { [weak self] response, status, _ in
            guard let self = self else { return }

            self.loadingView.stopAnimating()
            self.refreshControl.endRefreshing()

            if status, let dataArray = response?["data"] as? [[String: Any]] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: dataArray)
                    let list = try JSONDecoder().decode([AddressBookModel].self, from: jsonData)

                    var sorted: [AddressBookModel] = []
                    let defaults = list.filter { $0.isDefault }
                    let nonDefaults = list.filter { !$0.isDefault }
                    sorted.append(contentsOf: defaults)
                    sorted.append(contentsOf: nonDefaults)

                    self.addressList = sorted
                    self.selectedAddress = defaults.first ?? nonDefaults.first
                    self.searchTextChanged(self.searchTextField)
                } catch {
                    print("Error parsing default address list:", error)
                    self.updateEmptyState()
                }
            } else {
                self.addressList = []
                self.filteredList = []
                self.tableView.reloadData()
                self.updateEmptyState()
            }
        }
    }

    private func updateEmptyState() {
        let isEmpty = filteredList.isEmpty
        emptyView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        bottomButtonContainer.isHidden = isEmpty
    }

    // MARK: - Save Default Address
    @objc private func didTapSave() {
        guard let address = selectedAddress, let addressId = address._id, !addressId.isEmpty else {
            showToast(message: "No selected address found")
            return
        }

        let userId = PreferenceManager.shared.getUserId()
        guard !userId.isEmpty else { return }

        saveButton.isEnabled = false
        saveButton.setTitle("", for: .normal)
        buttonIndicator.startAnimating()

        let params: [String: Any] = [
            "user_id": userId,
            "address_id": addressId,
            "default_status": true
        ]

        NetworkManager.shared.callAPI(
            url: APIEndpoints.UPDATE_USER_ADDRESS,
            method: "PUT",
            parameters: params
        ) { [weak self] _, status, message in
            guard let self = self else { return }

            self.saveButton.isEnabled = true
            self.saveButton.setTitle("Save as Default", for: .normal)
            self.buttonIndicator.stopAnimating()

            let displayMsg = message.isEmpty ? (status ? "Default address updated successfully" : "Failed to update default address") : message
            self.showToast(message: displayMsg)

            if status {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SetDefaultAddressVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SetDefaultAddressCell.identifier, for: indexPath) as? SetDefaultAddressCell else {
            return UITableViewCell()
        }

        let item = filteredList[indexPath.row]
        let isSelected = (item._id != nil && item._id == selectedAddress?._id)
        cell.configure(with: item, isSelected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAddress = filteredList[indexPath.row]
        tableView.reloadData()
    }
}

// MARK: - SetDefaultAddressCell
class SetDefaultAddressCell: UITableViewCell {
    static let identifier = "SetDefaultAddressCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 0.88, alpha: 1.0).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let radioImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-SemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let defaultBadge: UILabel = {
        let label = UILabel()
        label.text = "CURRENT DEFAULT"
        label.font = UIFont(name: "Hind-Bold", size: 10) ?? UIFont.boldSystemFont(ofSize: 10)
        label.textColor = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        label.backgroundColor = UIColor(red: 232/255.0, green: 245/255.0, blue: 233/255.0, alpha: 1.0)
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(white: 0.3, alpha: 1.0)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(white: 0.4, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(cardView)

        cardView.addSubview(radioImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(defaultBadge)
        cardView.addSubview(addressLabel)
        cardView.addSubview(phoneLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            radioImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            radioImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            radioImageView.widthAnchor.constraint(equalToConstant: 22),
            radioImageView.heightAnchor.constraint(equalToConstant: 22),

            nameLabel.leadingAnchor.constraint(equalTo: radioImageView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: radioImageView.centerYAnchor),

            defaultBadge.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            defaultBadge.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            defaultBadge.heightAnchor.constraint(equalToConstant: 18),
            defaultBadge.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -14),

            addressLabel.topAnchor.constraint(equalTo: radioImageView.bottomAnchor, constant: 10),
            addressLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            addressLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            phoneLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 8),
            phoneLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            phoneLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            phoneLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with model: AddressBookModel, isSelected: Bool) {
        nameLabel.text = model.name ?? "Recipient"
        addressLabel.text = model.formattedAddress.isEmpty ? "No address specified" : model.formattedAddress
        phoneLabel.text = "Phone: \(model.contact_no ?? "N/A")"
        defaultBadge.isHidden = !model.isDefault

        let primaryGreen = UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0)
        if isSelected {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
            radioImageView.image = UIImage(systemName: "largecircle.fill.circle", withConfiguration: config)
            radioImageView.tintColor = primaryGreen
            cardView.layer.borderColor = primaryGreen.cgColor
            cardView.layer.borderWidth = 1.5
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            radioImageView.image = UIImage(systemName: "circle", withConfiguration: config)
            radioImageView.tintColor = UIColor(white: 0.7, alpha: 1.0)
            cardView.layer.borderColor = UIColor(white: 0.88, alpha: 1.0).cgColor
            cardView.layer.borderWidth = 1
        }
    }
}
