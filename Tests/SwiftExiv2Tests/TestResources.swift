import Foundation
import Testing

extension Tag {
    @Tag static var reading: Self
    @Tag static var writing: Self
}

struct TestResources {
    // contains no EXIF data
    static let test1ImageURL: URL! = Bundle.module.url(forResource: "test1",
                                                       withExtension: "jpg",
                                                       subdirectory: "Test Assets")

    // contains fill set of EXIF data
    static let test2ImageURL: URL! = Bundle.module.url(forResource: "test2",
                                                       withExtension: "jpg",
                                                       subdirectory: "Test Assets")
}

final class TemporaryDirectory {
    private var directory: URL

    init?() {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do { try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true) }
        catch { return nil }
    }

    deinit {
        try? FileManager.default.removeItem(at: directory)
    }

    func copiedResource(_ sourceURL: URL) -> URL? {
        let destURL = directory.appendingPathComponent(sourceURL.lastPathComponent)
        do { try FileManager.default.copyItem(at: sourceURL, to: destURL) }
        catch { return nil }
        return destURL
    }
}
