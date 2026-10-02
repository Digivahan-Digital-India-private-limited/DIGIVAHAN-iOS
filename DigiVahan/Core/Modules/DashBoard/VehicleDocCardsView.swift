//
//  VehicleDocCardsView.swift
//  DigiVahan
//
//  Created for DigiVahan Dashboard Vehicle Info Cards (Insurance, PUC, Fitness Status).
//

import UIKit

class VehicleDocCardsView: UIView {
    
    // MARK: - Outer Card Container (Matches Android vehicleDocDatesLayout)
    private let outerCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor(red: 225/255.0, green: 225/255.0, blue: 225/255.0, alpha: 1.0).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Vertical Stack inside Outer Card
    private let innerCardsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Card 1: Insurance Card UI
    let insuranceCardView = VehicleDocCardsView.createInnerCard()
    let insuranceProgressGraph = SemiCircleProgressView()
    let insuranceDaysLeftLabel = UILabel()
    let insuranceExpiryTitleLabel = UILabel()
    let insuranceExpiryDateLabel = UILabel()
    let insurerNameLabel = UILabel()
    let policyTypeLabel = UILabel()
    
    // MARK: - Card 2: PUC Card UI
    let pucCardView = VehicleDocCardsView.createInnerCard()
    let pucProgressGraph = SemiCircleProgressView()
    let pucDaysLeftLabel = UILabel()
    let pucValidUpToLabel = UILabel()
    
    // MARK: - Card 3: Fitness Status Card UI
    let fitnessCardView = VehicleDocCardsView.createInnerCard()
    let fitnessDonutChart = MultiColorDonutChartView()
    let fitnessPillBadgeView = UIView()
    let fitnessIndicatorDot = UIView()
    let fitnessStatusLabel = UILabel()
    let vehicleRegisteredDateLabel = UILabel()
    let fitnessUptoDateLabel = UILabel()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Factory for Inner Card (Matches Android bg_card CardView)
    private static func createInnerCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1.0
        card.layer.borderColor = UIColor(red: 232/255.0, green: 232/255.0, blue: 232/255.0, alpha: 1.0).cgColor
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.05
        card.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        card.layer.shadowRadius = 3
        card.layer.masksToBounds = false
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        backgroundColor = .clear
        
        addSubview(outerCardView)
        outerCardView.addSubview(innerCardsStackView)
        
        NSLayoutConstraint.activate([
            outerCardView.topAnchor.constraint(equalTo: topAnchor),
            outerCardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerCardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            outerCardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            innerCardsStackView.topAnchor.constraint(equalTo: outerCardView.topAnchor, constant: 8),
            innerCardsStackView.leadingAnchor.constraint(equalTo: outerCardView.leadingAnchor, constant: 8),
            innerCardsStackView.trailingAnchor.constraint(equalTo: outerCardView.trailingAnchor, constant: -8),
            innerCardsStackView.bottomAnchor.constraint(equalTo: outerCardView.bottomAnchor, constant: -8)
        ])
        
        setupInsuranceCard()
        setupPUCCard()
        setupFitnessCard()
        
        innerCardsStackView.addArrangedSubview(insuranceCardView)
        innerCardsStackView.addArrangedSubview(pucCardView)
        innerCardsStackView.addArrangedSubview(fitnessCardView)
    }
    
    // MARK: - Setup Insurance Card
    private func setupInsuranceCard() {
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Insurance"
        titleLabel.font = UIFont(name: "Hind-SemiBold", size: 13.5) ?? UIFont.systemFont(ofSize: 13.5, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.12, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        insuranceCardView.addSubview(titleLabel)
        
        // Left Column (Graph + Overlaid Text)
        let graphContainer = UIView()
        graphContainer.translatesAutoresizingMaskIntoConstraints = false
        insuranceCardView.addSubview(graphContainer)
        
        insuranceProgressGraph.translatesAutoresizingMaskIntoConstraints = false
        insuranceProgressGraph.progressThickness = 18
        graphContainer.addSubview(insuranceProgressGraph)
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 1
        textStack.alignment = .center
        textStack.translatesAutoresizingMaskIntoConstraints = false
        graphContainer.addSubview(textStack)
        
        insuranceDaysLeftLabel.font = UIFont(name: "Hind-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        insuranceDaysLeftLabel.textColor = UIColor(white: 0.12, alpha: 1.0)
        insuranceDaysLeftLabel.textAlignment = .center
        textStack.addArrangedSubview(insuranceDaysLeftLabel)
        
        insuranceExpiryTitleLabel.text = "Expiry Date"
        insuranceExpiryTitleLabel.font = UIFont(name: "Hind-Regular", size: 10.5) ?? UIFont.systemFont(ofSize: 10.5)
        insuranceExpiryTitleLabel.textColor = UIColor(red: 157/255.0, green: 164/255.0, blue: 169/255.0, alpha: 1.0) // #9DA4A9
        insuranceExpiryTitleLabel.textAlignment = .center
        textStack.addArrangedSubview(insuranceExpiryTitleLabel)
        
        insuranceExpiryDateLabel.font = UIFont(name: "Hind-Medium", size: 11.5) ?? UIFont.systemFont(ofSize: 11.5, weight: .medium)
        insuranceExpiryDateLabel.textColor = UIColor(red: 111/255.0, green: 111/255.0, blue: 111/255.0, alpha: 1.0) // #6F6F6F
        insuranceExpiryDateLabel.textAlignment = .center
        textStack.addArrangedSubview(insuranceExpiryDateLabel)
        
        // Right Column (Insurer Name & Policy Type)
        let rightStack = UIStackView()
        rightStack.axis = .vertical
        rightStack.spacing = 2
        rightStack.alignment = .leading
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        insuranceCardView.addSubview(rightStack)
        
        let insurerTitle = UILabel()
        insurerTitle.text = "Insurer Name"
        insurerTitle.font = UIFont(name: "Hind-Bold", size: 12.5) ?? UIFont.boldSystemFont(ofSize: 12.5)
        insurerTitle.textColor = UIColor(white: 0.12, alpha: 1.0)
        rightStack.addArrangedSubview(insurerTitle)
        
        insurerNameLabel.font = UIFont(name: "Hind-Regular", size: 10.5) ?? UIFont.systemFont(ofSize: 10.5)
        insurerNameLabel.textColor = UIColor(white: 0.45, alpha: 1.0)
        insurerNameLabel.numberOfLines = 2
        rightStack.addArrangedSubview(insurerNameLabel)
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 6).isActive = true
        rightStack.addArrangedSubview(spacer)
        
        let policyTitle = UILabel()
        policyTitle.text = "Policy Type"
        policyTitle.font = UIFont(name: "Hind-Bold", size: 12.5) ?? UIFont.boldSystemFont(ofSize: 12.5)
        policyTitle.textColor = UIColor(white: 0.12, alpha: 1.0)
        rightStack.addArrangedSubview(policyTitle)
        
        policyTypeLabel.font = UIFont(name: "Hind-Regular", size: 10.5) ?? UIFont.systemFont(ofSize: 10.5)
        policyTypeLabel.textColor = UIColor(white: 0.45, alpha: 1.0)
        policyTypeLabel.numberOfLines = 1
        rightStack.addArrangedSubview(policyTypeLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: insuranceCardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: insuranceCardView.leadingAnchor, constant: 14),
            
            graphContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            graphContainer.leadingAnchor.constraint(equalTo: insuranceCardView.leadingAnchor, constant: 8),
            graphContainer.widthAnchor.constraint(equalToConstant: 154),
            graphContainer.bottomAnchor.constraint(lessThanOrEqualTo: insuranceCardView.bottomAnchor, constant: -12),
            
            insuranceProgressGraph.topAnchor.constraint(equalTo: graphContainer.topAnchor),
            insuranceProgressGraph.leadingAnchor.constraint(equalTo: graphContainer.leadingAnchor),
            insuranceProgressGraph.trailingAnchor.constraint(equalTo: graphContainer.trailingAnchor),
            insuranceProgressGraph.heightAnchor.constraint(equalToConstant: 77),
            
            textStack.centerXAnchor.constraint(equalTo: insuranceProgressGraph.centerXAnchor),
            textStack.topAnchor.constraint(equalTo: insuranceProgressGraph.topAnchor, constant: 26),
            textStack.bottomAnchor.constraint(equalTo: graphContainer.bottomAnchor),
            
            rightStack.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 2),
            rightStack.leadingAnchor.constraint(equalTo: graphContainer.trailingAnchor, constant: 14),
            rightStack.trailingAnchor.constraint(equalTo: insuranceCardView.trailingAnchor, constant: -14),
            rightStack.bottomAnchor.constraint(lessThanOrEqualTo: insuranceCardView.bottomAnchor, constant: -12),
            
            insuranceCardView.bottomAnchor.constraint(greaterThanOrEqualTo: graphContainer.bottomAnchor, constant: 12),
            insuranceCardView.bottomAnchor.constraint(greaterThanOrEqualTo: rightStack.bottomAnchor, constant: 12)
        ])
    }
    
    // MARK: - Setup PUC Card
    private func setupPUCCard() {
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "PUC"
        titleLabel.font = UIFont(name: "Hind-SemiBold", size: 13.5) ?? UIFont.systemFont(ofSize: 13.5, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.12, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pucCardView.addSubview(titleLabel)
        
        // Left Column (Graph + Overlaid Text)
        let graphContainer = UIView()
        graphContainer.translatesAutoresizingMaskIntoConstraints = false
        pucCardView.addSubview(graphContainer)
        
        pucProgressGraph.translatesAutoresizingMaskIntoConstraints = false
        pucProgressGraph.progressThickness = 18
        graphContainer.addSubview(pucProgressGraph)
        
        pucDaysLeftLabel.numberOfLines = 2
        pucDaysLeftLabel.textAlignment = .center
        pucDaysLeftLabel.translatesAutoresizingMaskIntoConstraints = false
        graphContainer.addSubview(pucDaysLeftLabel)
        
        // Right Column (Valid Up To)
        let rightStack = UIStackView()
        rightStack.axis = .vertical
        rightStack.spacing = 2
        rightStack.alignment = .leading
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        pucCardView.addSubview(rightStack)
        
        let validUpToTitle = UILabel()
        validUpToTitle.text = "Valid Up To"
        validUpToTitle.font = UIFont(name: "Hind-Bold", size: 12.5) ?? UIFont.boldSystemFont(ofSize: 12.5)
        validUpToTitle.textColor = UIColor(white: 0.12, alpha: 1.0)
        rightStack.addArrangedSubview(validUpToTitle)
        
        pucValidUpToLabel.font = UIFont(name: "Hind-Regular", size: 10.5) ?? UIFont.systemFont(ofSize: 10.5)
        pucValidUpToLabel.textColor = UIColor(white: 0.45, alpha: 1.0)
        pucValidUpToLabel.numberOfLines = 1
        rightStack.addArrangedSubview(pucValidUpToLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: pucCardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: pucCardView.leadingAnchor, constant: 14),
            
            graphContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            graphContainer.leadingAnchor.constraint(equalTo: pucCardView.leadingAnchor, constant: 8),
            graphContainer.widthAnchor.constraint(equalToConstant: 154),
            graphContainer.heightAnchor.constraint(equalToConstant: 77),
            graphContainer.bottomAnchor.constraint(lessThanOrEqualTo: pucCardView.bottomAnchor, constant: -12),
            
            pucProgressGraph.topAnchor.constraint(equalTo: graphContainer.topAnchor),
            pucProgressGraph.leadingAnchor.constraint(equalTo: graphContainer.leadingAnchor),
            pucProgressGraph.trailingAnchor.constraint(equalTo: graphContainer.trailingAnchor),
            pucProgressGraph.heightAnchor.constraint(equalToConstant: 77),
            
            pucDaysLeftLabel.centerXAnchor.constraint(equalTo: pucProgressGraph.centerXAnchor),
            pucDaysLeftLabel.centerYAnchor.constraint(equalTo: pucProgressGraph.centerYAnchor, constant: 8),
            
            rightStack.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 2),
            rightStack.leadingAnchor.constraint(equalTo: graphContainer.trailingAnchor, constant: 14),
            rightStack.trailingAnchor.constraint(equalTo: pucCardView.trailingAnchor, constant: -14),
            rightStack.bottomAnchor.constraint(lessThanOrEqualTo: pucCardView.bottomAnchor, constant: -12),
            
            pucCardView.bottomAnchor.constraint(greaterThanOrEqualTo: graphContainer.bottomAnchor, constant: 12),
            pucCardView.bottomAnchor.constraint(greaterThanOrEqualTo: rightStack.bottomAnchor, constant: 12)
        ])
    }
    
    // MARK: - Setup Fitness Status Card
    private func setupFitnessCard() {
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Fitness Status"
        titleLabel.font = UIFont(name: "Hind-SemiBold", size: 13.5) ?? UIFont.systemFont(ofSize: 13.5, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.12, alpha: 1.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        fitnessCardView.addSubview(titleLabel)
        
        // Left Column (Donut Chart + Pill Badge)
        let leftContainer = UIView()
        leftContainer.translatesAutoresizingMaskIntoConstraints = false
        fitnessCardView.addSubview(leftContainer)
        
        fitnessDonutChart.translatesAutoresizingMaskIntoConstraints = false
        fitnessDonutChart.strokeWidth = 16
        leftContainer.addSubview(fitnessDonutChart)
        
        fitnessPillBadgeView.translatesAutoresizingMaskIntoConstraints = false
        fitnessPillBadgeView.layer.cornerRadius = 10
        fitnessPillBadgeView.backgroundColor = UIColor(red: 226/255.0, green: 240/255.0, blue: 223/255.0, alpha: 1.0) // #E2F0DF
        fitnessPillBadgeView.layer.shadowColor = UIColor.black.cgColor
        fitnessPillBadgeView.layer.shadowOpacity = 0.05
        fitnessPillBadgeView.layer.shadowOffset = CGSize(width: 0, height: 1)
        fitnessPillBadgeView.layer.shadowRadius = 2
        fitnessPillBadgeView.layer.masksToBounds = false
        leftContainer.addSubview(fitnessPillBadgeView)
        
        let badgeStack = UIStackView()
        badgeStack.axis = .horizontal
        badgeStack.spacing = 5
        badgeStack.alignment = .center
        badgeStack.translatesAutoresizingMaskIntoConstraints = false
        fitnessPillBadgeView.addSubview(badgeStack)
        
        fitnessIndicatorDot.translatesAutoresizingMaskIntoConstraints = false
        fitnessIndicatorDot.layer.cornerRadius = 3.5
        fitnessIndicatorDot.clipsToBounds = true
        badgeStack.addArrangedSubview(fitnessIndicatorDot)
        
        fitnessStatusLabel.font = UIFont(name: "Hind-SemiBold", size: 11) ?? UIFont.systemFont(ofSize: 11, weight: .semibold)
        fitnessStatusLabel.textColor = UIColor(white: 0.12, alpha: 1.0)
        badgeStack.addArrangedSubview(fitnessStatusLabel)
        
        // Right Column (Registration Date + Fitness Upto Date)
        let rightStack = UIStackView()
        rightStack.axis = .vertical
        rightStack.spacing = 2
        rightStack.alignment = .leading
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        fitnessCardView.addSubview(rightStack)
        
        let regTitle = UILabel()
        regTitle.text = "Vehicle Registered On"
        regTitle.font = UIFont(name: "Hind-Bold", size: 12.5) ?? UIFont.boldSystemFont(ofSize: 12.5)
        regTitle.textColor = UIColor(white: 0.12, alpha: 1.0)
        rightStack.addArrangedSubview(regTitle)
        
        vehicleRegisteredDateLabel.font = UIFont(name: "Hind-Regular", size: 10.5) ?? UIFont.systemFont(ofSize: 10.5)
        vehicleRegisteredDateLabel.textColor = UIColor(white: 0.45, alpha: 1.0)
        rightStack.addArrangedSubview(vehicleRegisteredDateLabel)
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        rightStack.addArrangedSubview(spacer)
        
        let fitnessTitle = UILabel()
        fitnessTitle.text = "Fitness Registered Up To"
        fitnessTitle.font = UIFont(name: "Hind-Bold", size: 12.5) ?? UIFont.boldSystemFont(ofSize: 12.5)
        fitnessTitle.textColor = UIColor(white: 0.12, alpha: 1.0)
        rightStack.addArrangedSubview(fitnessTitle)
        
        fitnessUptoDateLabel.font = UIFont(name: "Hind-Regular", size: 10.5) ?? UIFont.systemFont(ofSize: 10.5)
        fitnessUptoDateLabel.textColor = UIColor(white: 0.45, alpha: 1.0)
        rightStack.addArrangedSubview(fitnessUptoDateLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: fitnessCardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: fitnessCardView.leadingAnchor, constant: 14),
            
            leftContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            leftContainer.leadingAnchor.constraint(equalTo: fitnessCardView.leadingAnchor, constant: 14),
            leftContainer.widthAnchor.constraint(equalToConstant: 106),
            leftContainer.bottomAnchor.constraint(lessThanOrEqualTo: fitnessCardView.bottomAnchor, constant: -12),
            
            fitnessDonutChart.topAnchor.constraint(equalTo: leftContainer.topAnchor),
            fitnessDonutChart.centerXAnchor.constraint(equalTo: leftContainer.centerXAnchor),
            fitnessDonutChart.widthAnchor.constraint(equalToConstant: 84),
            fitnessDonutChart.heightAnchor.constraint(equalToConstant: 84),
            
            fitnessPillBadgeView.topAnchor.constraint(equalTo: fitnessDonutChart.bottomAnchor, constant: 7),
            fitnessPillBadgeView.centerXAnchor.constraint(equalTo: leftContainer.centerXAnchor),
            fitnessPillBadgeView.heightAnchor.constraint(equalToConstant: 22),
            fitnessPillBadgeView.bottomAnchor.constraint(equalTo: leftContainer.bottomAnchor),
            
            badgeStack.leadingAnchor.constraint(equalTo: fitnessPillBadgeView.leadingAnchor, constant: 8),
            badgeStack.trailingAnchor.constraint(equalTo: fitnessPillBadgeView.trailingAnchor, constant: -8),
            badgeStack.centerYAnchor.constraint(equalTo: fitnessPillBadgeView.centerYAnchor),
            
            fitnessIndicatorDot.widthAnchor.constraint(equalToConstant: 7),
            fitnessIndicatorDot.heightAnchor.constraint(equalToConstant: 7),
            
            rightStack.topAnchor.constraint(equalTo: fitnessDonutChart.topAnchor, constant: 2),
            rightStack.leadingAnchor.constraint(equalTo: leftContainer.trailingAnchor, constant: 14),
            rightStack.trailingAnchor.constraint(equalTo: fitnessCardView.trailingAnchor, constant: -14),
            rightStack.bottomAnchor.constraint(lessThanOrEqualTo: fitnessCardView.bottomAnchor, constant: -12),
            
            fitnessCardView.bottomAnchor.constraint(greaterThanOrEqualTo: leftContainer.bottomAnchor, constant: 12),
            fitnessCardView.bottomAnchor.constraint(greaterThanOrEqualTo: rightStack.bottomAnchor, constant: 12)
        ])
    }
    
    // MARK: - Data Binding
    func configure(with model: GarageItemModel) {
        configureInsurance(with: model)
        configurePUC(with: model)
        configureFitness(with: model)
    }
    
    private func configureInsurance(with model: GarageItemModel) {
        let insurer = (model.insurer_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        insurerNameLabel.text = insurer.isEmpty ? "N/A" : insurer
        
        let policyType = (model.insurance_type ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        policyTypeLabel.text = policyType.isEmpty ? "Comprehensive" : policyType
        
        let rawExpiry = (model.insurance_expiry ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let formattedExpiry = TimeUtils.convertDateFormat(rawExpiry, outputFormat: "dd MMM yyyy")
        insuranceExpiryDateLabel.text = formattedExpiry.isEmpty ? "N/A" : formattedExpiry
        
        if !rawExpiry.isEmpty, let _ = TimeUtils.parseDateSafely(rawExpiry) {
            let todayFormatted = TimeUtils.getCurrentDate("dd MMM yyyy")
            let isExpired = TimeUtils.isDateExpired(currentDateString: todayFormatted, targetDateString: formattedExpiry)
            var daysLeft = TimeUtils.getDaysDifference(todayFormatted, formattedExpiry)
            if isExpired {
                daysLeft = daysLeft != 0 ? -daysLeft : 0
            }
            
            if daysLeft >= 0 {
                insuranceDaysLeftLabel.text = "\(daysLeft) Days Left"
            } else {
                insuranceDaysLeftLabel.text = "\(-daysLeft) Days Ago"
            }
            
            let pct = calculateRemainingPercentage(daysPassed: daysLeft)
            insuranceProgressGraph.setProgressColor(getProgressColor(for: daysLeft))
            insuranceProgressGraph.setProgress(pct)
        } else {
            insuranceDaysLeftLabel.text = "N/A"
            insuranceProgressGraph.setProgress(0)
        }
    }
    
    private func configurePUC(with model: GarageItemModel) {
        let rawPucExpiry = (model.pollution_expiry ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let formattedPucExpiry = TimeUtils.convertDateFormat(rawPucExpiry, outputFormat: "dd MMM yyyy")
        pucValidUpToLabel.text = formattedPucExpiry.isEmpty ? "N/A" : formattedPucExpiry
        
        if !rawPucExpiry.isEmpty, let _ = TimeUtils.parseDateSafely(rawPucExpiry) {
            let todayFormatted = TimeUtils.getCurrentDate("dd MMM yyyy")
            let isExpired = TimeUtils.isDateExpired(currentDateString: todayFormatted, targetDateString: formattedPucExpiry)
            var daysLeft = TimeUtils.getDaysDifference(todayFormatted, formattedPucExpiry)
            if isExpired {
                daysLeft = daysLeft != 0 ? -daysLeft : 0
            }
            
            let daysString: String
            let subtitleString: String
            if daysLeft >= 0 {
                daysString = "\(daysLeft)"
                subtitleString = "Days Left"
            } else {
                daysString = "\(-daysLeft)"
                subtitleString = "Days Ago"
            }
            
            let attr = NSMutableAttributedString(
                string: "\(daysString)\n",
                attributes: [
                    .font: UIFont(name: "Hind-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor(white: 0.12, alpha: 1.0)
                ]
            )
            attr.append(NSAttributedString(
                string: subtitleString,
                attributes: [
                    .font: UIFont(name: "Hind-Bold", size: 13.5) ?? UIFont.boldSystemFont(ofSize: 13.5),
                    .foregroundColor: UIColor(white: 0.12, alpha: 1.0)
                ]
            ))
            pucDaysLeftLabel.attributedText = attr
            
            let pct = calculateRemainingPercentage(daysPassed: daysLeft)
            pucProgressGraph.setProgressColor(getProgressColor(for: daysLeft))
            pucProgressGraph.setProgress(pct)
        } else {
            pucDaysLeftLabel.text = "N/A"
            pucProgressGraph.setProgress(0)
        }
    }
    
    private func configureFitness(with model: GarageItemModel) {
        let rawRegDate = (model.registration_date ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let formattedRegDate = TimeUtils.convertDateFormat(rawRegDate, outputFormat: "dd MMM yyyy")
        vehicleRegisteredDateLabel.text = formattedRegDate.isEmpty ? "N/A" : formattedRegDate
        
        let rawFitnessExpiry = (model.fitness_upto ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let formattedFitnessExpiry = TimeUtils.convertDateFormat(rawFitnessExpiry, outputFormat: "dd MMM yyyy")
        fitnessUptoDateLabel.text = formattedFitnessExpiry.isEmpty ? "N/A" : formattedFitnessExpiry
        
        let todayFormatted = TimeUtils.getCurrentDate("dd MMM yyyy")
        let isFitnessExpired = formattedFitnessExpiry.isEmpty || TimeUtils.isDateExpired(currentDateString: todayFormatted, targetDateString: formattedFitnessExpiry)
        
        if isFitnessExpired {
            fitnessStatusLabel.text = "Expired"
            fitnessStatusLabel.textColor = UIColor(red: 198/255.0, green: 40/255.0, blue: 40/255.0, alpha: 1.0) // #C62828
            fitnessIndicatorDot.backgroundColor = UIColor(red: 239/255.0, green: 59/255.0, blue: 59/255.0, alpha: 1.0) // #EF3B3B
            fitnessPillBadgeView.backgroundColor = UIColor(red: 255/255.0, green: 235/255.0, blue: 238/255.0, alpha: 1.0) // #FFEBEE
            
            fitnessDonutChart.setData(
                values: [100.0],
                colors: [UIColor(red: 239/255.0, green: 59/255.0, blue: 59/255.0, alpha: 1.0)]
            )
        } else {
            fitnessStatusLabel.text = "Valid"
            fitnessStatusLabel.textColor = UIColor(white: 0.12, alpha: 1.0)
            fitnessIndicatorDot.backgroundColor = UIColor(red: 47/255.0, green: 177/255.0, blue: 50/255.0, alpha: 1.0) // #2FB132
            fitnessPillBadgeView.backgroundColor = UIColor(red: 226/255.0, green: 240/255.0, blue: 223/255.0, alpha: 1.0) // #E2F0DF
            
            let ratio = calculateFitnessRatio(startDateStr: formattedRegDate, endDateStr: formattedFitnessExpiry)
            let passed = max(1.0, CGFloat(ratio.passed))
            let remaining = max(1.0, CGFloat(ratio.remaining))
            
            let redColor = UIColor(red: 255/255.0, green: 107/255.0, blue: 107/255.0, alpha: 1.0) // #FF6B6B
            let greenColor = UIColor(red: 47/255.0, green: 177/255.0, blue: 50/255.0, alpha: 1.0) // #2FB132
            
            fitnessDonutChart.setData(
                values: [passed, remaining],
                colors: [redColor, greenColor]
            )
        }
    }
    
    // MARK: - Calculation Helpers
    private func calculateRemainingPercentage(daysPassed: Int) -> Int {
        var days = daysPassed
        if days < 0 { days = 0 }
        let percentage: Double
        if days > 300 {
            percentage = 1.0
        } else if days >= 150 && days <= 300 {
            percentage = ((300.0 - Double(days)) / (300.0 - 150.0)) * 100.0
        } else if days >= 90 && days < 150 {
            percentage = ((150.0 - Double(days)) / (150.0 - 90.0)) * 100.0
        } else if days >= 30 && days < 90 {
            percentage = ((90.0 - Double(days)) / (90.0 - 30.0)) * 100.0
        } else if days >= 0 && days < 30 {
            percentage = ((30.0 - Double(days)) / 30.0) * 100.0
        } else {
            percentage = 100.0
        }
        return max(0, min(100, Int(round(percentage))))
    }
    
    private func getProgressColor(for daysLeft: Int) -> UIColor {
        if daysLeft >= 90 {
            return UIColor(red: 54/255.0, green: 183/255.0, blue: 46/255.0, alpha: 1.0) // #36B72E
        } else if daysLeft >= 30 {
            return UIColor(red: 247/255.0, green: 228/255.0, blue: 183/255.0, alpha: 1.0) // #F7E4B7
        } else if daysLeft >= 10 {
            return UIColor(red: 255/255.0, green: 130/255.0, blue: 130/255.0, alpha: 1.0) // #FF8282
        } else {
            return UIColor(red: 239/255.0, green: 59/255.0, blue: 59/255.0, alpha: 1.0) // #EF3B3B
        }
    }
    
    private func calculateFitnessRatio(startDateStr: String, endDateStr: String) -> (passed: Int, remaining: Int) {
        guard let startDate = TimeUtils.parseDateSafely(startDateStr),
              let endDate = TimeUtils.parseDateSafely(endDateStr) else {
            return (0, 100)
        }
        let today = Date()
        if today < startDate {
            return (0, 100)
        }
        if today > endDate {
            return (100, 0)
        }
        let totalDuration = endDate.timeIntervalSince(startDate)
        guard totalDuration > 0 else {
            return (100, 0)
        }
        let passedDuration = today.timeIntervalSince(startDate)
        let passedRatio = (passedDuration / totalDuration) * 100.0
        let remainingRatio = 100.0 - passedRatio
        return (Int(round(passedRatio)), Int(round(remainingRatio)))
    }
}
