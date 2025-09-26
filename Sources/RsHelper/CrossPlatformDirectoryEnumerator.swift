import Foundation

/// 跨平台目录枚举器，修复 Windows 平台 skipDescendants() 的 bug
public class CrossPlatformDirectoryEnumerator: Sequence, IteratorProtocol {
    private let baseEnumerator: FileManager.DirectoryEnumerator
    
    #if os(Windows)
    private var skipPaths: Set<String> = []
    #endif
    
    public init(baseEnumerator: FileManager.DirectoryEnumerator) {
        self.baseEnumerator = baseEnumerator
    }
    
    public func next() -> URL? {
        #if os(Windows)
        // Windows 平台使用修复后的逻辑
        while let file = baseEnumerator.nextObject() as? URL {
            let filePath = file.path
            
            let shouldSkip = skipPaths.contains { skipPath in
                filePath.hasPrefix(skipPath + "/") || filePath == skipPath
            }
            
            if shouldSkip {
                continue
            }
            
            return file
        }
        return nil
        #else
        // macOS/Linux 使用原生实现
        return baseEnumerator.nextObject() as? URL
        #endif
    }
    
    /// 跨平台安全的跳过后代方法
    public func skipDescendants(of url: URL) {
        #if os(Windows)
        // Windows 平台使用路径跟踪
        skipPaths.insert(url.path)
        #else
        // 其他平台使用原生方法
        baseEnumerator.skipDescendants()
        #endif
    }
}
