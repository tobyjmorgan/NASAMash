//
//  CGRect+extensions.swift
//  ScrollViewTest
//
//  Created by redBred LLC on 3/6/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGRect {

    func changingOnlySize(size: CGSize) -> CGRect {
        return CGRect(origin: self.origin, size: size)
    }

    func changingOnlySize(origin: CGPoint) -> CGRect {
        return CGRect(origin: origin, size: self.size)
    }
}
