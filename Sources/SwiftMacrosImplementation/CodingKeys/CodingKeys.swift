import SwiftSyntax
import SwiftSyntaxMacros
import RegexBuilder

public enum CodingKeys: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let memberList = declaration.memberBlock.members

        let cases = memberList.compactMap { member -> String? in
            // is a property
            guard
                let propertyName = member.decl.as(VariableDeclSyntax.self)?.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                return nil
            }

            // if it has a CodingKey macro on it
            if let customKeyMacro = member.decl.as(VariableDeclSyntax.self)?.attributes.first(where: { element in
                element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.description == "CodingKey"
            }) {
                // Uses the value in the Macro
                let customKeyValue = customKeyMacro.as(AttributeSyntax.self)!.arguments!.as(LabeledExprListSyntax.self)!.first!.expression

                return "case \(propertyName) = \(customKeyValue)"
            } else {
                guard let strategyCase = node
                    .arguments?.as(LabeledExprListSyntax.self)?.first?
                    .expression.as(MemberAccessExprSyntax.self)?
                    .declName.baseName.text else {
                    return "case \(propertyName)"
                }

                guard ["snake_case", "default"].contains(strategyCase) else {
                    return "case \(propertyName)"
                }

                switch strategyCase {
                case "snake_case":
                    let keyValue = propertyName.snakeCased()
                    if keyValue == propertyName {
                        return "case \(propertyName)"
                    } else {
                        return "case \(propertyName) = \"\(keyValue)\""
                    }
                case "default":
                    return "case \(propertyName)"
                default:
                    return "case \(propertyName)"
                }
            }
        }

        let codingKeys: DeclSyntax = """
        enum CodingKeys: String, CodingKey {
            \(raw: cases.joined(separator: "\n"))
        }
        """

        return [codingKeys]
    }
}

public struct CodingKey: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Does nothing, used only to decorate members with data
        return []
    }
}

private extension String {
    func snakeCased() -> String {
        let capitalLetters = Regex {
            Capture {
                "A"..."Z"
            }
        }

        let snakeCased = replacing(capitalLetters) { match in
            "_\(match.output.1.lowercased())"
        }

        return snakeCased
    }
}
