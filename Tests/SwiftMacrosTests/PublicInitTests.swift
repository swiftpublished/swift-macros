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

                public init() {
                }
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

    ///
    /// - Note
    /// Use `main` branch of `swift-syntax` in the `Package.swift` dependency
    ///
    func testEnum() {
        assertMacroExpansion(
            """
            @PublicInit
            public enum Action {
                case increment
            }
            """,
            expandedSource:
            """
            public enum Action {
                case increment
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "'@PublicInit' can only be applied to a Struct or Class",
                    line: 1,
                    column: 1,
                    severity: .error,
                    fixIts: [
                        FixItSpec(message: "Remove '@PublicInit'")
                    ]
                )
            ],
            macros: macros,
            applyFixIts: ["Remove '@PublicInit'"],
            fixedSource:
            """

            public enum Action {
                case increment
            }
            """
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

    func test_default_value_let() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct State {
                public let id: Int = 1
            }
            """,
            expandedSource:
            """
            public struct State {
                public let id: Int = 1

                public init() {
                }
            }
            """,
            macros: macros
        )
    }

    func test_default_value_without_variable_type() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct State {
                public let id = 1
            }
            """,
            expandedSource:
            """
            public struct State {
                public let id = 1

                public init() {
                }
            }
            """,
            macros: macros
        )
    }

    func test_default_value_var() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct State {
                public var id: Int = 1
            }
            """,
            expandedSource:
            """
            public struct State {
                public var id: Int = 1

                public init(
                    id: Int = 1
                ) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }

    func test_default_value_var_optional_type_with_some_value() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct State {
                public var id: Int? = 1
            }
            """,
            expandedSource:
            """
            public struct State {
                public var id: Int? = 1

                public init(
                    id: Int? = 1
                ) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }

    func test_default_value_var_optional_type_with_nil() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct State {
                public var id: Int? = nil
            }
            """,
            expandedSource:
            """
            public struct State {
                public var id: Int? = nil

                public init(
                    id: Int? = nil
                ) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }

    func test_default_value_var_optional_type_with_nil_for_custom_type() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct State {
                public var id: SomeType? = nil
            }
            """,
            expandedSource:
            """
            public struct State {
                public var id: SomeType? = nil

                public init(
                    id: SomeType? = nil
                ) {
                    self.id = id
                }
            }
            """,
            macros: macros
        )
    }

    ///
    /// - Note
    /// Use `main` branch of `swift-syntax` in the `Package.swift` dependency
    ///
    func test_failed_to_infer_type() {
        assertMacroExpansion(
            """
            @PublicInit
            public struct State {
                public var id = "1"
            }
            """,
            expandedSource:
            """
            public struct State {
                public var id = "1"
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Failed to infer the Type",
                    line: 3,
                    column: 16,
                    severity: .error,
                    fixIts: [
                        FixItSpec(message: "Specify Type instead")
                    ]
                )
            ],
            macros: macros,
            applyFixIts: ["Specify Type instead"],
            fixedSource:
            """
            @PublicInit
            public struct State {
                public var id: <#Type#> = "1"
            }
            """
        )
    }
}
