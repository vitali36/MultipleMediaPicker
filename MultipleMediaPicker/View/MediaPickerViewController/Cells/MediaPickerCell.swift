//
//  MediaPickerCell.swift
//  Hologram
//
//  Created by Vitaliy Bulavkin on 23.09.2020.
//  Copyright © 2020 Vitaliy Bulavkin. All rights reserved.
//

import UIKit
import Photos

public class MediaPickerCell: UICollectionViewCell, NibLoadableView {
    @IBOutlet weak public var innerView: UIView!
    @IBOutlet weak public var backgroundImageView: UIImageView!
    @IBOutlet weak public var photoImageView: UIImageView!
    @IBOutlet weak public var nameLabel: UILabel!
    @IBOutlet weak public var filesCountLabel: UILabel!
    
    public var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            photoImageView.image = thumbnailImage
        }
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.image = nil
    }
    
    public func configure(with assetCollection: PHAssetCollection) {
        nameLabel.text = assetCollection.localizedTitle
        
        let result = PHAsset.fetchAssets(in: assetCollection, options: nil)
        filesCountLabel.text = "\(result.count)"
    }
}
