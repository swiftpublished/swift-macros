import SwiftSyntaxMacros
import SwiftSyntax
import SwiftSyntaxBuilder

public struct PublicInit: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard [.structDecl, .classDecl].contains(declaration.kind) else {
            let diagnostic = PublicInitDiagnostic.notApplicable.diagnostic(for: node)
            context.diagnose(diagnostic)
            return []
        }

        let members = declaration.memberBlock.members
        let variables: [VariableDeclSyntax] = members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self) else {
                return nil
            }

            guard variable.isStoredProperty else {
                return nil
            }

            return variable
        }

        guard !variables.isEmpty else {
            return []
        }

        let variableNames = variables.compactMap { $0.bindings.first?.pattern }
        let variableTypes = variables.compactMap { $0.bindings.first?.typeAnnotation?.type }

        let argumentsList = zip(variableNames, variableTypes)
            .map { variableName, variableType in "\(variableName): \(variableType)" }
            .joined(separator: ",\n")
        let initHeader = "public init(\n" + argumentsList + "\n)"
        let header = SyntaxNodeString(stringLiteral: initHeader)

        let initializer = try InitializerDeclSyntax(header) {
            for name in variableNames {
                ExprSyntax("self.\(name) = \(name)")
            }
        }

        return [
            DeclSyntax(initializer)
        ]
    }
}
