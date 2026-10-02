//
//  OrderListVC.swift
//  DigiVahan
//
//  Created for DigiVahan Order System Module.
//

import UIKit

class OrderListVC: BaseViewController {

    // MARK: - UI Components
    private let topNavBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let backButton: UIButton = {
        let btn = UIButton(type: .custom)
        if let icon = UIImage(named: "back_arrow") {
            btn.setImage(icon.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let fallback = UIImage(systemName: "arrow.left") {
            btn.setImage(fallback, for: .normal)
            btn.tintColor = .black
        }
        btn.imageView?.contentMode = .scaleAspectFit
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let navTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Orders"
        label.font = UIFont(name: "Hind-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let navDividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Empty State View
    private let emptyContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emptyImageView: UIImageView = {
        let iv = UIImageView()
        if let img = UIImage(named: "order_empty_image") {
            iv.image = img
        } else if let boxImg = UIImage(named: "my_order_icon") {
            iv.image = boxImg
        }
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Order List is empty"
        label.font = UIFont(name: "Hind-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emptySubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "No order has been made yet."
        label.font = UIFont(name: "Hind-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor(red: 120/255.0, green: 125/255.0, blue: 130/255.0, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(topNavBarView)
        topNavBarView.addSubview(backButton)
        topNavBarView.addSubview(navTitleLabel)
        topNavBarView.addSubview(navDividerLine)

        view.addSubview(emptyContainerView)
        emptyContainerView.addSubview(emptyImageView)
        emptyContainerView.addSubview(emptyTitleLabel)
        emptyContainerView.addSubview(emptySubtitleLabel)

        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // Top Nav Bar
            topNavBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topNavBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topNavBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topNavBarView.heightAnchor.constraint(equalToConstant: 48),

            backButton.leadingAnchor.constraint(equalTo: topNavBarView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: topNavBarView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),

            navTitleLabel.centerYAnchor.constraint(equalTo: topNavBarView.centerYAnchor),
            navTitleLabel.centerXAnchor.constraint(equalTo: topNavBarView.centerXAnchor),

            navDividerLine.leadingAnchor.constraint(equalTo: topNavBarView.leadingAnchor),
            navDividerLine.trailingAnchor.constraint(equalTo: topNavBarView.trailingAnchor),
            navDividerLine.bottomAnchor.constraint(equalTo: topNavBarView.bottomAnchor),
            navDividerLine.heightAnchor.constraint(equalToConstant: 0.6),

            // Empty State View
            emptyContainerView.topAnchor.constraint(equalTo: topNavBarView.bottomAnchor),
            emptyContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyImageView.centerXAnchor.constraint(equalTo: emptyContainerView.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: emptyContainerView.centerYAnchor, constant: -60),
            emptyImageView.widthAnchor.constraint(equalToConstant: 160),
            emptyImageView.heightAnchor.constraint(equalToConstant: 160),

            emptyTitleLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 24),
            emptyTitleLabel.leadingAnchor.constraint(equalTo: emptyContainerView.leadingAnchor, constant: 20),
            emptyTitleLabel.trailingAnchor.constraint(equalTo: emptyContainerView.trailingAnchor, constant: -20),

            emptySubtitleLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 8),
            emptySubtitleLabel.leadingAnchor.constraint(equalTo: emptyContainerView.leadingAnchor, constant: 20),
            emptySubtitleLabel.trailingAnchor.constraint(equalTo: emptyContainerView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Actions
    @objc private func backButtonTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
