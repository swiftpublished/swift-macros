import SwiftSyntax

extension ExprSyntax {
    var inferredType: TypeSyntax? {
        switch kind {
        case .booleanLiteralExpr:
            return TypeSyntax(stringLiteral: "Bool")
        case .integerLiteralExpr:
            return TypeSyntax(stringLiteral: "Int")
        case .floatLiteralExpr:
            return TypeSyntax(stringLiteral: "Double")
        case .stringLiteralExpr:
            return TypeSyntax(stringLiteral: "String")
        case .arrayExpr:
            if let elementSyntax = self.as(ArrayExprSyntax.self)?.elements.first,
               let type = elementSyntax.expression.inferredType {
                return TypeSyntax(stringLiteral: "[\(type)]")
            } else {
                return nil
            }
        default:
            // TODO: Handle other cases
            #warning("Failed to get Type from the ExprSyntax")
            return nil
        }
    }
}
