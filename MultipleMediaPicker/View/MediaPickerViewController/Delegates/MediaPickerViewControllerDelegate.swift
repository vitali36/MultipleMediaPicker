//
//  MediaPickerViewControllerDelegate.swift
//  MultipleMediaPicker
//
//  Created by Vitaliy Bulavkin on 23.09.2020.
//  Copyright © 2020 Vitaliy Bulavkin. All rights reserved.
//

import Foundation
import Photos

public protocol MediaPickerViewControllerDelegate: AnyObject {
    func didSelectMedia(items: [PHAsset])
}
