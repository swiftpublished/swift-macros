@attached(member, names: named(init))
public macro PublicInit() = #externalMacro(module: "SwiftMacrosImplementation", type: "PublicInit")

public enum CodingKeysStrategy: String {
    case snake_case
    case `default`
}

@attached(member, names: named(CodingKeys))
public macro CodingKeys(using: CodingKeysStrategy = .default) = #externalMacro(module: "SwiftMacrosImplementation", type: "CodingKeys")

@attached(peer)
public macro CodingKey(name: String) = #externalMacro(module: "SwiftMacrosImplementation", type: "CodingKey")
