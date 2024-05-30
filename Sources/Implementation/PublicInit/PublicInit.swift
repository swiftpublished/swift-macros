import SwiftSyntaxMacros
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftDiagnostics

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

            guard !variable.isLetWithDefaultValue else {
                return nil
            }

            guard variable.isStoredProperty else {
                return nil
            }

            return variable
        }

        guard !variables.isEmpty else {
            return ["public init() {}"]
        }

        let variableNames = variables.compactMap { variable in
            variable.bindings.first?.pattern
        }

        var diagnostic: Diagnostic?
        let variableTypesAndDefaultValues = variables
            .compactMap { variable -> (type: TypeSyntax, defaultValue: InitializerClauseSyntax?)? in
                guard let bindings = variable.bindings.first else {
                    return nil
                }

                if let definedType = bindings.typeAnnotation?.type {
                    return (type: definedType, defaultValue: bindings.initializer)
                } else {
                    if let inferredType = bindings.initializer?.value.inferredType {
                        return (inferredType, defaultValue: bindings.initializer)
                    } else {
                        diagnostic = PublicInitDiagnostic.notInferableType
                            .diagnostic(for: bindings.pattern)
                        return nil
                    }
                }
            }

        guard diagnostic == nil else {
            context.diagnose(diagnostic!)
            return []
        }

        let argumentsList = zip(variableNames, variableTypesAndDefaultValues)
            .map { variableName, variableTypeAndDefaultValue in
                let (variableType, defaultInitializer) = variableTypeAndDefaultValue
                return [
                    "\(variableName.trimmedDescription):",
                    variableType.trimmedDescription,
                    defaultInitializer?.trimmedDescription
                ]
                    .compactMap { $0 }
                    .joined(separator: " ")
            }
            .joined(separator: ",\n")
        let initHeader = "public init(\n" + argumentsList + "\n)"
        let header = SyntaxNodeString(stringLiteral: initHeader)

        let initializer = try InitializerDeclSyntax(header) {
            for name in variableNames {
                ExprSyntax("self.\(raw: name.trimmedDescription) = \(raw: name.trimmedDescription)")
            }
        }

        return [
            DeclSyntax(initializer)
        ]
    }
}
