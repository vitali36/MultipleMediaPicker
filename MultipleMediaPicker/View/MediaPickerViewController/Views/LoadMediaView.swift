//
//  BottomView.swift
//  MultipleMediaPicker
//
//  Created by Vitaliy Bulavkin on 23.09.2020.
//  Copyright © 2020 Vitaliy Bulavkin. All rights reserved.
//

import UIKit

public class LoadMediaView: UIView {
    
    // MARK: Outlets

    @IBOutlet weak public var countLabel: UILabel!
    @IBOutlet weak public var countView: UIView!
    @IBOutlet weak public var downloadLabel: UILabel!
    @IBOutlet weak public var innerView: UIView!
    
    // MARK: Properties

    var onTapped: (() -> ())?
    
    // MARK: Public
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    public func setMedia(count: Int) {
        countLabel.text = "\(count)"
    }
    
    // MARK: Private
    
    private func setupUI() {
        countView.cornerRadius = countView.bounds.height / 2
        innerView.cornerRadius = innerView.bounds.height / 2
        
        innerView.isUserInteractionEnabled = true
        innerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadMediaTapped)))
    }
    
    @objc
    private func loadMediaTapped() {
        guard let onTapped = onTapped else { return }
        onTapped()
    }
}
