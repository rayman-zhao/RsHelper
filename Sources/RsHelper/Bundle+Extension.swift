import Foundation
#if os(Windows)
import WinSDK

fileprivate func getVSFixedFileInfo(_ filename: String) -> String? {
    guard let block = getFileVersionInfo(filename) else { return nil }
    guard let value = verQueryValue(block, "\\") else { return nil }

    guard value.count >= MemoryLayout<VS_FIXEDFILEINFO>.size else { return nil }
    return value.withUnsafeBytes { rawBuffer in
        let fixedInfo = rawBuffer.load(as: VS_FIXEDFILEINFO.self)
        let major = Int((fixedInfo.dwFileVersionMS >> 16) & 0xffff)
        let minor = Int(fixedInfo.dwFileVersionMS & 0xffff)
        let build = Int((fixedInfo.dwFileVersionLS >> 16) & 0xffff)
        let revision = Int(fixedInfo.dwFileVersionLS & 0xffff)

        return "\(major).\(minor).\(build).\(revision)"
    }
}

fileprivate func verQueryValue(_ block: [UInt8], _ subBlock: String) -> [UInt8]? {
     var buffer: UnsafeMutableRawPointer? = nil
     var len: UINT = 0

     let ok = VerQueryValueW(block, subBlock.wideString, &buffer, &len)
     
     guard ok, let buffer else { return nil }
     return [UInt8](UnsafeRawBufferPointer(start: buffer, count: Int(len)))
}

fileprivate func getFileVersionInfo(_ filename: String) -> [UInt8]? {
    let size = getFileVersionInfoSize(filename)
    guard size > 0 else { return nil }

    var data = [UInt8](repeating: 0, count: Int(size))
    let ok = data.withUnsafeMutableBytes { rawBuffer in
        GetFileVersionInfoW(filename.wideString, 0, DWORD(size), rawBuffer.baseAddress)
    }

    guard ok else { return nil }
    return data
}

fileprivate func getFileVersionInfoSize(_ filename: String) -> Int {
    return Int(GetFileVersionInfoSizeW(filename.wideString, nil))
}
#endif

public extension Bundle {
    /// Get full path of a resource file.
    /// 
    /// When bundle resource files in SPM like:
    /// 
    /// resources: [
    /// .copy("Resources/"),
    /// ],
    /// 
    /// SPM and XCode will have different bundle structure on macOS and Windows. This function simplified condition check.
    /// 
    /// - Parameter fileName: A resource file name, like "test.txt"
    /// - Returns: Full file path
    func path(forResource fileName: String) -> String? {
        let url = URL(filePath: fileName)
        let ext = url.pathExtension
        let name = url.deletingPathExtension().lastPathComponent

        return self.path(forResource: name, ofType: ext) ?? // For SPM
               self.path(forResource: name, ofType: ext, inDirectory: "Resources") // For XCode
    }

    var executableVersion: String? {
        guard let executableURL = self.executableURL else { return nil }
        return getVSFixedFileInfo(executableURL.path)
    }
}
