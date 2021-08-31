# SPMDependencyGraph
Command Line Tool to help visualize your Swift Package Manager dependencies.

## Usage

SPMDependencyGraph takes 1 or more paths that it can use to load package.swift files. The paths can be any combination of these types:
- Package.swift files.
- Directory of a project containing a Package.swift file.
  - This enables supplying the paths to the projects instead of their Package.swift files.
- Directory of projects containing Package.swift files.
  - This enables supplying either a path to a group of projects used directly, or to a SPM cache directory that contains all dependencies.

### Example usage
```zsh
  SPMDependencyGraph /some/path/Package.swift /some/other/path/Package.swift
  SPMDependencyGraph /some/directory/path/
```

## Installing/running
The tool can be run directly from Xcode by supplying arguments in the scheme's Run -> Arguments options.
You can also build the project than take the built product and move it somewhere in your `$PATH`.
