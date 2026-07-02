//
//  LoadingView.swift
//  DigiVahan
//
//  Created by Mr Ash on 29/05/26.
//

import UIKit

class LoadingView: UIView {

    private let containerView = UIView()
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)

    private var timer: Timer?
    private var progress: Float = 0.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {

        backgroundColor = UIColor.black.withAlphaComponent(0.4)

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16

        addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 220)
        ])

        // Logo
        logoImageView.image = UIImage(named: "app_logo")
        logoImageView.contentMode = .scaleAspectFit

        // Text
        titleLabel.text = "Please wait..."
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center

        // Progress
        progressView.progressTintColor = UIColor.systemGreen
        progressView.trackTintColor = UIColor.systemGray5
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true

        let stack = UIStackView(arrangedSubviews: [
            logoImageView,
            titleLabel,
            progressView
        ])

        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill

        containerView.addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),

            logoImageView.heightAnchor.constraint(equalToConstant: 70),
            progressView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }

    func startLoading() {

        progress = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in

            self.progress += 0.01

            if self.progress >= 1 {
                self.progress = 0
            }

            self.progressView.setProgress(self.progress, animated: true)
        }
    }

    func stopLoading() {
        timer?.invalidate()
        timer = nil
    }
}
