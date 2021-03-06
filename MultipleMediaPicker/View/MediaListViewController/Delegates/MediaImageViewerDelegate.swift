//
//  MediaImageViewerDelegate.swift
//  MultipleMediaPicker
//
//  Created by Vitaliy Bulavkin on 23.09.2020.
//  Copyright © 2020 Vitaliy Bulavkin. All rights reserved.
//

import Foundation

public protocol MediaImageViewerDelegate: AnyObject {
    func selectImageAt(index: Int)
    func deselectImageAt(index: Int)
}
