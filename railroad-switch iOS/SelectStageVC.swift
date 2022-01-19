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
    let numStages = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = .red
        scrollView.delegate = self
        scrollView.alwaysBounceHorizontal = true
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        let contentView = UIView()
        contentView.backgroundColor = .blue
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        // make contentView span the whole content
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        // fix contentView height to the height of scrollView (for horizontal scrolling)
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        var stageViews: [UILabel] = []
        for n in 0..<numStages {
            let label = UILabel()
            stageViews.append(label)
            label.text = "HEY"
            label.backgroundColor = .purple
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(label)
            
            label.widthAnchor.constraint(equalToConstant: 100).isActive = true
            label.heightAnchor.constraint(equalToConstant: 100).isActive = true
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            if n > 0 {
                label.centerXAnchor.constraint(equalTo: stageViews[n - 1].centerXAnchor, constant: PAGE_WIDTH).isActive = true
            }
        }
        
        let firstSpace = UILayoutGuide()
        contentView.addLayoutGuide(firstSpace)
        // relationships to the content view
        firstSpace.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        firstSpace.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.5).isActive = true
        firstSpace.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        firstSpace.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        // attach to first label
        firstSpace.trailingAnchor.constraint(equalTo: stageViews.first!.centerXAnchor).isActive = true

        let lastSpace = UILayoutGuide()
        contentView.addLayoutGuide(lastSpace)
        // relationships to the content view
        lastSpace.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.5).isActive = true
        lastSpace.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        lastSpace.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        lastSpace.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        // attach to the last label
        lastSpace.leadingAnchor.constraint(equalTo: stageViews.last!.centerXAnchor).isActive = true
    }
}

extension SelectStageVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentX = scrollView.contentOffset.x
        let maxX = CGFloat(numStages - 1) * PAGE_WIDTH
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
