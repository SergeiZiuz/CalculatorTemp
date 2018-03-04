//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Sergei Ziuzev on 06/09/2017.
//  Copyright © 2017 Sergei Ziuzev. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var cash: (accumulator: Double?, descriptionAccumulator: String?)
    
//    private var accumulator: Double?
//    private var descriptionAccumulator: String?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, ((String) -> String)?)
        case binaryOperation((Double, Double) -> Double, ((String, String) -> String)?)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi), // Double.pi,
        "e" : Operation.constant(M_E), // M_E,
        "√" : Operation.unaryOperation(sqrt, nil), // sqrt,
//        "∛" : Operation.unaryOperation(), // cqrt
        "cos" : Operation.unaryOperation(cos, nil), // cos
        "sin" : Operation.unaryOperation(sin, nil), //sin
        "tan" : Operation.unaryOperation(tan, nil), // Tan
        "sin⁻¹" : Operation.unaryOperation(asin, nil),
        "cos⁻¹" : Operation.unaryOperation(acos, nil),
        "tan⁻¹" : Operation.unaryOperation(atan, nil),
        "x²" : Operation.unaryOperation({pow($0, 2.0)}, {"(" + $0 + ")²"}),
        "x³" : Operation.unaryOperation({pow($0, 3.0)}, nil),
        "%" : Operation.unaryOperation({$0 / 100}, nil), // Persent
        "±" : Operation.unaryOperation({ -$0 }, nil), //+/-
        "×" : Operation.binaryOperation(*, nil), // this is ({ $0 * $1 })
        "÷" : Operation.binaryOperation(/, nil), // this is ({ $0 / $1 })
        "+" : Operation.binaryOperation(+, nil), // this is ({ $0 + $1 })
        "−" : Operation.binaryOperation(-, nil), // this is ({ $0 - $1 })
        "𝕩ʸ" : Operation.binaryOperation({pow($0, $1)}, nil),
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                cash = (value, symbol)
//                cash.accumulator = value
//                cash.descriptionAccumulator = symbol
            case .unaryOperation(let function, var descriptionFunction):
                if cash.accumulator != nil {
//                    cash.accumulator = function(cash.accumulator!)
                    if descriptionFunction == nil {
                        descriptionFunction = {symbol + "(" + $0 + ")"}
                    }
                    cash = (function(cash.accumulator!), descriptionFunction!(cash.descriptionAccumulator!))
//                    cash.descriptionAccumulator = descriptionFunction!(cash.descriptionAccumulator!)
                }
            case .binaryOperation(let function, var descriptionFunction):
                performPendingBinaryOperation()
                if cash.accumulator != nil {
                    if descriptionFunction == nil {
                        descriptionFunction = {$0 + " " + symbol + " " + $1}
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: cash.accumulator!, descriptionFunction: descriptionFunction!, descriptionOperand: cash.descriptionAccumulator!)
                    cash = (nil, nil)
//                    cash.accumulator = nil
//                    cash.descriptionAccumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && cash.accumulator != nil {
            cash = (pendingBinaryOperation!.perform(with: cash.accumulator!), pendingBinaryOperation!.performDescription(with: cash.descriptionAccumulator!))
//            cash.accumulator = pendingBinaryOperation!.perform(with: cash.accumulator!)
//            cash.descriptionAccumulator = pendingBinaryOperation!.performDescription(with: cash.descriptionAccumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    var description: String? {
        if pendingBinaryOperation == nil {
            return cash.descriptionAccumulator
        } else {
            return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand, cash.descriptionAccumulator ?? "")
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func performDescription(with secondOperand: String) -> String {
            return descriptionFunction(descriptionOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        cash.accumulator = operand
        if let value = cash.accumulator {
            cash.descriptionAccumulator = formatter.string(from: NSNumber(value:value)) ?? ""
//            descriptionAccumulator = String(value)
        }
    }
    
    var result: Double? {
        return cash.accumulator
//        if pendingBinaryOperation == nil {
//            return accumulator
//        } else {
//            return pendingBinaryOperation!.firstOperand
//        }
    }
    
    mutating func clear() {
        cash = (nil, nil)
//        cash.accumulator = nil
//        cash.descriptionAccumulator = nil
        pendingBinaryOperation = nil
    }
    
}

let formatter:NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 12
    formatter.notANumberSymbol = "Error"
    formatter.groupingSeparator = " "
    formatter.locale = Locale.current
    return formatter
} ()
