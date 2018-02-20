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
    
    var userIsInTheMiddleOfTyping = false

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if (digit != ".") || !(textCurrentlyInDisplay.contains(".")) {
                display.text = textCurrentlyInDisplay + digit
            }
            
        } else {
            display.text = digit.contains(".") ? "0" + digit : digit //(display.text ?? "0") if current display = 0 and digit = . then write "0." else "."
            userIsInTheMiddleOfTyping = true
        }
        print("\(digit) was touched")
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        if let description = brain.description {
            history.text = description + (brain.resultIsPending ? " ..." : " =")
        }
    }
    
}

