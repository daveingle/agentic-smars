
import Foundation
import FoundationModels

@Generable(description: "Symbolic constant declaration with explicit type and value - provides named constants for system configuration")
public struct Datum: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Symbolic name enclosed in ⟦brackets⟧ - typically snake_case for constants")
  public let name: String
  @Guide(description: "Type declaration - must be STRING, INTEGER, FLOAT, BOOL, or custom Kind name")
  public let type: String
  @Guide(description: "Literal value as string - will be parsed according to declared type")
  public let value: String

  // MARK: ‑ CustomStringConvertible (symbolic serialisation)

  public var description: String {
    "δ\(name)∷\(type)=\(value)"
  }
}

public extension Datum {

  init<A: CustomStringConvertible>(_ name: String, type: String, value: A) {
    self.name = name
    self.type = type
    self.value = value.description
  }
}
