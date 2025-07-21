
import Foundation
import FoundationModels

@Generable
public struct Datum: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "The symbolic constant name (appears in ⟦brackets⟧ in SMARS syntax)")
  public let name: String
  @Guide(description: "The declared type of the constant (e.g., STRING, INTEGER, FLOAT, BOOL)")
  public let type: String
  @Guide(description: "The literal value of the constant as a string representation")
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
