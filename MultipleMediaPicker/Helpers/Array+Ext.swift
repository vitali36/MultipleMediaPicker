//
//  Array+Ext.swift
//  MultipleMediaPicker
//
//  Created by Vitaliy Bulavkin on 23.09.2020.
//  Copyright © 2020 Vitaliy Bulavkin. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func removeObject<U: Equatable>(_ object: U) {
        var index: Int?
        
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if let index = index {
            self.remove(at: index)
        }
    }
}
