import SwiftSyntax

extension VariableDeclSyntax {
    ///
    /// Determine whether this variable has the syntax of a stored property.
    ///
    /// This syntactic check cannot account for semantic adjustments due to,
    /// e.g., accessor macros or property wrappers.
    ///
    var isStoredProperty: Bool {
        if bindings.count != 1 {
            return false
        }

        let binding = bindings.first!
        switch binding.accessorBlock?.accessors {
        case .none:
            return true

        case .accessors(let accessors):
            for accessor in accessors {
                switch accessor.accessorSpecifier.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    // Observers can occur on a stored property.
                    break

                default:
                    // Other accessors make it a computed property.
                    return false
                }
            }

            return true

        case .getter:
            return false
        }
    }

    var isLetWithDefaultValue: Bool {
        bindingSpecifier.tokenKind == .keyword(.let) &&
        bindings.first?.initializer != nil
    }
}
