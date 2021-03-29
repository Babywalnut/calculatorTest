//
//  calculator.swift
//  Calculator
//
//  Created by 제임스,수킴,바비 on 2021/03/26.
//

import Foundation

enum Precedence: CaseIterable {
    case bitwisePrecedence
    case multiplicationPrecedence
    case additionPrecedence
}

extension Precedence: Comparable {
    static func < (lhs: Precedence, rhs: Precedence) -> Bool {
        switch lhs {
        case .bitwisePrecedence:
            return false
        case .multiplicationPrecedence:
            if rhs == .bitwisePrecedence {
                return lhs < rhs
            }
            else {
                return false
            }
        case .additionPrecedence:
            if rhs == .additionPrecedence {
                return false
            }
            else {
                return lhs < rhs
            }
        }
    }
    static func > (lhs: Precedence, rhs: Precedence) -> Bool {
        switch lhs {
        case .bitwisePrecedence:
            if rhs != .bitwisePrecedence {
                return lhs > rhs
            }
        case .multiplicationPrecedence:
            if rhs == .additionPrecedence {
                return lhs > rhs
            }
            else {
                return false
            }
        case .additionPrecedence:
            return false
        }
 
    }
    static func == (lhs: Precedence, rhs: Precedence) -> Bool {
        if lhs != rhs {
            return false
        }
        else {
            return lhs == rhs
        }
    }
}

enum Operators: String, CaseIterable {
    case multiplication = "*"
    case division = "/"
    case addition = "+"
    case subtraction = "-"
    case leftShift = "<<"
    case rightShift = ">>"
    case AND = "&"
    case NAND = "~&"
    case OR = "|"
    case NOR = "~|"
    case XOR = "^"
    case NOT = "~"
    
    var precedence: [String: Precedence] {
        switch self {
        case .leftShift, .rightShift, .NOT:
            return [rawValue: .bitwisePrecedence]
        case .AND, .NAND, .multiplication, .division:
            return [rawValue: .multiplicationPrecedence]
        case .addition, .subtraction, .OR, .NOR, .XOR:
            return [rawValue: .additionPrecedence]
        }
    }
}

class InputDataValidation {
    typealias Precedence = Int
    
    static let sharedInstance = InputDataValidation()
    var medianNotation: [String] = []
//    let operatorPriority: [String : Precedence] = [">>" : 4, "<<" : 4 ,"&" : 3, "~&" : 3, "*" : 3, "/" : 3,
//                                                   "|" : 2, "~|" : 2, "^" : 2, "+" : 2, "-" : 2, "~" : 1]
    
    private init() {}
    
    private func filterAdditionalIncomingData(_ operators: Operators, currentData: String, previousData: String) {
        switch operators.rawValue.contains(previousData) {
        case true :
            if operators.rawValue.contains(currentData){
                medianNotation.removeLast()
                medianNotation.append(currentData)
            } else {
                medianNotation.append(currentData)
            }
        case false :
            if operators.rawValue.contains(currentData) {
                medianNotation.append(currentData)
            } else {
                medianNotation.removeLast()
                medianNotation.append(previousData + currentData)
            }
        }
    }
    
    private func filterInitialIncomingData(_ inputData: String, _ operators: Operators) {
        if inputData == "~" || !operators.rawValue.contains(inputData) {
            medianNotation.append(inputData)
        } else {
            medianNotation = []
        }
    }
    
    func manageData(input: String, operators: Operators) {
        if medianNotation.isEmpty {
            filterInitialIncomingData(input, operators)
        }
        guard let finalElement = medianNotation.last else { return }
        
        filterAdditionalIncomingData(operators, currentData: input, previousData: finalElement)
    }
}

class GeneralCalculation {
    var medianNotation = InputDataValidation.sharedInstance.medianNotation
    var postfixNotation: [String] = []
    var operatorStack = Stack<String>()

    func convertToPostfixNotation(operators: Operators) {
        if operators.rawValue.contains(medianNotation.last!) {
            medianNotation.removeLast()
        }
        for element in medianNotation {
            distinguishOperatorFromOperand(element, operators)
        }
        appendRemainingOperators()
    }
    
    private func distinguishOperatorFromOperand(_ element: String, _ operators: Operators) {
        if operators.rawValue.contains(element) {
            pushPriorOperator(element, operators)
        }
        else {
            postfixNotation.append(element)
        }
    }
    
    private func pushPriorOperator(_ element: String, _ operators: Operators) {
        if operatorStack.isEmpty() {
            operatorStack.push(element)
        }
        else {
            let operaterArray = Operators.allCases
            guard let peeked = operatorStack.peek() else { return }
            while operators.precedence[peeked.value]! > operators.precedence[element]! || operators.precedence[peeked.value]! == operators.precedence[element]! {
                guard let popped = operatorStack.pop() else { break }
                
                postfixNotation.append(popped.value)
            }
            operatorStack.push(element)
        }
    }
    
    private func appendRemainingOperators() {
        while !operatorStack.isEmpty() {
            if let remainder = operatorStack.pop()?.value {
                postfixNotation.append(remainder)
            }
            break
        }
    }
}


class DecimalCalculation {
    typealias Precedence = Int
    
    var postfixNotation = GeneralCalculation().postfixNotation
    let operatorPriority: [String : Precedence] = ["*" : 3, "/" : 3, "+" : 2, "-" : 2, "(" : 1]
    var firstOperand = Double()
    var secondOperand = Double()
    
    private func calculatePostfixNotation() {
        var operandStack = Stack<Double>()
        
        for element in postfixNotation {
            if !operatorPriority.keys.contains(element) {
                guard let numbers = Double(element) else { return }
                
                operandStack.push(numbers)
            }
            else {
                guard let firstPoppedValue = operandStack.pop(),
                      let secondPoppedValue = operandStack.pop() else { return }
                
                firstOperand = firstPoppedValue.value
                secondOperand = secondPoppedValue.value
                
                switch element {
                case "*" :
                    operandStack.push(secondOperand * firstOperand)
                case "/" :
                    operandStack.push(secondOperand / firstOperand)
                case "+" :
                    operandStack.push(secondOperand + firstOperand)
                case "-" :
                    operandStack.push(secondOperand - firstOperand)
                default:
                    return
                }
            }
        }
        print(operandStack.peek()?.value)
    }
    
    
}

var inputDataValidation = InputDataValidation.sharedInstance

inputDataValidation.manageData(input: "2", operators: Operators)
