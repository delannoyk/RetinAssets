//
//  ArrayExtension.swift
//  RetinAssets
//
//  Created by Kevin DELANNOY on 19/05/15.
//  Copyright (c) 2015 Kevin Delannoy. All rights reserved.
//

import Cocoa

extension Array {
    func flattern<U>(identity: ([Element]) -> [[U]]) -> [U] {
        let x: [[U]] = identity(self)
        return x.reduce([], combine: +)
    }
}

func identity<T>(x: T) -> T {
    return x
}
