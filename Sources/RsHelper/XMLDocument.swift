import Foundation
#if os(macOS)
#else
import FoundationXML
#endif

public extension XMLDocument {
    /// Depth first traverse all elements of the XML document.
    /// 
    /// Only call the clousure with elements with attributes.
    /// 
    /// - Parameters:
    ///   - root: Start element, default nil for the root element.
    ///   - body: The callback clousure.
    func forEachElement(from root: XMLElement? = nil,
                        _ body: (_ parent: String, _ name: String, _ attribute: String, _ value: String) -> Void) {
        guard let parent = root ?? rootElement() else { return }
        
        let pname = parent.name ?? ""
        
        parent.children?.forEach { node in
            if node.kind == .element,
               let element = node as? XMLElement,
               let ename = element.name {
                element.attributes?.forEach { attr in
                    if let aname = attr.name,
                       let aval = attr.stringValue {
                        body(pname, ename, aname, aval)
                    }
                }
                forEachElement(from: element, body)
            }
        }
    }
}