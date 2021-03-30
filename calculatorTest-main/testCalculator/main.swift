//
//  calculator.swift
//  Calculator
//
//  Created by 제임스,수킴,바비 on 2021/03/26.
//

import Foundation


class Data {
    static var medianNotation: [String] = []
    static var postfixNotation: [String] = []
}

enum Precedence {
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

    static func < (lhs: Precedence, rhs: Precedence) -> Bool {
        switch (lhs, rhs) {
        case (.bitwisePrecedence, .multiplicationPrecedence), (.bitwisePrecedence, .additionPrecedence), (.multiplicationPrecedence, .additionPrecedence):
            return false
        default:
            return true
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
    
    private func filterAdditionalIncomingData(currentData: String, previousData: String) {
        switch Operators.list.contains(previousData) {
        case true :
            if currentData == "~" || !Operators.list.contains(currentData) {
                Data.medianNotation.append(currentData)
            }
            else {
                Data.medianNotation.removeLast()
                Data.medianNotation.append(currentData)
            }
        case false :
            if Operators.list.contains(currentData) {
                Data.medianNotation.append(currentData)
            }
            else {
                Data.medianNotation.removeLast()
                Data.medianNotation.append(previousData + currentData)
            }
        }
    }
    
    private func filterInitialIncomingData(_ inputData: String) {
        if inputData == "~" || !Operators.list.contains(inputData) {
            Data.medianNotation.append(inputData)
        }
        else {
            Data.medianNotation = []
        }
    }
    
    func manageData(input: String) {
        if Data.medianNotation.isEmpty {
            filterInitialIncomingData(input)
        }
        else {
            guard let finalElement = Data.medianNotation.last else { return }
            
            filterAdditionalIncomingData(currentData: input, previousData: finalElement)
        }
    }
}

class GeneralCalculator {
    var decimalCalcualtion = DecimalCalculation()
    var binaryCalculation = BinaryCalculation()
    var operatorStack = Stack<String>()
    
    private func distinguishOperatorFromOperand(_ element: String) {
        if Operators.list.contains(element) {
            pushPriorOperator(element)
        }
        else {
            Data.postfixNotation.append(element)
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
                  
            while incomingOperator.precedence < stackedOperator.precedence || incomingOperator.precedence == stackedOperator.precedence {
                guard let popped = operatorStack.pop() else { break }
                
                Data.postfixNotation.append(popped.value)
            }
                operatorStack.push(element)
        }
    }
    
    private func appendRemainingOperators() {
        while !operatorStack.isEmpty() {
            guard let remainder = operatorStack.pop()?.value else { return }
            
            Data.postfixNotation.append(remainder)
        }
    }
    
    func executeDecimalCalculation() {
        if Operators.list.contains(Data.medianNotation.last!) {
            Data.medianNotation.removeLast()
        }
        for element in Data.medianNotation {
            distinguishOperatorFromOperand(element)
        }
        appendRemainingOperators()
        decimalCalcualtion.calculatePostfixNotation()
    }
    
    func executeBinaryCalculation() {
        if Operators.list.contains(Data.medianNotation.last!) {
            Data.medianNotation.removeLast()
        }
        for element in Data.medianNotation {
            distinguishOperatorFromOperand(element)
        }
        appendRemainingOperators()
        binaryCalculation.calculatePostfixNotation()
    }
    
}


class DecimalCalculation {
    var firstOperand = Double()
    var secondOperand = Double()
    
    func calculatePostfixNotation() {
        var operandStack = Stack<Double>()

        
        for element in Data.postfixNotation {
            if !Operators.list.contains(element) {
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

let inputdatavalidation = InputDataValidation()
inputdatavalidation.manageData(input: "5")
inputdatavalidation.manageData(input: "-")
inputdatavalidation.manageData(input: "15")
//inputdatavalidation.manageData(input: "+")
//inputdatavalidation.manageData(input: "~")
//inputdatavalidation.manageData(input: "2")
//inputdatavalidation.manageData(input: "*")
//inputdatavalidation.manageData(input: "4")
//inputdatavalidation.manageData(input: "+")
//inputdatavalidation.manageData(input: "2")
//inputdatavalidation.manageData(input: "*")
//inputdatavalidation.manageData(input: "8")
print(Data.medianNotation)

let generalCalculator: GeneralCalculator = GeneralCalculator()
//generalCalculation.executeDecimalCaculation()
generalCalculator.executeBinaryCalculation()
print(Data.postfixNotation)
