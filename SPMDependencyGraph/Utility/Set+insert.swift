//
//  Set+insert.swift
//  DependencyGraph
//
//  Created by Isaac Ressler on 8/30/21.
//

import Foundation

extension Set {
  mutating func insert(contentsOf newElements: [Element]) {
    for newElement in newElements {
      insert(newElement)
    }
  }
}
