//
//  MediaImageCell.swift
//  MultipleMediaPicker
//
//  Created by Vitaliy Bulavkin on 23.09.2020.
//  Copyright © 2020 Vitaliy Bulavkin. All rights reserved.
//

import UIKit

public class MediaImageCell: UICollectionViewCell {
    
    // MARK: Properties

    public var mediaImageView = UIImageView()
    public var selectButton = UIButton()
    public var representedAssetIdentifier: String!
    
    public var thumbnailImage: UIImage! {
        didSet {
            mediaImageView.image = thumbnailImage
        }
    }
    public var onSelected: (() -> ())?
    
    // MARK: Public

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        mediaImageView.image = nil
    }
    
    public func setSelectedPhotoButton() {
        let bundle = Bundle(for: type(of: self))
        var selectedPhotoImage = UIImage()
        if #available(iOS 13.0, *) {
            selectedPhotoImage = UIImage(named: "selectedPhotoButton", in: bundle, with: nil)!
        } else {
            selectedPhotoImage = UIImage(named: "selectedPhotoButton", in: bundle, compatibleWith: nil)!
        }
        selectButton.setImage(selectedPhotoImage, for: .normal)
    }
    
    public func setDeselectedPhotoButton() {
        let bundle = Bundle(for: type(of: self))
        var deselectedPhotoImage = UIImage()
        if #available(iOS 13.0, *) {
            deselectedPhotoImage = UIImage(named: "deselectedPhotoButton", in: bundle, with: nil)!
        } else {
            deselectedPhotoImage = UIImage(named: "deselectedPhotoButton", in: bundle, compatibleWith: nil)!
        }
        selectButton.setImage(deselectedPhotoImage, for: .normal)
    }
    
    // MARK: Private
    
    private func setupUI() {
        mediaImageView.contentMode = .scaleAspectFit
        mediaImageView.translatesAutoresizingMaskIntoConstraints = false
        
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        selectButton.addTarget(self, action: #selector(selectPhotoButtonTapped), for: .touchUpInside)
        let bundle = Bundle(for: type(of: self))
        var deselectedPhotoImage = UIImage()
        if #available(iOS 13.0, *) {
            deselectedPhotoImage = UIImage(named: "deselectedPhotoButton", in: bundle, with: nil)!
        } else {
            deselectedPhotoImage = UIImage(named: "deselectedPhotoButton", in: bundle, compatibleWith: nil)!
        }
        selectButton.setImage(deselectedPhotoImage, for: .normal)

        addSubview(mediaImageView)
        addSubview(selectButton)
        
        selectButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        selectButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        selectButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        selectButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true

        mediaImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mediaImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mediaImageView.topAnchor.constraint(equalTo: selectButton.bottomAnchor, constant: 20).isActive = true
        mediaImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    @objc
    private func selectPhotoButtonTapped() {
        guard let onSelected = self.onSelected else { return }
        onSelected()
    }
}
