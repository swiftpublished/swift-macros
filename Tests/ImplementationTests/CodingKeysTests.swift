import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
@testable import SwiftMacrosImplementation

final class CodingKeysTests: XCTestCase {
    private let macros: [String: Macro.Type] = [
        "CodingKeys": CodingKeys.self,
        "CodingKey": CodingKey.self
    ]

    func testWithoutStrategy() {
        assertMacroExpansion(
            """
            @CodingKeys
            public struct State: Codable {
                public let id: String
                public let firstName: String
            }
            """,
            expandedSource:
            """
            public struct State: Codable {
                public let id: String
                public let firstName: String

                enum CodingKeys: String, CodingKey {
                    case id
                    case firstName
                }
            }
            """,
            macros: macros
        )
    }

    func testWithDefaultStrategy() {
        assertMacroExpansion(
            """
            @CodingKeys(using: .default)
            public struct State: Codable {
                public let id: String
                public let firstName: String
            }
            """,
            expandedSource:
            """
            public struct State: Codable {
                public let id: String
                public let firstName: String

                enum CodingKeys: String, CodingKey {
                    case id
                    case firstName
                }
            }
            """,
            macros: macros
        )
    }

    func testWithSnake_CaseStrategy() {
        assertMacroExpansion(
            """
            @CodingKeys(using: .snake_case)
            public struct State: Codable {
                public let id: String
                public let firstName: String
            }
            """,
            expandedSource:
            """
            public struct State: Codable {
                public let id: String
                public let firstName: String

                enum CodingKeys: String, CodingKey {
                    case id
                    case firstName = "first_name"
                }
            }
            """,
            macros: macros
        )
    }

    func testWithSnake_CaseStrategyAndExplicitCodingKey() {
        assertMacroExpansion(
            """
            @CodingKeys(using: .snake_case)
            public struct State: Codable {
                public let id: String
                public let firstName: String

                @CodingKey(name: "some last name")
                public let lastName: String
            }
            """,
            expandedSource:
            """
            public struct State: Codable {
                public let id: String
                public let firstName: String
                public let lastName: String

                enum CodingKeys: String, CodingKey {
                    case id
                    case firstName = "first_name"
                    case lastName = "some last name"
                }
            }
            """,
            macros: macros
        )
    }
}
