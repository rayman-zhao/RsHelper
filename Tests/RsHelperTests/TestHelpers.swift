import Foundation

/// 测试目录管理工具
struct TestDirectory {
    let url: URL
    
    /// 创建临时测试目录
    /// - Parameter named: 测试目录的名称标识
    init(named: String) throws {
        self.url = FileManager.default.temporaryDirectory
            .appendingPathComponent("RsHelperTest_\(named)_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    /// 创建子目录
    /// - Parameter path: 相对于测试目录的路径，可以包含多级（如 "sub/deep"）
    /// - Returns: 创建的子目录 URL
    @discardableResult
    func createSubdirectory(_ path: String) throws -> URL {
        let subdir = url.appendingPathComponent(path)
        try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: true)
        return subdir
    }
    
    /// 创建文件
    /// - Parameters:
    ///   - path: 相对于测试目录的文件路径
    ///   - content: 文件内容
    /// - Returns: 创建的文件 URL
    @discardableResult
    func createFile(_ path: String, content: String = "test content") throws -> URL {
        let file = url.appendingPathComponent(path)
        // 确保父目录存在
        let parentDir = file.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentDir.path) {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }
        try content.write(to: file, atomically: true, encoding: .utf8)
        return file
    }
    
    /// 清理测试目录
    func cleanup() {
        try? FileManager.default.removeItem(at: url)
    }
}

/// 测试目录构建器，提供流式 API
struct TestDirectoryBuilder {
    let testDir: TestDirectory
    
    init(named: String) throws {
        self.testDir = try TestDirectory(named: named)
    }
    
    @discardableResult
    func withSubdirectory(_ path: String) throws -> Self {
        try testDir.createSubdirectory(path)
        return self
    }
    
    @discardableResult
    func withFile(_ path: String, content: String = "test content") throws -> Self {
        try testDir.createFile(path, content: content)
        return self
    }
    
    func build() -> TestDirectory {
        return testDir
    }
}