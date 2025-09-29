import Foundation

#if os(Windows)
/// Windows 平台的目录枚举器修复实现
fileprivate final class WindowsDirectoryEnumerator: FileManager.DirectoryEnumerator {
    private let baseEnumerator: FileManager.DirectoryEnumerator
    private var skipPaths: Set<String> = []
    private var lastReturnedURL: URL?
    
    fileprivate init(wrapping enumerator: FileManager.DirectoryEnumerator) {
        self.baseEnumerator = enumerator
        super.init()
    }
    
    override func nextObject() -> Any? {
        while let file = baseEnumerator.nextObject() as? URL {
            let filePath = file.path
            
            let shouldSkip = skipPaths.contains { skipPath in
                filePath.hasPrefix(skipPath + "/") || filePath == skipPath
            }
            
            if shouldSkip {
                continue
            }
            
            lastReturnedURL = file
            return file
        }
        return nil
    }
    
    override func skipDescendants() {
        if let url = lastReturnedURL {
            skipPaths.insert(url.path)
        }
    }
    
    override var level: Int {
        return baseEnumerator.level
    }
}
#endif

extension FileManager {
    /// 修复 Windows 平台 skipDescendants() bug 的目录枚举器
    /// 在 Windows 平台提供修复版本，其他平台保持原生行为
    /// 
    /// - Parameters:
    ///   - url: 要枚举的目录 URL
    ///   - keys: 要预取的资源键数组
    ///   - mask: 目录枚举选项
    /// - Returns: 目录枚举器，如果目录无法访问则返回 nil
    /// 
    /// - Note: 此方法修复了 Windows 平台上 skipDescendants() 可能影响
    ///         同级目录枚举的问题，其他平台保持标准行为
    public func enumerator2(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]? = nil,
        options mask: FileManager.DirectoryEnumerationOptions = []
    ) -> DirectoryEnumerator? {
        // 使用系统的 FileManager 创建枚举器
        guard let baseEnumerator = self.enumerator(
            at: url,
            includingPropertiesForKeys: keys,
            options: mask,
            errorHandler: nil
        ) else {
            return nil
        }
        
        #if os(Windows)
        // Windows 平台返回修复版本
        return WindowsDirectoryEnumerator(wrapping: baseEnumerator)
        #else
        // 其他平台返回原始实现
        return baseEnumerator
        #endif
    }
}
