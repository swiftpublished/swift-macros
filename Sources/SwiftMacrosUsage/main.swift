import SwiftMacrosInterface

/// Xcode Error:
/// Diagnostic: '@PublicInit' can only be applied to a Struct or Class
/// FixIt: Remove '@PublicInit'
///     Action: Removes '@PublicInit'
///
//@PublicInit
//enum Direction {
//    case north
//    case south
//}

/// Expands to:
///
/// ```
/// public init(
///     id: Int
/// ) {
///     self.id = id
/// }
/// ```
///
@PublicInit
public struct InitializableState {
    public let id: Int
}

/// Expands to:
///
/// ```
/// public struct CodableState: Codable {
///     public let id: Int
///     public let firstName: String
///
///     enum CodingKeys: String, CodingKey {
///         case id
///         case firstName
///     }
/// }
/// ```
///
@CodingKeys
public struct CodableState: Codable {
    public let id: Int
    public let firstName: String
}

/// Expands to:
///
/// ```
/// public struct CodableStateDefault: Codable {
///     public let id: Int
///     public let firstName: String
///
///     enum CodingKeys: String, CodingKey {
///         case id
///         case firstName
///     }
/// }
/// ```
///
@CodingKeys(using: .default)
public struct CodableStateDefault: Codable {
    public let id: Int
    public let firstName: String
}

/// Expands to:
///
/// ```
/// public struct CodableStateSnake_Case: Codable {
///     public let id: Int
///     public let firstName: String
///
///     enum CodingKeys: String, CodingKey {
///         case id
///         case firstName = "first_name"
///     }
/// }
/// ```
///
@CodingKeys(using: .snake_case)
public struct CodableStateSnake_Case: Codable {
    public let id: Int
    public let firstName: String
}

/// Expands to:
///
/// ```
/// public struct CodableStateSnake_CaseAndExplicitCodingKey: Codable {
///     public let id: Int
///     public let firstName: String
///     public let lastName: String
///
///     enum CodingKeys: String, CodingKey {
///         case id
///         case firstName = "first_name"
///         case lastName = "some last name"
///     }
/// }
/// ```
///
@CodingKeys(using: .snake_case)
public struct CodableStateSnake_CaseAndExplicitCodingKey: Codable {
    public let id: Int
    public let firstName: String

    @CodingKey(name: "some last name")
    public let lastName: String
}
