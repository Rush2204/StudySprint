//
//  PDFUseCases.swift
//  StudySprint
//

import Foundation
import PDFKit
import Combine

protocol PDFUseCasesProtocol {
    func extractText(from pdf: PDFDocument, pageRange: String) async -> String
    func extractTextWithOCR(from pdf: PDFDocument, pageRange: String) async -> String
}

class PDFUseCases: PDFUseCasesProtocol {
    func extractText(from pdf: PDFDocument, pageRange: String) async -> String {
        return await PDFParser.extractText(from: pdf, pageRange: pageRange, useOCRIfNeeded: true)
    }
    
    func extractTextWithOCR(from pdf: PDFDocument, pageRange: String) async -> String {
        return await PDFParser.extractText(from: pdf, pageRange: pageRange, useOCRIfNeeded: true)
    }
}
