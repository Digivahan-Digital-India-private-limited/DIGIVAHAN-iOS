//
//  EmergencyContactsListVC.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/06/26.
//


import UIKit
import SDWebImage

class EmergencyContactsListVC: BaseViewController {

    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addEmergencyContactBtn: UIImageView!
    
    var contacts: [EmergencyContactModel] = []
    var isEditable = true

    override func viewDidLoad() {
        super.viewDidLoad()

        enableKeyboardDismissOnTap()
        setUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getEmergencyContactList()
    }

    private func setUI() {

        title = "Emergency Contacts"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont(name: "Hind-Medium", size: 20)!,
                .foregroundColor: UIColor.black
            ]

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90

        tableView.separatorStyle = .none
        
        contacts = []
        
        // set emergencyContactLayoutBtn
        addEmergencyContactBtn.isUserInteractionEnabled = true

            let addEmergencyContactBtnTap = UITapGestureRecognizer(
                target: self,
                action: #selector(onAddEmergencyContactBtnClick)
            )

        addEmergencyContactBtn.addGestureRecognizer(addEmergencyContactBtnTap)
        
    }
    
    @objc private func onAddEmergencyContactBtnClick() {
        NavigationManager.pushScreen(
            from: self,
            storyboardName: "Main",
            viewControllerID: "UpdateEmergencyContactsVC"
        )
        
    }

    func editContact(_ contact: EmergencyContactModel) {
        // shared data
        let sharedData: [String: Any] = [
            "hit_type": "update",
            "contactDetails": contact
        ]

        // Navigate to edit screen here
        
        NavigationManager.pushScreen(
            from: self,
            storyboardName: "Main",
            viewControllerID: "UpdateEmergencyContactsVC",
            data: sharedData
        )
    }

    func deleteContact(_ contact: EmergencyContactModel, at index: Int) {

        if contacts.count <= 1 {
            showToast(message: "There should be at least one contact")
            return
        }

        let alert = UIAlertController(
            title: "Delete Contact",
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
                "contact_id": contact._id
            ]

            NetworkManager.shared.callAPI(
                url: APIEndpoints.DELETE_EMERGENCY_CONTACT,
                method: "POST",
                parameters: params
            ) { response, status, message in

                LoadingManager.shared.hide()
                
                self.showToast(message: message)

                if status {

                    self.contacts.remove(at: index)

                    self.tableView.deleteRows(
                        at: [IndexPath(row: index, section: 0)],
                        with: .automatic
                    )

                } else {

                    self.showToast(message: message)
                }
            }
        })

        present(alert, animated: true)
    }
    
    
    func getEmergencyContactList() {

        LoadingManager.shared.show(on: view)

        let params: [String: Any] = [
            "user_id": PreferenceManager.shared.getUserId(),
            "details_type": "emergency_contacts"
        ]

        NetworkManager.shared.callAPI(
            url: APIEndpoints.GET_USER_DETAILS,
            method: "POST",
            parameters: params
        ) { response, status, message in

            LoadingManager.shared.hide()

            if status {

                self.contacts.removeAll()

                if let response = response,
                   let dataArray = response["data"] as? [[String: Any]] {

                    do {

                        let jsonData = try JSONSerialization.data(
                            withJSONObject: dataArray,
                            options: []
                        )

                        let contactList = try JSONDecoder().decode(
                            [EmergencyContactModel].self,
                            from: jsonData
                        )

                        self.contacts.append(contentsOf: contactList)

                        self.tableView.reloadData()

                        // Show Empty/List View
                        self.listView.isHidden = self.contacts.isEmpty
                        self.emptyView.isHidden = !self.contacts.isEmpty

                    } catch {

                        print("Decode Error:", error.localizedDescription)
                    }
                }

            } else {

                self.showToast(message: message)
            }
        }
    }
    
}

extension EmergencyContactsListVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        return contacts.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let contact = contacts[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "EmergencyContactCell",
            for: indexPath
        ) as! EmergencyContactCell

        cell.selectionStyle = .none

        cell.userName.text = "\(contact.first_name) \(contact.last_name)"
        cell.userNumber.text = contact.phone_number

        if contact.profile_pic.isEmpty {

            cell.userImage.image = UIImage(named: "defaultProfileIcon")

        } else if let url = URL(string: contact.profile_pic) {

            cell.userImage.sd_setImage(
                with: url,
                placeholderImage: UIImage(named: "defaultProfileIcon")
            )
        }

        cell.editBtn.isHidden = !isEditable
        cell.deleteBtn.isHidden = !isEditable

        cell.editAction = { [weak self] in
            self?.editContact(contact)
        }

        cell.deleteAction = { [weak self] in
            self?.deleteContact(contact, at: indexPath.row)
        }

        return cell
    }
}
