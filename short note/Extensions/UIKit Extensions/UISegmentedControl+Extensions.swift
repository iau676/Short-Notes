//
//  UISegmentedControl+Extensions.swift
//  short note
//
//  Created by ibrahim uysal on 10.02.2023.
//

import UIKit

extension UISegmentedControl {
    func replaceSegments(segments: Array<String>) {
        self.removeAllSegments()
        for segment in segments {
            self.insertSegment(withTitle: segment, at: self.numberOfSegments, animated: false)
        }
    }
}
