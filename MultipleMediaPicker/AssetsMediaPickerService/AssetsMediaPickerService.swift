//
//  AssetsMediaPickerService.swift
//  MultipleMediaPicker
//
//  Created by Vitaliy Bulavkin on 23.09.2020.
//  Copyright © 2020 Vitaliy Bulavkin. All rights reserved.
//

import Foundation
import Photos

public class AssetsMediaPickerService: AssetsMediaPickerServicing {
    public func fetchAssetCollections(with type: PHAssetCollectionType, subtype: PHAssetCollectionSubtype) -> PHFetchResult<PHAssetCollection> {
        return PHAssetCollection.fetchAssetCollections(with: type, subtype: subtype, options: nil)
    }
}
