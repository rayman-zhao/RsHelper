import Foundation

public extension Data {
    /// Append bytes of an integer to the data.
    /// 
    /// - Parameter value: The integer will be appended
    mutating func append(_ value: Int) {
        append(Swift.withUnsafeBytes(of: value) { Data($0) })
    }
    
    /// Append bytes of a C-string to the data.
    /// 
    /// The end of the C-string NULL (\0) will be appended.
    /// 
    /// - Parameter cString: The C-string will be appended.
    mutating func append(_ cString: UnsafePointer<CChar>) {
        let length = strlen(cString) + 1 // Include end \0
        cString.withMemoryRebound(to: UInt8.self, capacity: length) {
            append($0, count: length)
        }
    }
}