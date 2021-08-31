//
//  String+regex.swift
//  DependencyGraph
//
//  Created by Isaac Ressler on 8/30/21.
//

import Foundation

extension String {
  func matches(for regexStr: String) -> [String]? {
    let regex: NSRegularExpression?
    do {
      regex = try NSRegularExpression(pattern: regexStr)
    } catch let error {
      print("invalid regex (\(regexStr)): \(error.localizedDescription)")
      return nil
    }

    guard let regex = regex else {
      print("invalid regex (\(regexStr))")
      return nil
    }

    let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
    var finalResults = [String]()
    for result in results {
      var newResults = [String]()
      if result.numberOfRanges > 1 {
        for index in 1..<result.numberOfRanges {
          let nsRange = result.range(at: index)
          if nsRange.length == 0 {
            continue
          }
          guard let range = Range(result.range(at: index), in: self) else {
            continue
          }
          let capturedMatch = String(self[range])
          newResults.append(capturedMatch)
        }
      }

      if newResults.isEmpty {
        guard result.range.length > 0, let range = Range(result.range, in: self) else {
          continue
        }
        let match = String(self[range])
        newResults.append(match)
      }
      finalResults.append(contentsOf: newResults.filter({ !$0.isEmpty }))
    }

    return finalResults
  }
}
