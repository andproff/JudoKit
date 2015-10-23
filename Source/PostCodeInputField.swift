//
//  PostCodeInputField.swift
//  JudoKit
//
//  Copyright (c) 2015 Alternative Payments Ltd
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import Judo

let kUSARegexString = "(^\\d{5}$)|(^\\d{5}-\\d{4}$)"
let kUKRegexString = "(GIR 0AA)|((([A-Z-[QVX]][0-9][0-9]?)|(([A-Z-[QVX]][A-Z-[IJZ]][0-9][0-9]?)|(([A-Z-[QVX‌​]][0-9][A-HJKSTUW])|([A-Z-[QVX]][A-Z-[IJZ]][0-9][ABEHMNPRVWXY]))))\\s?[0-9][A-Z-[C‌​IKMOV]]{2})"
let kCanadaRegexString = "[ABCEGHJKLMNPRSTVXY][0-9][ABCEGHJKLMNPRSTVWXYZ][0-9][ABCEGHJKLMNPRSTVWXYZ][0-9]"

public class PostCodeInputField: JudoPayInputField {
    
    var billingCountry: BillingCountry = .UK {
        didSet {
            switch billingCountry {
            case .UK, .Canada:
                self.textField().keyboardType = .Default
            default:
                self.textField().keyboardType = .NumberPad
            }
            self.titleLabel.text = self.billingCountry.titleDescription()
        }
    }
    
    override func setupView() {
        super.setupView()
        self.textField().keyboardType = .Default
        self.textField().autocapitalizationType = .AllCharacters
        self.textField().autocorrectionType = .No
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // only handle delegate calls for own textfield
        guard textField == self.textField() else { return false }
        
        // get old and new text
        let oldString = textField.text!
        let newString = (oldString as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if newString.characters.count == 0 {
            return true
        }
        
        switch billingCountry {
        case .UK:
            return newString.isAlphaNumeric() && newString.characters.count <= 8
        case .Canada:
            return newString.isAlphaNumeric() && newString.characters.count <= 6
        case .USA:
            return newString.isNumeric() && newString.characters.count <= 5
        default:
            return newString.isNumeric() && newString.characters.count <= 8
        }
    }

    // MARK: Custom methods
    
    override func textFieldDidChangeValue(textField: UITextField) {
        super.textFieldDidChangeValue(textField)

        guard let newString = self.textField().text?.uppercaseString else { return }

        let usaRegex = try! NSRegularExpression(pattern: kUSARegexString, options: .AnchorsMatchLines)
        let ukRegex = try! NSRegularExpression(pattern: kUKRegexString, options: .AnchorsMatchLines)
        let canadaRegex = try! NSRegularExpression(pattern: kCanadaRegexString, options: .AnchorsMatchLines)
        
        var isValid = false
        
        switch billingCountry {
        case .UK:
            isValid = ukRegex.numberOfMatchesInString(newString, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, newString.characters.count)) > 0
        case .Canada:
            isValid = canadaRegex.numberOfMatchesInString(newString, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, newString.characters.count)) > 0 && newString.characters.count == 6
        case .USA:
            isValid = usaRegex.numberOfMatchesInString(newString, options: NSMatchingOptions.WithoutAnchoringBounds, range: NSMakeRange(0, newString.characters.count)) > 0
        case .Other:
            isValid = newString.isNumeric() && newString.characters.count <= 8
        }
        
        self.delegate?.judoPayInput(self, isValid: isValid)
    }
    
    override func title() -> String {
        return self.billingCountry.titleDescription()
    }
    
    override func titleWidth() -> Int {
        return 120
    }
    
    override func hintLabelText() -> String {
        return "Post Code Input Hinttext"
    }

}
