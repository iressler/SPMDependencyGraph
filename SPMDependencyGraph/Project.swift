//
//  Project.swift
//  DependencyGraph
//
//  Created by Isaac Ressler on 8/30/21.
//

import Foundation

class Project {
  var name: String
  private(set) var dependents: [Project] = []
  private(set) var dependencies: [Project] = []

  var totalDependencies: Int {
    return dependencies.reduce(into: 0) { partialResult, project in
      partialResult = partialResult + 1 + project.totalDependencies
    }
  }

  func addDependency(_ dependency: Project) {
    self.dependencies.append(dependency)
    dependency.dependents.append(self)
  }

  init(name: String) {
    self.name = Self.sanitize(name)
  }

  func nameMatches(_ otherName: String) -> Bool {
    return name.caseInsensitiveCompare(Self.sanitize(otherName)) == .orderedSame
  }

  static func sanitize(_ string: String) -> String {
    return string.removingCharacters(in: .alphanumerics.inverted)
  }
}

extension Project: CustomStringConvertible {
  var description: String {
    return description(indentCount: 0)
  }

  private func description(indentCount: Int) -> String{
    let indent = String(repeating: " ", count: indentCount * 2)
    var description = indent + name
    if !dependencies.isEmpty {
      description.append("\n\(dependencies.map({ $0.description(indentCount: indentCount+1) }).joined(separator: "\n"))")
    }
    return description

  }
}

// Equality/hash calculated on name only to allow for comparing against existing projects when calculating dependencies.
extension Project: Equatable {
  static func == (lhs: Project, rhs: Project) -> Bool {
    return lhs.name == rhs.name
  }
}

extension Project: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
}
