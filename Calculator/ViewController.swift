//
//  ViewController.swift
//  Calculator
//
//  Created by Sergei Ziuzev on 02/09/2017.
//  Copyright © 2017 Sergei Ziuzev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var point: UIButton! {
        didSet {
            point.setTitle(decilalSeparator, for: UIControlState())
        }
    }
    @IBOutlet weak var displayM: UILabel!
    
    
    let decilalSeparator = formatter.decimalSeparator ?? "."
    
    var userIsInTheMiddleOfTyping = false

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        print("\(digit) was touched")
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if (digit != decilalSeparator) || !(textCurrentlyInDisplay.contains(decilalSeparator)) {
                display.text = textCurrentlyInDisplay + digit
            }
            
        } else {
            display.text = digit.contains(".") ? "0" + digit : digit //(display.text ?? "0") if current display = 0 and digit = . then write "0." else "."
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double? {
        get {
            if let text = display.text, let value = formatter.number(from: text) as? Double {
                return value
            }
            return nil //Double(display.text!)!
        }
        set {
            if let value = newValue {
                display.text = formatter.string(from: NSNumber(value:value))
            }
//            if let description = brain.description {
//                history.text = description + (brain.resultIsPending ? " …" : " =")
//            }
        }
//        set {
//            display.text = formatter.string(from: NSNumber(value:newValue))
////            display.text = String(newValue)
//        }
    }
    
    var displayResult: (result: Double?, isPending: Bool, description: String, error: String?) = (nil, false, " ", nil) {
        didSet {
            switch displayResult {
            case (nil, _, " ", nil) : displayValue = 0
            case (let result, _, _, nil) : displayValue = result
            case (_, _, _, let error) : display.text = error!
            }
            history.text = displayResult.description != " " ? displayResult.description + (displayResult.isPending ? " ..." : " =") : " "
            displayM.text = formatter.string(from: NSNumber(value:variableValue["M"] ?? 0))
        }
    }
    
    
    private var brain = CalculatorBrain()
    private var variableValue = [String: Double]()
    
    @IBAction func performOperation(_ sender: UIButton) {
        print("\(sender.currentTitle!) was touch")
        if userIsInTheMiddleOfTyping {
            if let value = displayValue {
                brain.setOperand(value)
            }
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
//        displayValue = brain.result
        displayResult = brain.evaluate(using: variableValue)
        
//        if let result = brain.result {
//            displayValue = result
//        }
        
//        if let description = brain.description {
//            history.text = description + (brain.resultIsPending ? " ..." : " =")
//        }
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        brain.clear()
        variableValue = [:]
//        displayValue = 0
//        history.text = " "
        displayResult = brain.evaluate()
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            guard !display.text!.isEmpty else { return }
            display.text = String(display.text!.characters.dropLast())
            if display.text!.isEmpty {
//                displayValue = 0
                userIsInTheMiddleOfTyping = false
                displayResult = brain.evaluate(using: variableValue)
            }
        } else {
            brain.undo()
            displayResult = brain.evaluate(using: variableValue)
            
        }
//        guard userIsInTheMiddleOfTyping && !display.text!.isEmpty else { return }
//        display.text = String(display.text!.dropLast())
//        if display.text!.isEmpty {
//            displayValue = 0
//        }
    }
    
    @IBAction func setM(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = String((sender.currentTitle!).characters.dropLast())
        variableValue[symbol] = displayValue
        displayResult = brain.evaluate(using: variableValue)
        
    }
    
    
    @IBAction func pushM(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        displayResult = brain.evaluate(using: variableValue)
    }
    
}

