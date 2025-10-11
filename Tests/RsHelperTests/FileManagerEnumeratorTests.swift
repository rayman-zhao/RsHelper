import Testing
import Foundation
@testable import RsHelper

@Suite
struct FileManagerEnumeratorTests {
    
    /// 测试基本的 skipDescendants 功能
    /// 验证跳过一个目录后，同级目录仍能正常遍历
    @Test
    func testSkipDescendants() throws {
        let testDir = try TestDirectoryBuilder(named: "BasicSkip")
            .withSubdirectory("folder1/subfolder")
            .withSubdirectory("folder2")
            .withFile("folder1/file1.txt", content: "content1")
            .withFile("folder1/subfolder/file2.txt", content: "content2")
            .withFile("folder2/file3.txt", content: "content3")
            .withFile("file4.txt", content: "content4")
            .build()
        
        defer { testDir.cleanup() }
        
        guard let enumerator = FileManager.default.enumerator2(
            at: testDir.url,
            includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            Issue.record("Failed to create enumerator")
            return
        }
        
        var foundFiles: [String] = []
        
        while let fileURL = enumerator.nextObject() as? URL {
            let fileName = fileURL.lastPathComponent
            foundFiles.append(fileName)
            
            // 当遇到 folder1 时跳过其子目录
            if fileName == "folder1" {
                enumerator.skipDescendants()
            }
        }
        
        // 验证结果
        #expect(foundFiles.contains("folder1"))
        #expect(foundFiles.contains("folder2"))
        #expect(foundFiles.contains("file3.txt")) // folder2 中的文件应该被找到
        #expect(foundFiles.contains("file4.txt"))
        
        // 这些不应该被找到（因为 folder1 被跳过了）
        #expect(!foundFiles.contains("file1.txt"))
        #expect(!foundFiles.contains("subfolder"))
        #expect(!foundFiles.contains("file2.txt"))
        
        print("✓ Basic skip test - Found files: \(foundFiles)")
    }
    
    /// 测试多次调用 skipDescendants
    /// 验证可以跳过多个不同的目录
    @Test
    func testMultipleSkipDescendants() throws {
        let testDir = try TestDirectoryBuilder(named: "MultipleSkip")
            .withSubdirectory("skip1")
            .withSubdirectory("keep1")
            .withSubdirectory("skip2")
            .withSubdirectory("keep2")
            .withFile("skip1/file1.txt", content: "content1")
            .withFile("keep1/file2.txt", content: "content2")
            .withFile("skip2/file3.txt", content: "content3")
            .withFile("keep2/file4.txt", content: "content4")
            .build()
        
        defer { testDir.cleanup() }
        
        guard let enumerator = FileManager.default.enumerator2(
            at: testDir.url,
            includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            Issue.record("Failed to create enumerator")
            return
        }
        
        var foundFiles: [String] = []
        
        while let fileURL = enumerator.nextObject() as? URL {
            let fileName = fileURL.lastPathComponent
            foundFiles.append(fileName)
            
            // 跳过 skip1 和 skip2
            if fileName == "skip1" || fileName == "skip2" {
                enumerator.skipDescendants()
            }
        }
        
        // 应该找到 keep 文件夹中的内容
        #expect(foundFiles.contains("keep1"))
        #expect(foundFiles.contains("keep2"))
        #expect(foundFiles.contains("file2.txt"))
        #expect(foundFiles.contains("file4.txt"))
        
        // 不应该找到 skip 文件夹中的内容
        #expect(!foundFiles.contains("file1.txt"))
        #expect(!foundFiles.contains("file3.txt"))
        
        print("✓ Multiple skip test - Found files: \(foundFiles)")
    }
    
    /// 测试深层嵌套结构的跳过
    /// 验证在中间层级跳过后，不会影响同级的其他内容
    @Test
    func testDeepNestedSkip() throws {
        let testDir = try TestDirectoryBuilder(named: "DeepNested")
            .withSubdirectory("level1/level2/level3")
            .withFile("level1/level2/level3/deep.txt", content: "deep")
            .withFile("level1/sibling.txt", content: "sibling")
            .withFile("level1/level2/middle.txt", content: "middle")
            .build()
        
        defer { testDir.cleanup() }
        
        guard let enumerator = FileManager.default.enumerator2(
            at: testDir.url,
            includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            Issue.record("Failed to create enumerator")
            return
        }
        
        var foundFiles: [String] = []
        
        while let fileURL = enumerator.nextObject() as? URL {
            let fileName = fileURL.lastPathComponent
            foundFiles.append(fileName)
            
            // 在 level2 处跳过
            if fileName == "level2" {
                enumerator.skipDescendants()
            }
        }
        
        // level3、deep.txt 和 middle.txt 不应该被找到
        #expect(!foundFiles.contains("level3"))
        #expect(!foundFiles.contains("deep.txt"))
        #expect(!foundFiles.contains("middle.txt"))
        
        // sibling.txt 应该被找到（同级内容）
        #expect(foundFiles.contains("level1"))
        #expect(foundFiles.contains("sibling.txt"))
        
        print("✓ Deep nested test - Found files: \(foundFiles)")
    }
    
    /// 测试空目录的处理
    /// 验证空目录不会影响枚举器的正常工作
    @Test
    func testEmptyDirectories() throws {
        let testDir = try TestDirectoryBuilder(named: "EmptyDirs")
            .withSubdirectory("empty1")
            .withSubdirectory("empty2")
            .withSubdirectory("withContent")
            .withFile("withContent/file.txt", content: "content")
            .withFile("root.txt", content: "root")
            .build()
        
        defer { testDir.cleanup() }
        
        guard let enumerator = FileManager.default.enumerator2(
            at: testDir.url,
            includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            Issue.record("Failed to create enumerator")
            return
        }
        
        var foundFiles: [String] = []
        
        while let fileURL = enumerator.nextObject() as? URL {
            let fileName = fileURL.lastPathComponent
            foundFiles.append(fileName)
            
            // 跳过第一个空目录
            if fileName == "empty1" {
                enumerator.skipDescendants()
            }
        }
        
        // 所有目录都应该被找到
        #expect(foundFiles.contains("empty1"))
        #expect(foundFiles.contains("empty2"))
        #expect(foundFiles.contains("withContent"))
        
        // withContent 中的文件应该被找到
        #expect(foundFiles.contains("file.txt"))
        #expect(foundFiles.contains("root.txt"))
        
        print("✓ Empty directories test - Found files: \(foundFiles)")
    }
    
    /// 测试边界情况：根目录只有文件
    /// 验证没有子目录时枚举器仍能正常工作
    @Test
    func testRootLevelFilesOnly() throws {
        let testDir = try TestDirectoryBuilder(named: "RootFilesOnly")
            .withFile("file1.txt", content: "file1")
            .withFile("file2.txt", content: "file2")
            .withFile("file3.txt", content: "file3")
            .build()
        
        defer { testDir.cleanup() }
        
        guard let enumerator = FileManager.default.enumerator2(
            at: testDir.url,
            includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            Issue.record("Failed to create enumerator")
            return
        }
        
        var foundFiles: [String] = []
        
        while let fileURL = enumerator.nextObject() as? URL {
            foundFiles.append(fileURL.lastPathComponent)
        }
        
        #expect(foundFiles.count == 3)
        #expect(foundFiles.contains("file1.txt"))
        #expect(foundFiles.contains("file2.txt"))
        #expect(foundFiles.contains("file3.txt"))
        
        print("✓ Root files only test - Found files: \(foundFiles)")
    }
    
    /// 测试复杂混合场景
    /// 结合多层嵌套、多次跳过、空目录等情况
    @Test
    func testComplexMixedScenario() throws {
        let testDir = try TestDirectoryBuilder(named: "ComplexMix")
            .withSubdirectory("project/src/main")
            .withSubdirectory("project/src/test")
            .withSubdirectory("project/build")
            .withSubdirectory("project/docs")
            .withFile("project/src/main/app.swift", content: "main")
            .withFile("project/src/test/test.swift", content: "test")
            .withFile("project/build/output.exe", content: "binary")
            .withFile("project/docs/readme.md", content: "docs")
            .withFile("project/config.json", content: "config")
            .build()
        
        defer { testDir.cleanup() }
        
        guard let enumerator = FileManager.default.enumerator2(
            at: testDir.url,
            includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            Issue.record("Failed to create enumerator")
            return
        }
        
        var foundFiles: [String] = []
        
        while let fileURL = enumerator.nextObject() as? URL {
            let fileName = fileURL.lastPathComponent
            foundFiles.append(fileName)
            
            // 跳过 build 和 test 目录（模拟实际使用场景）
            if fileName == "build" || fileName == "test" {
                enumerator.skipDescendants()
            }
        }
        
        // 应该找到的内容
        #expect(foundFiles.contains("project"))
        #expect(foundFiles.contains("src"))
        #expect(foundFiles.contains("docs"))
        #expect(foundFiles.contains("config.json"))
        #expect(foundFiles.contains("readme.md"))
        #expect(foundFiles.contains("main"))
        #expect(foundFiles.contains("app.swift"))
        
        // 不应该找到的内容（被跳过）
        #expect(!foundFiles.contains("test.swift"))
        #expect(!foundFiles.contains("output.exe"))
        
        print("✓ Complex mixed scenario test - Found files: \(foundFiles)")
    }
}