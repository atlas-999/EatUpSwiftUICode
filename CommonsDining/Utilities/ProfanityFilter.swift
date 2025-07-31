import Foundation

struct ProfanityFilter {
    static let vowelVariants: [Character: String] = [
        "a": "[a@*]",
        "e": "[e3*]",
        "i": "[i1!*|]",
        "o": "[o0*]",
        "u": "[u*]"
    ]

    static func generateAsteriskRegexPatterns(words: [String]) -> [String] {
        var patterns: [String] = []

        for phrase in words {
            let parts = phrase.lowercased().split(separator: " ")
            var transformedParts: [String] = []

            for part in parts {
                var regexPart = ""
                for char in part {
                    if let variant = vowelVariants[char] {
                        regexPart += variant
                    } else if char.isLetter || char.isNumber {
                        regexPart += NSRegularExpression.escapedPattern(for: String(char))
                    } else {
                        regexPart += NSRegularExpression.escapedPattern(for: String(char))
                    }
                }
                transformedParts.append(regexPart)
            }

            // Allow space, underscore, or nothing between parts
            let joiner = "(?:\\s*|_)?"
            let pattern = "\\b" + transformedParts.joined(separator: joiner) + "\\b"
            patterns.append(pattern)
        }

        return patterns
    }

    static func compileRegexPatterns(words: [String]) -> [NSRegularExpression] {
        let rawPatterns = generateAsteriskRegexPatterns(words: words)
        return rawPatterns.compactMap {
            try? NSRegularExpression(pattern: $0, options: [.caseInsensitive])
        }
    }

    static func isUsernameClean(_ username: String, compiledPatterns: [NSRegularExpression]) -> Bool {
        for pattern in compiledPatterns {
            let range = NSRange(username.startIndex..., in: username)
            if pattern.firstMatch(in: username, options: [], range: range) != nil {
                return false
            }
        }
        return true
    }
}
