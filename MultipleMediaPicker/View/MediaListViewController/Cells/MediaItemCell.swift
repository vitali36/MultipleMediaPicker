//
//  MediaItemCell.swift
//  MultipleMediaPicker
//
//  Created by Vitaliy Bulavkin on 23.09.2020.
//  Copyright © 2020 Vitaliy Bulavkin. All rights reserved.
//

import UIKit

public class MediaItemCell: UICollectionViewCell, NibLoadableView {
    @IBOutlet weak public var photoImageView: UIImageView!
    @IBOutlet weak public var selectPhotoButton: UIButton!
    
    public var onSelected: (() -> ())?
    public var representedAssetIdentifier: String!
    
    public var thumbnailImage: UIImage! {
        didSet {
            photoImageView.image = thumbnailImage
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.image = nil
    }
    
    private func setupUI() {
        selectPhotoButton.addTarget(self, action: #selector(selectPhotoButtonTapped), for: .touchUpInside)
    }
    
    @objc
    private func selectPhotoButtonTapped() {
        guard let onSelected = self.onSelected else { return }
        onSelected()
    }
    
    public func setSelectedPhotoButton() {
        let bundle = Bundle(for: type(of: self))
        var selectedPhotoImage = UIImage()
        if #available(iOS 13.0, *) {
            selectedPhotoImage = UIImage(named: "selectedPhotoButton", in: bundle, with: nil)!
        } else {
            selectedPhotoImage = UIImage(named: "selectedPhotoButton", in: bundle, compatibleWith: nil)!
        }
        selectPhotoButton.setImage(selectedPhotoImage, for: .normal)
    }
    
    public func setDeselectedPhotoButton() {
        let bundle = Bundle(for: type(of: self))
        var deselectedPhotoImage = UIImage()
        if #available(iOS 13.0, *) {
            deselectedPhotoImage = UIImage(named: "deselectedPhotoButton", in: bundle, with: nil)!
        } else {
            deselectedPhotoImage = UIImage(named: "deselectedPhotoButton", in: bundle, compatibleWith: nil)!
        }
        selectPhotoButton.setImage(deselectedPhotoImage, for: .normal)
    }
}
