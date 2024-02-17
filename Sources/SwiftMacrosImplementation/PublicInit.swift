import Foundation
import SwiftSyntaxMacros
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftDiagnostics

public struct PublicInit: MemberMacro {
    enum DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
        case notAStructOrClass

        var message: String {
            return "'@PublicInit' can only be applied to a Struct or Class"
        }

        var diagnosticID: MessageID { .init(domain: "SwiftMacrosImplementation", id: message) }
        var severity: DiagnosticSeverity { .error }
    }

    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.as(StructDeclSyntax.self) != nil ||
                declaration.as(ClassDeclSyntax.self) != nil else {
            let diagnostic = Diagnostic(node: attribute, message: DiagnosticMessage.notAStructOrClass)
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

extension VariableDeclSyntax {
    /// Determine whether this variable has the syntax of a stored property.
    ///
    /// This syntactic check cannot account for semantic adjustments due to,
    /// e.g., accessor macros or property wrappers.
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
}
