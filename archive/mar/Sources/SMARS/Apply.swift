//
//  Apply.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels

@Generable(description: "Function application instance that invokes a maplet with specific arguments and captures the result")
public struct Apply: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Unique call identifier - typically sequential like 'call1', 'call2' or descriptive")
  public let callID: String
  @Guide(description: "Name of the maplet being invoked - must match an existing Maplet name")
  public let mapletID: String
  @Guide(description: "Function arguments as string - single value, tuple (arg1,arg2), or empty () for no args")
  public let arguments: String
  @Guide(description: "Expected or actual result of the function call - can be literal or reference to Datum")
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
