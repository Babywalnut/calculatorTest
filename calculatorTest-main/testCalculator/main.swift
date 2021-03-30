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
    static func > (lhs: Precedence, rhs: Precedence) -> Bool {
        switch (lhs, rhs) {
        case (.bitwisePrecedence, .multiplicationPrecedence), (.bitwisePrecedence, .additionPrecedence), (.multiplicationPrecedence, .additionPrecedence):
            return true
        default:
            return false
        }
 
    }
    static func == (lhs: Precedence, rhs: Precedence) -> Bool {
        switch (lhs, rhs) {
        case (.bitwisePrecedence, .bitwisePrecedence), (.multiplicationPrecedence, .multiplicationPrecedence), (.additionPrecedence, .additionPrecedence):
            return true
        default:
            return false
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
    
    var precedence: Precedence {
        switch self {
        case .leftShift, .rightShift, .NOT:
            return .bitwisePrecedence
        case .AND, .NAND, .multiplication, .division:
            return .multiplicationPrecedence
        case .addition, .subtraction, .OR, .NOR, .XOR:
            return .additionPrecedence
        }
    }
    
    static var list: [String] {
        return Operators.allCases.map { $0.rawValue }
    }
}

class InputDataValidation {
    typealias Precedence = Int
    
    static let sharedInstance = InputDataValidation()
    var medianNotation: [String] = []
    
    private init() {}
    
    private func filterAdditionalIncomingData(currentData: String, previousData: String) {
        switch Operators.list.contains(previousData) {
        case true :
            if Operators.list.contains(currentData){
                medianNotation.removeLast()
                medianNotation.append(currentData)
            } else {
                medianNotation.append(currentData)
            }
        case false :
            if Operators.list.contains(currentData) {
                medianNotation.append(currentData)
            } else {
                medianNotation.removeLast()
                medianNotation.append(previousData + currentData)
            }
        }
    }
    
    private func filterInitialIncomingData(_ inputData: String) {
        if inputData == "~" || !Operators.list.contains(inputData) {
            medianNotation.append(inputData)
        } else {
            medianNotation = []
        }
    }
    
    func manageData(input: String) {
        if medianNotation.isEmpty {
            filterInitialIncomingData(input)
        }
        else {
            guard let finalElement = medianNotation.last else { return }
            
            filterAdditionalIncomingData(currentData: input, previousData: finalElement)
        }
    }
}

class GeneralCalculation {
    static let sharedInstance = GeneralCalculation()
    var medianNotation = InputDataValidation.sharedInstance.medianNotation
    var postfixNotation: [String] = []
    var operatorStack = Stack<String>()
    
    private func distinguishOperatorFromOperand(_ element: String) {
        if Operators.list.contains(element) {
            pushPriorOperator(element)
        }
        else {
            postfixNotation.append(element)
        }
    }
    
    private func pushPriorOperator(_ element: String) {
        if operatorStack.isEmpty() {
            operatorStack.push(element)
        }
        else {
            guard let peeked = operatorStack.peek() else { return }
            guard let incomingOperator = Operators(rawValue: element),
                  let stackedOperator = Operators(rawValue: peeked.value) else { return }
                  
            while incomingOperator.precedence > stackedOperator.precedence || incomingOperator.precedence == stackedOperator.precedence {
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
    
    func convertToPostfixNotation() {
        if Operators.list.contains(medianNotation.last!) {
            medianNotation.removeLast()
        }
        for element in medianNotation {
            distinguishOperatorFromOperand(element)
        }
        appendRemainingOperators()
    }
}


class DecimalCalculation {
    typealias Precedence = Int
    
    var postfixNotation = GeneralCalculation.sharedInstance.postfixNotation
    var firstOperand = Double()
    var secondOperand = Double()
    
    func calculatePostfixNotation() {
        var operandStack = Stack<Double>()
        dump(postfixNotation)
        
        for element in postfixNotation {
            if Operators.list.contains(element) {
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

let inputdatavalidation = InputDataValidation.sharedInstance
inputdatavalidation.manageData(input: "3")
inputdatavalidation.manageData(input: "+")
inputdatavalidation.manageData(input: "2")
inputdatavalidation.manageData(input: "/")
inputdatavalidation.manageData(input: "1")
print(inputdatavalidation.medianNotation)

let generalCalculation: GeneralCalculation = GeneralCalculation.sharedInstance
generalCalculation.convertToPostfixNotation()
print(generalCalculation.postfixNotation)

let decimalCalculator: DecimalCalculation = DecimalCalculation()
decimalCalculator.calculatePostfixNotation()
