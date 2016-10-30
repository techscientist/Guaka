//
//  ArgTokenType.swift
//  CommandLine
//
//  Created by Omar Abdelhafith on 30/10/2016.
//
//
import StringScanner


enum ArgTokenType {
  case longFlag(String), longFlagWithEqual(String, String)
  case shortFlag(String), shortFlagWithEqual(String, String)
  case shortMultiFlag(String)
  case invalidFlag(String)
  case positionalArgument(String)
  
  init(fromString string: String) {
    
    if string.hasPrefix("---") {
      
      self = .invalidFlag(string)
    } else if string.hasPrefix("--") {
      
      self = ArgTokenType.parseLongFlag(string)
    } else if string.hasPrefix("-") {
      
      self = ArgTokenType.parseShortFlag(string)
    } else {
      self = .positionalArgument(string)
    }
  }
  
  static func hasEqual(_ string: String) -> Bool {
    return string.characters.first { $0 == "=" } != nil
  }
  
  static func parseLongFlag(_ string: String) -> ArgTokenType {
    let scanner = StringScanner(string: string)
    _ = scanner.drop(length: 2)
    
    if ArgTokenType.hasEqual(string) {
      let (name, value) = parseEqual(scanner)
      return .longFlagWithEqual(name, value)
    } else {
      return .longFlag(scanner.remainingString)
    }
  }
  
  static func parseShortFlag(_ string: String) -> ArgTokenType {
    let scanner = StringScanner(string: string)
    _ = scanner.drop(length: 1)
    
    let length = scanner.remainingString.characters.count
    
    if length <= 0 {
      
      return .invalidFlag(string)
    } else if length == 1 {
      
      return .shortFlag(scanner.remainingString)
    } else {
      
      if isMultiFlag(scanner) {
        return .shortMultiFlag(scanner.remainingString)
      } else {
        if hasEqual(string) {
          let (name, value) = parseEqual(scanner)
          return .shortFlagWithEqual(name, value)
        } else {
          return .shortFlag(scanner.remainingString)
        }
      }
    }
  }
  
  static func parseEqual(_ scanner: StringScanner) -> (String, String) {
    var name = "", value = ""
    
    scanner.transaction {
      if case let .value(string) = scanner.scan(untilString: "=") {
        name = string
        _ = scanner.drop(length: 1)
        value = scanner.remainingString
      }
    }
    
    return (name, value)
  }
  
  static func parseMultiString(_ string: String) -> [String] {
    return string.characters.map { String($0) }
  }
  
  static func isMultiFlag(_ scanner: StringScanner) -> Bool {
    if case .value (let str) = scanner.peek(untilString: "=") {
      return str.characters.count > 1
    }
    
    return scanner.remainingString.characters.count > 1
  }
  
  var isFlag: Bool {
    switch self {
    case .longFlag:
      fallthrough
    case .shortFlag:
      fallthrough
    case .longFlagWithEqual:
      fallthrough
    case .shortFlagWithEqual:
      fallthrough
    case .shortMultiFlag:
      return true
      
    default:
      return false
    }
  }
  
  var requiresValue: Bool {
    switch self {
    case .longFlag:
      fallthrough
    case .shortFlag:
      fallthrough
    case .shortMultiFlag:
      return true
      
    default:
      return false
    }
  }
  
  var flagName: String? {
    switch self {
    case let .longFlag(name):
      return name
    case let .shortFlag(name):
      return name
    case let .longFlagWithEqual(name, _):
      return name
    case let .shortFlagWithEqual(name, _):
      return name
    case let .shortMultiFlag(name):
      return name
      
    default:
      return nil
    }
  }
}
