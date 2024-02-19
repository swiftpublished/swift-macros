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
///         case firstName = "first_name"
///     }
/// }
/// ```
///
@CodingKeys
public struct CodableState: Codable {
    public let id: Int
    @CodingKey(name: "first_name")
    public let firstName: String
}
