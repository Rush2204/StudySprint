//
//  String+Extensions.swift
//  StudySprint
//

import Foundation

extension String {
    var words: [String] {
        return components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
    }
    
    var characterCount: Int {
        return count
    }
    
    var wordCount: Int {
        return words.count
    }
    
    func removingExtraSpaces() -> String {
        return replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func removingEmptyLines() -> String {
        return components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
    }
    
    // Función para eliminar líneas que contienen "--- Página"
    func removingPageMarkers() -> String {
        let lines = self.components(separatedBy: .newlines)
        let filteredLines = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return !trimmed.hasPrefix("--- Página")
        }
        return filteredLines.joined(separator: "\n")
    }
    }

