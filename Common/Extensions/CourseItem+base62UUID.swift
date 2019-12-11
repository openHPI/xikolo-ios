//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension CourseItem {

    enum UUIDConversionError: Error {
        case invalidCharacter
    }

    static var base16Alphabet = "0123456789abcdef"
    static var base62Alphabet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

    public static func base62UUID(forUUID uuid: String) -> String? {
        let compactUUID = uuid.replacingOccurrences(of: "-", with: "")
        guard let base10Value = parseString(compactUUID, alphabet: Self.base16Alphabet) else { return nil }
        return try? self.parseDecimal(base10Value, alphabet: Self.base62Alphabet)
    }

    public static func uuid(forBase62UUID base62UUID: String) -> String? {
        guard let base10Value = self.parseString(base62UUID, alphabet: Self.base62Alphabet) else { return nil }

        guard var compactUUID = try? self.parseDecimal(base10Value, alphabet: Self.base16Alphabet) else { return nil }
        guard compactUUID.count == 32 else { return nil }

        compactUUID.insert("-", at: compactUUID.index(compactUUID.startIndex, offsetBy: 8))
        compactUUID.insert("-", at: compactUUID.index(compactUUID.startIndex, offsetBy: 13))
        compactUUID.insert("-", at: compactUUID.index(compactUUID.startIndex, offsetBy: 18))
        compactUUID.insert("-", at: compactUUID.index(compactUUID.startIndex, offsetBy: 23))

        return compactUUID
    }

    private static func parseString(_ string: String, alphabet: String) -> Decimal? {
        let digits = Array(alphabet)
        let base = Decimal(alphabet.count)

        var result = Decimal(0)

        for (postion, char) in string.reversed().enumerated() {
            guard let index = digits.firstIndex(of: char) else { return nil }
            result += Decimal(index) * pow(base, postion)
        }

        return result
    }

    private static func parseDecimal(_ decimal: Decimal, alphabet: String) throws -> String {
        let digits = Array(alphabet)
        let base = Decimal(alphabet.count)

        if decimal < base {
            let index = (decimal as NSDecimalNumber).intValue
            return String(digits[index])
        }

        var newDecimal = Decimal()
        var newValue = decimal / base
        NSDecimalRound(&newDecimal, &newValue, 0, .down)
        let remainder = decimal - (newDecimal * base)

        if remainder < base {
            let index = (remainder as NSDecimalNumber).intValue
            return try self.parseDecimal(newDecimal, alphabet: alphabet) + String(digits[index])
        } else {
            throw UUIDConversionError.invalidCharacter
        }
    }

    public var base62id: String? {
        return Self.base62UUID(forUUID: self.id)
    }

}
