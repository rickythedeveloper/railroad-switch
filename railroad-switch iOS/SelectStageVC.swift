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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = .red
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        self.view.addConstraints([
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
        
        
        let label = UILabel()
        label.text = "HEY"
        label.backgroundColor = .purple
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        label.addConstraints([
            label.widthAnchor.constraint(equalToConstant: 100),
            label.heightAnchor.constraint(equalToConstant: 100),
        ])
        
        contentView.addConstraints([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
        scrollView.addConstraints([
            NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0),
        ])
        
        scrollView.alwaysBounceHorizontal = true

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
