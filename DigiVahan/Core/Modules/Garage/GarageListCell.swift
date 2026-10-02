//
//  GarageListCell.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/06/26.
//

import UIKit

// MARK: - Expanded Touch Target Button
class GarageDeleteButton: UIButton {
    var hitAreaPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.inset(by: UIEdgeInsets(
            top: -hitAreaPadding.top,
            left: -hitAreaPadding.left,
            bottom: -hitAreaPadding.bottom,
            right: -hitAreaPadding.right
        ))
        return expandedBounds.contains(point)
    }
}

class GarageListCell: UITableViewCell {

    // MARK: - Storyboard Outlets (Preserved for compatibility)
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var vehicleClass: UILabel!
    @IBOutlet weak var deleteBtn: UIImageView!

    // MARK: - Modern UI Components
    let cardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 0.8
        view.layer.borderColor = UIColor(red: 222/255.0, green: 224/255.0, blue: 227/255.0, alpha: 1.0).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let vehicleNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-SemiBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor(red: 20/255.0, green: 20/255.0, blue: 20/255.0, alpha: 1.0)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let makerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(red: 120/255.0, green: 122/255.0, blue: 114/255.0, alpha: 1.0)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let vehicleNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Hind-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 120/255.0, green: 122/255.0, blue: 114/255.0, alpha: 1.0)
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let vehicleImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    let deleteButton: GarageDeleteButton = {
        let btn = GarageDeleteButton(type: .custom)
        let icon = UIImage(named: "close_icon1") ?? UIImage(named: "closeIcon")
        btn.setImage(icon, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.layer.zPosition = 999
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Actions
    var itemClickAction: (() -> Void)?
    var deleteAction: (() -> Void)?

    private var isModernUISetupDone = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupModernUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupModernUI()
    }

    private func setupModernUI() {
        guard !isModernUISetupDone else { return }
        isModernUISetupDone = true

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        clipsToBounds = false
        contentView.clipsToBounds = false

        // Remove old storyboard placeholder subviews from contentView
        contentView.subviews.forEach { $0.removeFromSuperview() }

        // Add views to contentView
        contentView.addSubview(cardContainer)
        contentView.addSubview(deleteButton)

        // Text stack (Name, Maker, Number)
        let textStackView = UIStackView(arrangedSubviews: [vehicleNameLabel, makerNameLabel, vehicleNumberLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 2
        textStackView.alignment = .leading
        textStackView.distribution = .fill
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Row content inside cardContainer
        let rowStackView = UIStackView(arrangedSubviews: [textStackView, vehicleImageView])
        rowStackView.axis = .horizontal
        rowStackView.spacing = 10
        rowStackView.alignment = .center
        rowStackView.distribution = .fill
        rowStackView.translatesAutoresizingMaskIntoConstraints = false

        cardContainer.addSubview(rowStackView)

        NSLayoutConstraint.activate([
            // Card container pinned to contentView with margins
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 94),

            // Row stack inside cardContainer
            rowStackView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 14),
            rowStackView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -14),
            rowStackView.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 12),
            rowStackView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -12),

            // Vehicle image size (matching Android 90dp x 70dp)
            vehicleImageView.widthAnchor.constraint(equalToConstant: 88),
            vehicleImageView.heightAnchor.constraint(equalToConstant: 68),

            // Delete button overlapping top-right corner of cardContainer
            deleteButton.widthAnchor.constraint(equalToConstant: 28),
            deleteButton.heightAnchor.constraint(equalToConstant: 28),
            deleteButton.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: 6),
            deleteButton.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: -6)
        ])

        // Tap gestures
        let cardTap = UITapGestureRecognizer(target: self, action: #selector(cardViewClicked))
        cardContainer.addGestureRecognizer(cardTap)
        cardContainer.isUserInteractionEnabled = true

        deleteButton.addTarget(self, action: #selector(deleteBtnClick), for: .touchUpInside)

        // Keep outlet references valid for compatibility
        self.cardView = cardContainer
        self.vehicleImage = vehicleImageView
        self.vehicleName = vehicleNameLabel
    }

    @objc private func deleteBtnClick() {
        deleteAction?()
    }

    @objc private func cardViewClicked() {
        itemClickAction?()
    }

    // MARK: - Configure
    func configure(with model: GarageItemModel) {
        vehicleNameLabel.text = model.makers_model ?? ""
        makerNameLabel.text = model.makers_name ?? ""

        let number = !(model.vehicle_number?.isEmpty ?? true) ? model.vehicle_number : model.vehicle_id
        vehicleNumberLabel.text = number ?? ""

        vehicleImageView.image = CommonFunctions.getVehiclePlaceholder(
            vehicleClass: model.vehicle_class,
            vehicleName: model.vehicle_name,
            makersModel: model.makers_model,
            category: model.category
        )
    }
}
