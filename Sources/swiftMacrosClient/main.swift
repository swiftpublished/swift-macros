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
public struct State {
    public let id: Int
}
