//
//  URL+packageFiles.swift
//  DependencyGraph
//
//  Created by Isaac Ressler on 8/30/21.
//

import Foundation

extension URL {
  func packageFiles() -> [URL]? {
    return packageFiles(depth: 2)
//    let subDirPackageURL = self.appendingPathComponent("Package.swift")
//    if fileManager.fileExists(atPath: subDirPackageURL.path) {
//      return [subDirPackageURL]
//    }
//    return []
  }

  // Depth is how many subdirectories to go down to find a pack file if the URL is a directory.
  private func packageFiles(depth: Int) -> [URL]? {

    var isDir: ObjCBool = true
    guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir) else {
      return nil
    }

    // If it is a file.
    if !isDir.boolValue {
      // If it is a package file.
      if lastPathComponent == "Package.swift" {
      // Otherwise it is an invalid file.
      } else {
        return nil
      }
      // Depth > 0 means look inside the directory
    } else {
      let packageFileURL = self.appendingPathComponent("Package.swift")
      if FileManager.default.fileExists(atPath: packageFileURL.path)  {
        return [packageFileURL]
      } else if depth > 0 {
        var packageFiles = [URL]()

        for subDirectory in subDirectories {
          if let packageURL = subDirectory.packageFiles(depth: depth - 1), !packageURL.isEmpty {
            packageFiles.append(contentsOf: packageURL)
          }
        }
        return packageFiles
      }
    }
    return []
  }

  private var subDirectories: [URL] {
    do {
      return try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter(\.hasDirectoryPath)
    } catch {
      return []
    }
  }
//
//  private func subdirectories() -> [URL] {
//    guard let  else {
//      return []
//    }
//
//
//
//    return packageFiles
//  }
}
