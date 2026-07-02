//
//  CircularProgressView.swift
//  DigiVahan
//
//  Created by Mr Ash on 03/06/26.
//

import UIKit

class CircularProgressView: UIView {

    /*
     Usage:

     // 70%
     profileProgress.setProgress(0.70)

     // 42%
     profileProgress.setProgress(0.42)

     // If server returns 42
     profileProgress.setProgress(
         CGFloat(42) / 100.0
     )
     */

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    /// Progress value between 0.0 and 1.0
    var progress: CGFloat = 0.0 {
        didSet {
            progressLayer.strokeEnd = progress
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        createCircle()
    }

    private func createCircle() {

        trackLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()

        let center = CGPoint(
            x: bounds.width / 2,
            y: bounds.height / 2
        )

        let radius =
        min(bounds.width, bounds.height) / 2 - 15

        // Similar to Android rotation="120"
        let startAngle = CGFloat.pi * 0.6
        let endAngle = CGFloat.pi * 2.4

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )

        // Background Circle
        trackLayer.path = path.cgPath
        trackLayer.strokeColor =
        UIColor.systemGray4.cgColor

        trackLayer.fillColor =
        UIColor.clear.cgColor

        trackLayer.lineWidth = 10
        trackLayer.lineCap = .round

        layer.addSublayer(trackLayer)

        // Progress Circle
        progressLayer.path = path.cgPath
        progressLayer.strokeColor =
        UIColor.systemGreen.cgColor

        progressLayer.fillColor =
        UIColor.clear.cgColor

        progressLayer.lineWidth = 10
        progressLayer.lineCap = .round

        progressLayer.strokeEnd = progress

        layer.addSublayer(progressLayer)

        print("Drawing Circle Progress =", progress)
    }

    /// Set progress between 0.0 and 1.0
    func setProgress(
        _ value: CGFloat,
        animated: Bool = true
    ) {

        let safeValue =
        min(max(value, 0.0), 1.0)

        // IMPORTANT
        progress = safeValue

        if animated {

            let animation =
            CABasicAnimation(
                keyPath: "strokeEnd"
            )

            animation.duration = 1.0
            animation.fromValue =
            progressLayer.presentation()?.strokeEnd
            ?? progressLayer.strokeEnd

            animation.toValue = safeValue

            progressLayer.add(
                animation,
                forKey: "progress"
            )
        }

        progressLayer.strokeEnd = safeValue
    }
}
