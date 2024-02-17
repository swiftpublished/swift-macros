import XCTest
import SwiftSyntaxMacrosTestSupport
@testable import SwiftMacrosImplementation

final class PublicInitTests: XCTestCase {
    private let macros = ["PublicInit": PublicInit.self]

    func testEmpty() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct State {
            }
            """,
            expandedSource:
            """
            public struct State {
            }
            """,
            macros: macros
        )
    }

    func testBasicClass() {
        assertMacroExpansion(
            """
            @PublicInit
            public class Client {
                public let id: Int
            }
            """,
            expandedSource:
            """
            public class Client {
                public let id: Int

                public init(
                    id: Int
                ) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }

    func testBasicStruct() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct State {
                public let id: Int
            }
            """,
            expandedSource:
            """
            public struct State {
                public let id: Int

                public init(
                    id: Int
                ) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }

    func testMultipleProperties() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct State {
                public let id: Int
                public let name: String
            }
            """,
            expandedSource:
            """
            public struct State {
                public let id: Int
                public let name: String

                public init(
                    id: Int,
                    name: String
                ) {
                    self.id = id
                    self.name = name
                }
            }
            """,
            macros: macros
        )
    }

    func testComputedProperty() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct State {
                public let id: Int

                public var isTrue: Bool {
                    return true
                }
            }
            """,
            expandedSource:
            """
            public struct State {
                public let id: Int

                public var isTrue: Bool {
                    return true
                }

                public init(
                    id: Int
                ) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }

    func testStaticProperty() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct State {
                public let id: Int

                public static var isTrue: Bool {
                    return true
                }
            }
            """,
            expandedSource:
            """
            public struct State {
                public let id: Int

                public static var isTrue: Bool {
                    return true
                }

                public init(
                    id: Int
                ) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }
}
