//
//  MultiColorDonutChartView.swift
//  DigiVahan
//
//  Created for DigiVahan Dashboard Vehicle Info Cards.
//

import UIKit

@IBDesignable
class MultiColorDonutChartView: UIView {
    
    private var values: [CGFloat] = []
    private var colors: [UIColor] = []
    
    var strokeWidth: CGFloat = 14.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    func setData(values: [CGFloat], colors: [UIColor]) {
        self.values = values
        self.colors = colors
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !values.isEmpty, values.count == colors.count else { return }
        
        let total = values.reduce(0, +)
        guard total > 0 else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let minDimension = min(bounds.width, bounds.height)
        let radius = (minDimension - strokeWidth) / 2.0
        
        guard radius > 0 else { return }
        
        // Start from top (12 o'clock = -90 degrees = -pi / 2)
        var startAngle: CGFloat = -CGFloat.pi / 2.0
        
        for (index, value) in values.enumerated() {
            guard value > 0 else { continue }
            let sweep = (value / total) * 2.0 * CGFloat.pi
            let endAngle = startAngle + sweep
            
            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )
            
            path.lineWidth = strokeWidth
            path.lineCapStyle = .butt
            colors[index].setStroke()
            path.stroke()
            
            startAngle = endAngle
        }
    }
}
