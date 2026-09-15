//
//  RefreshTimerBottomSheet.swift
//  DigiVahan
//
//  Created by Mr Ash on 09/08/26.
//

import UIKit

class RefreshTimerBottomSheet: UIView {

    // MARK: - Singleton

    static let shared = RefreshTimerBottomSheet()

    // MARK: - UI

    private let backgroundView = UIView()

    private let containerView = UIView()

    private let titleLabel = UILabel()

    private let messageLabel = UILabel()

    private let stackView = UIStackView()

    private let dayLabel = UILabel()
    private let hourLabel = UILabel()
    private let minuteLabel = UILabel()
    private let secondLabel = UILabel()

    private let gotItButton = UIButton(type: .system)
    
    private var bottomConstraint: NSLayoutConstraint!

    // MARK: - Variables

    private var timer: Timer?

    private var remainingSeconds: Int = 0

    // MARK: - Init

    private override init(frame: CGRect) {

        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}

extension RefreshTimerBottomSheet {

    private func setupUI() {

        frame = UIScreen.main.bounds

        backgroundColor = .clear

        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        backgroundView.alpha = 0

        addSubview(backgroundView)

        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)

        ])

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 24

        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowRadius = 12
        containerView.layer.shadowOffset = CGSize(width: 0, height: -2)

        containerView.layer.masksToBounds = false

        addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        

        bottomConstraint = containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 350)

        NSLayoutConstraint.activate([

            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),

            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            bottomConstraint,

            containerView.heightAnchor.constraint(equalToConstant: 330)

        ])
        
        
        titleLabel.text = "Refresh Challan"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center

        containerView.addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),

            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)

        ])
        
        messageLabel.numberOfLines = 0

        messageLabel.textAlignment = .center

        messageLabel.font = UIFont.systemFont(ofSize: 17)

        messageLabel.textColor = .darkGray

        containerView.addSubview(messageLabel)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),

            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),

            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25)

        ])
        
        // MARK: - Timer StackView

        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 12

        containerView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            stackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 30),

            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),

            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            stackView.heightAnchor.constraint(equalToConstant: 70)

        ])
        
        
//        stackView.addArrangedSubview(
//            createTimerView(
//                valueLabel: dayLabel,
//                title: "Days"
//            )
//        )

        stackView.addArrangedSubview(
            createTimerView(
                valueLabel: hourLabel,
                title: "Hours"
            )
        )

        stackView.addArrangedSubview(
            createTimerView(
                valueLabel: minuteLabel,
                title: "Minutes"
            )
        )

        stackView.addArrangedSubview(
            createTimerView(
                valueLabel: secondLabel,
                title: "Seconds"
            )
        )
        
        // MARK: - Got It Button

        gotItButton.setTitle("Got It", for: .normal)

        gotItButton.setTitleColor(.white, for: .normal)

        gotItButton.backgroundColor = UIColor(named: "colorPrimary")

        gotItButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)

        gotItButton.layer.cornerRadius = 12

        gotItButton.addTarget(
            self,
            action: #selector(dismissSheet),
            for: .touchUpInside
        )

        containerView.addSubview(gotItButton)

        gotItButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            gotItButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),

            gotItButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            gotItButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            gotItButton.heightAnchor.constraint(equalToConstant: 50)

        ])
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissSheet)
        )

        backgroundView.addGestureRecognizer(tap)
        
    }
    
    @objc
    private func dismissSheet() {

        timer?.invalidate()
        timer = nil

        bottomConstraint.constant = 350

        UIView.animate(
            withDuration: 0.3,
            animations: {

                self.backgroundView.alpha = 0
                self.layoutIfNeeded()

            }, completion: { _ in

                self.removeFromSuperview()

            }
        )
    }
    
    func show(on viewController: UIViewController) {

        if superview != nil {
            removeFromSuperview()
        }

        frame = viewController.view.bounds

        viewController.view.addSubview(self)

        layoutIfNeeded()

        bottomConstraint.constant = 0

        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Configure

    func configure(
        remainingMillis: Int64,
        canRefresh: Bool
    ) {

        timer?.invalidate()

        if canRefresh {

            messageLabel.text = "Challan data updated successfully."

            stackView.isHidden = true

        } else {

            messageLabel.text = "Please wait before refreshing your challan again."

            stackView.isHidden = false

            remainingSeconds = Int(remainingMillis / 1000)

            updateTimerLabels()

            startTimer()
        }
    }
    
    // MARK: - Start Timer

    private func startTimer() {

        timer?.invalidate()

        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] timer in

            guard let self = self else { return }

            if self.remainingSeconds <= 0 {

                timer.invalidate()

                self.dayLabel.text = "00"
                self.hourLabel.text = "00"
                self.minuteLabel.text = "00"
                self.secondLabel.text = "00"

                self.messageLabel.text = "You can now refresh the challan."

                return
            }

            self.remainingSeconds -= 1

            self.updateTimerLabels()
        }
    }
    
    // MARK: - Update Timer

    private func updateTimerLabels() {

        let days = remainingSeconds / 86400

        let hours = (remainingSeconds % 86400) / 3600

        let minutes = (remainingSeconds % 3600) / 60

        let seconds = remainingSeconds % 60

        dayLabel.text = String(format: "%02d", days)

        hourLabel.text = String(format: "%02d", hours)

        minuteLabel.text = String(format: "%02d", minutes)

        secondLabel.text = String(format: "%02d", seconds)
    }
    
    func createTimerView(
            valueLabel: UILabel,
            title: String
        ) -> UIView {

            let container = UIView()

            let titleLabel = UILabel()

            valueLabel.font = UIFont.boldSystemFont(ofSize: 28)
            valueLabel.textAlignment = .center
            valueLabel.text = "00"

            titleLabel.font = UIFont.systemFont(ofSize: 13)
            titleLabel.textAlignment = .center
            titleLabel.textColor = .gray
            titleLabel.text = title

            container.addSubview(valueLabel)
            container.addSubview(titleLabel)

            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([

                valueLabel.topAnchor.constraint(equalTo: container.topAnchor),

                valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),

                valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

                titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),

                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),

                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

                titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)

            ])

            return container
        }

}
