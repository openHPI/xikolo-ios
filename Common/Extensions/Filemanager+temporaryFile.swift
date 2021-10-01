//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

// Source: https://oleb.net/blog/2018/03/temp-file-helper/
extension FileManager {
    /// Creates a temporary directory with a unique name and returns its URL.
    ///
    /// - Returns: A tuple of the directory's URL and a delete function.
    ///   Call the function to delete the directory after you're done with it.
    ///
    /// - Note: You should not rely on the existence of the temporary directory
    ///   after the app is exited.
    func urlForUniqueTemporaryDirectory(preferredName: String? = nil) throws -> (url: URL, deleteDirectory: () throws -> Void) {
        let basename = preferredName ?? UUID().uuidString

        var counter = 0
        var createdSubdirectory: URL?

        repeat {
            do {
                let subdirName = counter == 0 ? basename : "\(basename)-\(counter)"
                let subdirectory = temporaryDirectory
                    .appendingPathComponent(subdirName, isDirectory: true)
                try createDirectory(at: subdirectory, withIntermediateDirectories: false)
                createdSubdirectory = subdirectory
            } catch CocoaError.fileWriteFileExists {
                // Catch file exists error and try again with another name.
                // Other errors propagate to the caller.
                counter += 1
            }
        } while createdSubdirectory == nil

        let directory = createdSubdirectory!
        let deleteDirectory: () throws -> Void = {
            try self.removeItem(at: directory)
        }

        return (directory, deleteDirectory)
    }
}

/// A wrapper around a temporary file in a temporary directory. The directory
/// has been especially created for the file, so it's safe to delete when you're
/// done working with the file.
///
/// Call `deleteDirectory` when you no longer need the file.
public struct TemporaryFile {
    public let directoryURL: URL
    public let fileURL: URL
    /// Deletes the temporary directory and all files in it.
    public let deleteDirectory: () throws -> Void

    /// Creates a temporary directory with a unique name and initializes the
    /// receiver with a `fileURL` representing a file named `filename` in that
    /// directory.
    ///
    /// - Note: This doesn't create the file!
    public init(creatingTempDirectoryForFilename filename: String) throws {
        let (directory, deleteDirectory) = try FileManager.default.urlForUniqueTemporaryDirectory()
        self.directoryURL = directory
        self.fileURL = directory.appendingPathComponent(filename.replacingOccurrences(of: "/", with: "-"))
        self.deleteDirectory = deleteDirectory
    }
}
