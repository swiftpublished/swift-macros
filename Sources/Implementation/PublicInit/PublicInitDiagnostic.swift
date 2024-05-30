import SwiftSyntax
import SwiftDiagnostics

enum PublicInitDiagnostic: String {
    case notApplicable
    case notInferableType

    func diagnostic(for node: SyntaxProtocol) -> Diagnostic {
        Diagnostic(
            node: node,
            message: PublicInitDiagnosticMessage(diagnostic: self),
            fixIts: PublicInitFixItMessage(diagnostic: self).fixIts(for: node)
        )
    }
}

private extension PublicInitDiagnostic {
    struct PublicInitDiagnosticMessage: DiagnosticMessage {
        let diagnostic: PublicInitDiagnostic

        var message: String {
            switch diagnostic {
            case .notApplicable:
                return "'@PublicInit' can only be applied to a Struct or Class"
            case .notInferableType:
                return "Failed to infer the Type"
            }
        }

        var diagnosticID: MessageID {
            let id = "\(PublicInitDiagnostic.self):\(Self.self):\(diagnostic.rawValue)"
            return MessageID(domain: "SwiftMacrosImplementation", id: id)
        }

        var severity: DiagnosticSeverity {
            return .error
        }
    }

    struct PublicInitFixItMessage: FixItMessage {
        let diagnostic: PublicInitDiagnostic

        var message: String {
            switch diagnostic {
            case .notApplicable:
                return "Remove '@PublicInit'"
            case .notInferableType:
                return "Specify Type instead"
            }
        }

        var fixItID: MessageID {
            let id = "\(PublicInitDiagnostic.self):\(Self.self):\(diagnostic.rawValue)"
            return MessageID(domain: "SwiftMacrosImplementation", id: id)
        }

        func fixIts(for node: SyntaxProtocol) -> [FixIt] {
            switch diagnostic {
            case .notApplicable:
                return [
                    FixIt(
                        message: self,
                        changes: [
                            .replace(
                                oldNode: Syntax(node),
                                newNode: Syntax(TokenSyntax(stringLiteral: ""))
                            )
                        ]
                    )
                ]
            case .notInferableType:
                guard let variableName = node.as(IdentifierPatternSyntax.self) else {
                    return []
                }

                return [
                    FixIt(
                        message: self,
                        changes: [
                            .replace(
                                oldNode: Syntax(variableName),
                                newNode: Syntax(
                                    IdentifierPatternSyntax(
                                        identifier: .identifier(
                                            "\(variableName.trimmedDescription): <#Type#> "
                                        )
                                    )
                                )
                            )
                        ]
                    )
                ]
            }
        }
    }
}
