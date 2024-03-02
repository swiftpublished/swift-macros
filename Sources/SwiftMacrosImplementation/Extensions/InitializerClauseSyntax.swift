import SwiftSyntax

extension InitializerClauseSyntax {
    var inferredType: TypeSyntax? {
        switch value.kind {
        case .integerLiteralExpr:
            return TypeSyntax(stringLiteral: "Int")
        default:
            // TODO: Handle other cases
            return nil
        }
    }
}
