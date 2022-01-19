//
//  SelectStageVC.swift
//  railroad-switch iOS
//
//  Created by Rintaro Kawagishi on 07/01/2022.
//

import UIKit

class StagePage: UIView {
    var stage: Stage?
}

class SelectStageVC: UIViewController {
    var scrollView: UIScrollView!
    let PAGE_WIDTH: CGFloat = 200
    let STAGE_VIEW_WIDTH: CGFloat = 80
    let numStages = 10
    let scrollViewContentTrailingInset: CGFloat = 5000

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = .red
        scrollView.delegate = self
        scrollView.alwaysBounceHorizontal = true
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        self.view.addConstraints([
//            view.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            scrollView.widthAnchor.constraint(equalToConstant: PAGE_WIDTH),
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
        
        let contentView = UIView()
        contentView.backgroundColor = .blue
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addConstraints([
            // these 4 make contentView span the whole content
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // fix contentView height to the height of scrollView (for horizontal scrolling)
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])
        
        
        
        var labels: [UILabel] = []
        for n in 0..<numStages {
            let label = UILabel()
            labels.append(label)
            label.text = "HEY"
            label.backgroundColor = .purple
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
            
            label.addConstraints([
                label.widthAnchor.constraint(equalToConstant: STAGE_VIEW_WIDTH),
                label.heightAnchor.constraint(equalToConstant: STAGE_VIEW_WIDTH),
            ])
            
            contentView.addConstraints([
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])
            
            
            if n > 0 {
                scrollView.addConstraint(label.leadingAnchor.constraint(equalTo: labels[n-1].trailingAnchor, constant: PAGE_WIDTH - STAGE_VIEW_WIDTH))
            }
        }
        
        let firstSpace = UILayoutGuide()
        contentView.addLayoutGuide(firstSpace)
        
        
        let lastSpace = UILayoutGuide()
        contentView.addLayoutGuide(lastSpace)
        scrollView.addConstraints([
            // relationships to the content view
            firstSpace.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            firstSpace.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.5),
            firstSpace.topAnchor.constraint(equalTo: contentView.topAnchor),
            firstSpace.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // attach to first label
            firstSpace.trailingAnchor.constraint(equalTo: labels.first!.centerXAnchor),

            // relationships to the content view
            lastSpace.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.5),
            lastSpace.topAnchor.constraint(equalTo: contentView.topAnchor),
            lastSpace.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lastSpace.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // attach to the last label
            lastSpace.leadingAnchor.constraint(equalTo: labels.last!.centerXAnchor),
        ])
    }
}

extension SelectStageVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentX = scrollView.contentOffset.x
        let maxX = CGFloat(numStages-1) * PAGE_WIDTH
        var nextX: CGFloat
        if currentX < 0 { nextX = 0 }
        else if currentX > maxX { nextX = maxX }
        else {
            var remainder = currentX.remainder(dividingBy: PAGE_WIDTH)
            remainder = remainder > 0 ? remainder : remainder + PAGE_WIDTH
            nextX = currentX - remainder + (velocity.x > 0 ? PAGE_WIDTH : 0)
        }
        targetContentOffset.pointee.x = nextX
    }
    
    
}
