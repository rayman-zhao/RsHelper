import Foundation
import Testing
import RsHelper
#if os(macOS)
#else
import FoundationXML
#endif

@Test
func bundle() async throws {
    #expect(Bundle.module.path(forResource: "test.txt") != nil)
    #expect(Bundle.module.path(forResource: "testx.txt") == nil)
}

@Test
func data() async throws {
    var d = Data()
    #expect(d.count == 0)
    
    d.append(0)
    #expect(d.count == 8)
    #expect(d.hashUUID == UUID(uuidString: "7DEA362B-3FAC-5E00-956A-4952A3D4F474"))
    
    d.append("Hello World".cString(using: .utf8)!)
    #expect(d.count == 8 + 12)
    #expect(d.last == 0)
}

@Test(arguments: [
    ("lena.jpg", true),
    ("lena.png", false),
    ("test.txt", false),
])
func dataTypes(_ fn: String, _ img: Bool) async throws {
    let url = URL(filePath: try #require(Bundle.module.path(forResource: fn)))
    let d = try Data(contentsOf: url)
    #expect(d.isImage == img)
}

@Test
func logger() async throws {
    log.error("Hello World")
}

@Test
func url() async throws {
    let test_txt = Bundle.module.path(forResource: "test.txt")!
    let url = URL(filePath: test_txt)
    #expect(url.fileSize == 0)
    #expect(url.reachableSibling(named: "test2.txt") != nil)
    #expect(url.reachableSibling(named: "test2.txt")?.fileSize == 0)

    let url2 = Bundle.module.resourceURL?.reachableChild(named: "test2.txt")
    #expect(url2 != nil)
}

@Test
func xml() async throws {
    // let xml = try XMLDocument(xmlString:
    // """
    // <?xml version="1.0" encoding="UTF-8"?>
    // <books>
    // <book id="1001">
    // <name>The Great Gatsby</name>
    // <author>F. Scott Fitzgerald</author>
    // <price>10.99</price>
    // </book>
    // <book id="1002">
    // <name>To Kill a Mockingbird</name>
    // <author>Harper Lee</author>
    // <price>7.99</price>
    // </book>
    // </books>
    // """)
    let data = try Data(contentsOf: URL(filePath: Bundle.module.path(forResource: "utf16le.txt")!))
    let xml = try XMLDocument(utf16Data: data, options: .documentTidyXML)
    var cnt = 0

    xml.forEachElement { parent, name, attribute, value in
        print("parent: \(parent)")
        print("name: \(name)")
        print("attribute: \(attribute)")
        print("value: \(value)")

        cnt += 1
    }

    #expect(cnt == 2)

    #expect(throws: Error.self) {
        _ = try XMLDocument(utf16Data: Data())
    }
}