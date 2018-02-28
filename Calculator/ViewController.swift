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
        print("\(sender.currentTitle!) was touch")
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

