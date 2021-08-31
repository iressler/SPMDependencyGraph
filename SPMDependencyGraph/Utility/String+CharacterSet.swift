//
//  String+CharacterSet.swift
//  DependencyGraph
//
//  Created by Isaac Ressler on 8/30/21.
//

import Foundation

extension String {
  func removingCharacters(in set: CharacterSet) -> String {
    return String(UnicodeScalarView(unicodeScalars.lazy.filter({ (char: Unicode.Scalar) -> Bool in
      return !set.contains(char)
    })))
  }
}
