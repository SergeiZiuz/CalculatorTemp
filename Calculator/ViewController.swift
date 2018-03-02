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
    
    let decilalSeparator = formatter.decimalSeparator ?? "."
    
    var userIsInTheMiddleOfTyping = false

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        print("\(digit) was touched")
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if (digit != ".") || !(textCurrentlyInDisplay.contains(".")) {
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
            if let description = brain.description {
                history.text = description + (brain.resultIsPending ? " …" : " =")
            }
        }
//        set {
//            display.text = formatter.string(from: NSNumber(value:newValue))
////            display.text = String(newValue)
//        }
    }
    
    private var brain = CalculatorBrain()
    
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
        
        displayValue = brain.result
        
//        if let result = brain.result {
//            displayValue = result
//        }
        
//        if let description = brain.description {
//            history.text = description + (brain.resultIsPending ? " ..." : " =")
//        }
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        brain.clear()
        displayValue = 0
        history.text = " "
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        guard userIsInTheMiddleOfTyping && !display.text!.isEmpty else { return }
        display.text = String(display.text!.dropLast())
        if display.text!.isEmpty {
            displayValue = 0
        }
    }
}

