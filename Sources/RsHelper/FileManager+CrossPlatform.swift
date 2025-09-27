import Foundation

extension FileManager {
    /// 跨平台安全的目录枚举方法
    /// 自动处理 Windows 平台的 skipDescendants() bug
    public func crossPlatformEnumerator(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]? = nil,
        options mask: DirectoryEnumerationOptions = []
    ) -> CrossPlatformDirectoryEnumerator? {
        guard let enumerator = self.enumerator(at: url, includingPropertiesForKeys: keys, options: mask) else {
            return nil
        }
        return CrossPlatformDirectoryEnumerator(baseEnumerator: enumerator)
    }
}
