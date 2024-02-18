import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PublicInit.self,
        CodingKeys.self,
        CodingKey.self
    ]
}
