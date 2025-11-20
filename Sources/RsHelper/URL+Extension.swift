import Foundation

public extension URL {
    /// The size of the file URL. -1 when failed to obtain.
    var fileSize: Int {
        let rv = try? resourceValues(forKeys: [.fileSizeKey])
        return rv?.fileSize ?? -1
    }
    
    /// Get the URL of a child file in a directory
    /// 
    /// The URL self should be a directory.
    /// 
    /// - Parameter child: The file name of the child file in the directory.
    /// - Returns: Child URL, or nil if can't find it in the directory.
    func reachableChild(named child: String) -> URL? {
        guard self.hasDirectoryPath else { return nil }

        let url = self.appending(component: child)
        return ((try? url.checkResourceIsReachable()) ?? false) ? url : nil
    }
    
    /// Get the URL of a sibling file in same directory
    /// 
    /// - Parameter sibling: The file name of sibling file in the same directory.
    /// - Returns: Sibling URL, or nil if can't find it in the same directory.
    func reachableSibling(named sibling: String) -> URL? {
        guard self.hasDirectoryPath == false else { return nil }
        
        let url = self.deletingLastPathComponent().appending(component: sibling)
        return ((try? url.checkResourceIsReachable()) ?? false) ? url : nil
    }

#if os(Windows)
    /// Stadard directory as macOS
    static var applicationSupportDirectory: URL {
         guard let appSupportDir = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            fatalError("Can't find applicationSupportDirectory with FileManager")
        }
        
        return appSupportDir
    }
#endif
}