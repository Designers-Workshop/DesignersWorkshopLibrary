//
//  Extensions.swift
//  
//
//  Created by Jeff Lebrun on 5/2/20.
//

import Foundation

// Array extension.
public extension Array where Element: Hashable {
	func removingDuplicates() -> [Element] {
		var addedDict = [Element: Bool]()
		
		return filter {
			addedDict.updateValue(true, forKey: $0) == nil
		}
	}
	
	mutating func removeDuplicates() {
		self = self.removingDuplicates()
	}
}
