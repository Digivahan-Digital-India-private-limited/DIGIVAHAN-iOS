//
//  SemiCircleProgressView.swift
//  DigiVahan
//
//  Created for DigiVahan Dashboard Vehicle Info Cards.
//

import UIKit

@IBDesignable
class SemiCircleProgressView: UIView {
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    
    var progressThickness: CGFloat = 18.0 {
        didSet {
            trackLayer.lineWidth = progressThickness
            progressLayer.lineWidth = progressThickness
            setNeedsLayout()
        }
    }
    
    var trackColor: UIColor = UIColor(red: 211/255.0, green: 214/255.0, blue: 219/255.0, alpha: 1.0) { // #D3D6DB
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var progressColor: UIColor = UIColor(red: 47/255.0, green: 177/255.0, blue: 50/255.0, alpha: 1.0) { // #2FB132
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    /// Progress from 0.0 to 1.0
    private(set) var progress: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        backgroundColor = .clear
        
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineCap = .butt
        trackLayer.lineWidth = progressThickness
        layer.addSublayer(trackLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineCap = .butt
        progressLayer.lineWidth = progressThickness
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackLayer.frame = bounds
        progressLayer.frame = bounds
        
        trackLayer.lineWidth = progressThickness
        progressLayer.lineWidth = progressThickness
        
        let pad = progressThickness / 2.0 + 1.0
        let availableWidth = bounds.width - (pad * 2.0)
        let availableHeight = bounds.height - pad
        
        guard availableWidth > 0, availableHeight > 0 else { return }
        
        let radius = min(availableWidth / 2.0, availableHeight)
        let center = CGPoint(x: bounds.midX, y: bounds.height - pad)
        
        // Semicircle: from 180 degrees (pi, left) to 0 degrees (0/2*pi, right) clockwise
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = progress
        CATransaction.commit()
    }
    
    /// Set progress 0 to 100 percentage
    func setProgress(_ percent: Int, animated: Bool = true) {
        let fraction = CGFloat(max(0, min(100, percent))) / 100.0
        setProgressFraction(fraction, animated: animated)
    }
    
    /// Set progress 0.0 to 1.0
    func setProgressFraction(_ fraction: CGFloat, animated: Bool = true) {
        let safeValue = max(0.0, min(1.0, fraction))
        self.progress = safeValue
        
        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.duration = 0.5
            anim.fromValue = progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd
            anim.toValue = safeValue
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(anim, forKey: "strokeAnim")
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = safeValue
        CATransaction.commit()
    }
    
    func setProgressColor(_ color: UIColor) {
        self.progressColor = color
    }
    
    func setTrackColor(_ color: UIColor) {
        self.trackColor = color
    }
}
