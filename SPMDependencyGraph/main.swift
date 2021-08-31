//
//  main.swift
//  DependencyGraph
//
//  Created by Isaac Ressler on 8/30/21.
//

import Foundation

// Drop the first because it is the script path.
let arguments = CommandLine.arguments.dropFirst()

// Use strings because URLs aren't equal on the path.
var packagePaths = Set<String>()
let fileManager = FileManager.default

for argument in arguments {
  guard let url = URL(string: argument) else {
    print("Invalid path: \(argument)")
    continue
  }

  var isDir: ObjCBool = false
  guard fileManager.fileExists(atPath: argument, isDirectory: &isDir) else {
    print("File does not exist at: \(argument)")
    continue
  }

  if let packageFileURLs = url.packageFiles() {
    packagePaths.insert(contentsOf: packageFileURLs.map({ $0.path }))
  } else {
    print("Did not find any packages in \(argument)")
  }
}

print("Loading dependencies from \(packagePaths.count) package files...")

var projects = Set<Project>()

for packagePath in packagePaths.sorted() {
  guard let url = URL(string: "file://\(packagePath)") else {
    print("Unable to create file URL from (\(packagePath)). Something is really broken")
    continue
  }

  let package: String

  do {
    // Need to remove newlines because packages can have a variety of formatting, which makes parsing impossible.
    package = try String(contentsOf: url).replacingOccurrences(of: "\n", with: " ")
  } catch {
    print("Error reading package at \(url): \(String(describing: error))")
    continue
  }

  guard let name = package.matches(for: "name: ?\"(.*?)\"")?.first else {
    print("Failed to get a name for: \(packagePath)")
    continue
  }

  let newProject = Project(name: name)

  // Very inefficient regex, however it works for every package I've tried.
  if let dependencyStrings = package.matches(for: "(?:\\.package\\((.*?)\\)+.*?)*"), !dependencyStrings.isEmpty {
    for dependencyString in dependencyStrings {
      let dependencyName: String
      if let dependencyNameString = dependencyString.matches(for: "name: ?\"([^\"]*)\"")?.first {
        dependencyName = dependencyNameString
      } else if let urlString = dependencyString.matches(for: "url: ?\"([^\"]*)\"")?.first {
        guard let url = URL(string: urlString) else {
          print("Failed to convert urlString into URL: \(urlString)")
          continue
        }
        dependencyName = url.deletingPathExtension().lastPathComponent
      } else {
        print("No name/url in: \(dependencyString)")
        continue
      }
      let matchingProject = projects.first(where: { project in
        project.nameMatches(dependencyName)
      })
      if let matchingProject = matchingProject {
        newProject.addDependency(matchingProject)
      } else {
        let dependentProject = Project(name: dependencyName)
        projects.insert(dependentProject)
        newProject.addDependency(dependentProject)
      }
    }
  }

  projects.insert(newProject)
}

//for project in projects {
//  print("\(project.name): \(project.totalDependencies)")
//}
print("The dependencies listed are all dependencies found, however some may not apply for the system and/or targets you are using.")
print("For example some projects may rely on build time variables or the target OS to determine what dependencies they need,")
print("or may have testing/target specific dependencies that aren't required for your build.")
print("")
print("It's also possible that a project has multiple dependent projects, so may be listed under multiple projects.")
print("")
print("Dependency results:")

// Filter to only include the "root" projects, e.g. projects that none of the other projects depend on.
let rootProjects = projects.filter({ $0.dependents.isEmpty }).sorted(by: { lhs, rhs in
  // Weird sorting because we want higher dependency counts first, then if the dependency counts match lower names first.
  if lhs.totalDependencies != rhs.totalDependencies {
    return lhs.totalDependencies > rhs.totalDependencies
  } else {
    return lhs.name < rhs.name
  }
})

// Track the projects with no dependencies so they can be output last.
var standaloneProjects = [Project]()

for project in rootProjects {
  // Output all of the projects with dependencies before the projects without dependencies.
  if project.dependencies.isEmpty {
    standaloneProjects.append(project)
  } else {
    print(String(describing: project) + "\n")
  }
}

// Output these last because they are "simple" and not part of a connected graph.
print("Standalone projects:\n")

for project in standaloneProjects {
  print(String(describing: project))
}

