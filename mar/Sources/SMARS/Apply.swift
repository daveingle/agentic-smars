//
//  Apply.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels

@Generable
public struct Apply: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Unique identifier for this function application instance")
  public let callID: String
  @Guide(description: "Name of the maplet (function) being invoked")
  public let mapletID: String
  @Guide(description: "Serialized argument expression - single value or tuple for multiple arguments")
  public let arguments: String
  @Guide(description: "The result of the function application - literal value or reference to another atom")
  public let result: String

  /// Designated initialiser for unary calls with simple literals.
  public init(callID: String,
              mapletID: String,
              argument: String,
              result: String) {
    self.callID = callID
    self.mapletID = mapletID
    self.arguments = argument
    self.result = result
  }

  /// Initialiser for multi‑arg (tuple) calls.  The helper joins the list
  /// using `","` and wraps with parentheses:  ["a","b"] → "(a,b)".
  public init(callID: String,
              mapletID: String,
              arguments: [String],
              result: String) {
    self.callID = callID
    self.mapletID = mapletID
    switch arguments.count {
    case 0:
      self.arguments = "()"
    case 1:
      self.arguments = arguments[0]
    default:
      self.arguments = "(\(arguments.joined(separator: ",")))"
    }
    self.result = result
  }

  // MARK: - CustomStringConvertible (symbolic serialisation)

  public var description: String {
    "α\(callID)∶\(mapletID)▸\(arguments)⇢\(result)"
  }
}
