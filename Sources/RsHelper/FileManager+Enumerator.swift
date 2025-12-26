import Foundation

#if os(Windows)
/// Windows 平台的目录枚举器修复实现
/// 使用 fileprivate 确保只在当前文件内可见
fileprivate final class WindowsDirectoryEnumerator: FileManager.DirectoryEnumerator {
    private let baseEnumerator: FileManager.DirectoryEnumerator
    private var skipPaths: Set<String> = []
    private var lastReturnedURL: URL?
    private var lastSkipLevel: Int?
    
    fileprivate init(wrapping enumerator: FileManager.DirectoryEnumerator) {
        self.baseEnumerator = enumerator
        super.init()
    }
    
    override func nextObject() -> Any? {
        while let file = baseEnumerator.nextObject() as? URL {
            let filePath = file.path
            let currentLevel = baseEnumerator.level
            
            // 优化1：使用 level 来避免过深遍历
            // 如果我们跳过了某个层级，且当前层级更深，直接跳过
            if let skipLevel = lastSkipLevel, currentLevel > skipLevel {
                continue
            }
            
            // 优化2：当回到更浅层级时，清理 skipPaths 和重置 skipLevel
            if let skipLevel = lastSkipLevel, currentLevel <= skipLevel {
                lastSkipLevel = nil
                // 清理已经完成遍历的 skip 路径
                let currentComponents = filePath.split(separator: "/")
                skipPaths = skipPaths.filter { skipPath in
                    let skipComponents = skipPath.split(separator: "/")
                    // 保留那些不比当前路径深的 skip 路径
                    return skipComponents.count <= currentComponents.count
                }
            }
            
            // 检查是否在被跳过的路径下
            let separator = "/" // URL.path 在所有平台都使用正斜杠
            let shouldSkip = skipPaths.contains { skipPath in
                return filePath.hasPrefix(skipPath + separator) || filePath == skipPath
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
            // 记录跳过时的层级，用于后续优化
            lastSkipLevel = baseEnumerator.level
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
    ///
    /// ## Performance Optimizations
    /// - Uses level tracking to avoid unnecessary deep traversal
    /// - Cleans up skip paths when returning to shallower levels
    /// - Reduces memory usage by removing completed skip paths
    public func enumerator2(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]? = nil,
        options mask: FileManager.DirectoryEnumerationOptions = []
    ) -> DirectoryEnumerator? {
        guard let baseEnumerator = self.enumerator(
            at: url,
            includingPropertiesForKeys: keys,
            options: mask,
            errorHandler: nil
        ) else {
            return nil
        }
        
        #if os(Windows)
        return WindowsDirectoryEnumerator(wrapping: baseEnumerator)
        #else
        return baseEnumerator
        #endif
    }
}