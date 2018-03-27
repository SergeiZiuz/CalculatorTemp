//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Sergei Ziuzev on 06/09/2017.
//  Copyright © 2017 Sergei Ziuzev. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
//    private var accumulator: Double?
//    private var descriptionAccumulator: String?
    
    private enum opStack {
        case operand(Double)
        case operation(String)
        case variable(String)
    }
    
    private var internalProgram = [opStack]()
    
    mutating func setOperand (_ operand: Double) {
        internalProgram.append(opStack.operand(operand))
    }
    
    mutating func setOperand (variable named: String) {
        internalProgram.append(opStack.variable(named))
    }
    
    mutating func performOperation (_ symbol: String) {
        internalProgram.append(opStack.operation(symbol))
    }
    
    mutating func clear() {
        internalProgram.removeAll()
    }
    
    mutating func undo() {
        if !internalProgram.isEmpty {
            internalProgram = Array(internalProgram.dropLast())
        }
    }
    
    private enum Operation {
        case nullaryOperation(() -> Double, String)
        case constant(Double)
        case unaryOperation((Double) -> Double, ((String) -> String)?, ((Double) -> String?)?)
        case binaryOperation((Double, Double) -> Double, ((String, String) -> String)?, ((Double, Double) -> String?)?, Int)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "Ran" : Operation.nullaryOperation({Double(arc4random()) / Double(UInt32.max)}, "rand()"),
        "π" : Operation.constant(Double.pi), // Double.pi,
        "e" : Operation.constant(M_E), // M_E,
        "√" : Operation.unaryOperation(sqrt, nil, { $0 < 0 ? "√ negativ number" : nil}), // sqrt,
//        "∛" : Operation.unaryOperation(), // cqrt
        "cos" : Operation.unaryOperation(cos, nil, nil), // cos
        "sin" : Operation.unaryOperation(sin, nil, nil), //sin
        "tan" : Operation.unaryOperation(tan, nil, nil), // Tan
        "sin⁻¹" : Operation.unaryOperation(asin, nil, { $0 < -1.0 || $0 > 1.0 ? "not in range [-1,1]" : nil}),
        "cos⁻¹" : Operation.unaryOperation(acos, nil, { $0 < -1.0 || $0 > 1.0 ? "not in range [-1,1]" : nil}),
        "tan⁻¹" : Operation.unaryOperation(atan, nil, nil),
        "x²" : Operation.unaryOperation({pow($0, 2.0)}, {"(" + $0 + ")²"}, nil),
        "x³" : Operation.unaryOperation({pow($0, 3.0)}, {"(" + $0 + ")³"}, nil),
        "%" : Operation.unaryOperation({$0 / 100}, nil, nil), // Persent
        "±" : Operation.unaryOperation({ -$0 }, nil, nil), //+/-
        "×" : Operation.binaryOperation(*, nil, nil, 1), // this is ({ $0 * $1 })
        "÷" : Operation.binaryOperation(/, nil, { $1 == 0 ? "devide by zerro" : nil}, 1), // this is ({ $0 / $1 })
        "+" : Operation.binaryOperation(+, nil, nil, 0), // this is ({ $0 + $1 })
        "−" : Operation.binaryOperation(-, nil, nil, 0), // this is ({ $0 - $1 })
        "𝕩ʸ" : Operation.binaryOperation({pow($0, $1)}, {$0 + "^" + $1}, nil, 2),
        "=" : Operation.equals
    ]
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        var validator: ((Double, Double) -> String?)?
        var prevPrecedence: Int
        var precedence: Int
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        func performDescription(with secondOperand: String) -> String {
            var descriptionOperandNew = descriptionOperand
            if prevPrecedence < precedence {
                descriptionOperandNew = "(" + descriptionOperandNew + ")"
            }
            return descriptionFunction(descriptionOperandNew, secondOperand)
        }
        func validate(with secondOperand: Double) -> String? {
            guard let validator = validator else {return nil}
            return validator (firstOperand, secondOperand)
        }
    }
    
    //-------------------------------------------------------------------------
    // MARK: - evaluate
    
    func evaluate (using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String, error: String?) {
        // MARK: - Local variables evaluate
        var cache: (accumulator: Double?, descriptionAccumulator: String?) //tuple
        var error: String?
        var prevPrecedence = Int.max
        var pendingBinaryOperation: PendingBinaryOperation?
        var description: String? {
            if pendingBinaryOperation == nil {
                return cache.descriptionAccumulator
            } else {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand, cache.descriptionAccumulator ?? "")
            }
        }
        var result: Double? {
            return cache.accumulator
//            if pendingBinaryOperation == nil {
//                return accumulator
//            } else {
//                return pendingBinaryOperation!.firstOperand
//            }
        }
        var resultIsPending: Bool {
            return pendingBinaryOperation != nil
        }
        
        //MARK: - Nested function evaluate
        
        func setOperand(_ operand: Double) {
            cache.accumulator = operand
            if let value = cache.accumulator {
                cache.descriptionAccumulator = formatter.string(from: NSNumber(value:value)) ?? ""
                prevPrecedence = Int.max
            }
        }
        
        func setOperand(variable named: String) {
            cache.accumulator = variables?[named] ?? 0
            cache.descriptionAccumulator = named
            prevPrecedence = Int.max
        }
        
        func performOperation(_ symbol: String) {
            if let operation = operations[symbol] {
                error = nil
                switch operation {
                case .nullaryOperation (let function, let descriptionValue):
                    cache = (function(), descriptionValue)
                case .constant(let value):
                    cache = (value, symbol)
                case .unaryOperation(let function, var descriptionFunction, let validator):
                    if cache.accumulator != nil {
                        error = validator?(cache.accumulator!)
                        cache.accumulator = function(cache.accumulator!)
                        if descriptionFunction == nil {
                            descriptionFunction = {symbol + "(" + $0 + ")"}
                        }
//                        cash = (function(cash.accumulator!), descriptionFunction!(cash.descriptionAccumulator!))
                        cache.descriptionAccumulator = descriptionFunction!(cache.descriptionAccumulator!)
                    }
                case .binaryOperation(let function, var descriptionFunction, let validator, let precedence):
                    performPendingBinaryOperation()
                    if cache.accumulator != nil {
                        if descriptionFunction == nil {
                            descriptionFunction = {$0 + " " + symbol + " " + $1}
                        }
                        pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: cache.accumulator!, descriptionFunction: descriptionFunction!, descriptionOperand: cache.descriptionAccumulator!, validator: validator, prevPrecedence: prevPrecedence, precedence: precedence)
                        cache = (nil, nil)
                        //                    cash.accumulator = nil
                        //                    cash.descriptionAccumulator = nil
                    }
                case .equals:
                    performPendingBinaryOperation()
                }
            }
        }
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && cache.accumulator != nil {
                error = pendingBinaryOperation!.validate(with: cache.accumulator!)
                cache = (pendingBinaryOperation!.perform(with: cache.accumulator!), pendingBinaryOperation!.performDescription(with: cache.descriptionAccumulator!))
               prevPrecedence = pendingBinaryOperation!.precedence
//            cash.accumulator = pendingBinaryOperation!.perform(with: cash.accumulator!)
//            cash.descriptionAccumulator = pendingBinaryOperation!.performDescription(with: cash.descriptionAccumulator!)
                pendingBinaryOperation = nil
            }
        }
        
        // MARK: - Body evaluate
        
        guard !internalProgram.isEmpty else {return (nil, false, " ", nil)}
        prevPrecedence = Int.max
        pendingBinaryOperation = nil
        for op in internalProgram {
            switch op {
            case .operand(let operand):
                setOperand(operand)
            case .operation(let operation):
                performOperation(operation)
            case .variable(let symbol):
                setOperand(variable: symbol)
            }
        }
        return (result, resultIsPending, description ?? " ", error)
    }
    //---------------------------------------------------------
    
//    mutating func clear() {
//        cash = (nil, nil)
////        cash.accumulator = nil
////        cash.descriptionAccumulator = nil
//        pendingBinaryOperation = nil
//    }
    
    @available(iOS, deprecated, message: "No longer needed")
    var description: String? {
        return evaluate().description
    }
    
    @available(iOS, deprecated, message: "No longer needed")
    var result: Double? {
        return evaluate().result
    }
    
    @available(iOS, deprecated, message: "No longer needed")
    var resultIsPending: Bool {
        return evaluate().isPending
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
