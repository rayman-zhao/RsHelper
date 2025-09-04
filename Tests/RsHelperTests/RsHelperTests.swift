import Foundation
import Testing
@testable import RsHelper

@Test
func bundle() async throws {
    #expect(Bundle.module.path(forResource: "test.txt") != nil)
    #expect(Bundle.module.path(forResource: "test2.txt") == nil)
}
