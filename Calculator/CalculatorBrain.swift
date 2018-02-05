//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Sergei Ziuzev on 06/09/2017.
//  Copyright © 2017 Sergei Ziuzev. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi), // Double.pi,
        "e" : Operation.constant(M_E), // M_E,
        "√" : Operation.unaryOperation(sqrt), // sqrt,
//        "∛" : Operation.unaryOperation(), // cqrt
        "cos" : Operation.unaryOperation(cos), // cos
        "sin" : Operation.unaryOperation(sin), //sin
        "tan" : Operation.unaryOperation(tan), // Tan
        "x²" : Operation.unaryOperation({pow($0, 2.0)}),
        "x³" : Operation.unaryOperation({pow($0, 3.0)}),
        "%" : Operation.unaryOperation({$0 / 100}), // Persent
        "±" : Operation.unaryOperation({ -$0 }), //+/-
        "×" : Operation.binaryOperation(*), // this is ({ $0 * $1 })
        "÷" : Operation.binaryOperation(/), // this is ({ $0 / $1 })
        "+" : Operation.binaryOperation(+), // this is ({ $0 + $1 })
        "−" : Operation.binaryOperation(-), // this is ({ $0 - $1 })
        "𝕩ʸ" : Operation.binaryOperation({pow($0, $1)}),
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let Value):
                accumulator = Value
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
}
