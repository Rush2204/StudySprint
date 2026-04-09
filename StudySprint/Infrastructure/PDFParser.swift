//
//  PDFParser.swift
//  StudySprint
//

import PDFKit
import Vision
import UIKit

struct PDFParser {
    
    static func extractText(from pdf: PDFDocument, pageRange: String, useOCRIfNeeded: Bool = true) async -> String {
        let pages = parsePageRange(pageRange, totalPages: pdf.pageCount)
        var allText = ""
        
        for pageNumber in pages {
            guard let page = pdf.page(at: pageNumber - 1) else { continue }
            
            if let directText = page.string, !directText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                allText += directText + "\n\n"
            } else if useOCRIfNeeded {
                let ocrText = await extractTextFromPageWithOCR(page: page, pageNumber: pageNumber)
                allText += ocrText + "\n\n"
            }
        }
        
        return allText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func extractTextFromPageWithOCR(page: PDFPage, pageNumber: Int) async -> String {
        guard let image = convertPDFPageToImage(page: page) else {
            return ""
        }
        return await recognizeText(from: image)
    }
    
    private static func convertPDFPageToImage(page: PDFPage) -> UIImage? {
        let pageBounds = page.bounds(for: .mediaBox)
        let scale: CGFloat = 2.0
        let imageSize = CGSize(width: pageBounds.width * scale, height: pageBounds.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        let image = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fill(CGRect(origin: .zero, size: imageSize))
            ctx.cgContext.translateBy(x: 0, y: imageSize.height)
            ctx.cgContext.scaleBy(x: scale, y: -scale)
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
        
        return image
    }
    
    private static func recognizeText(from image: UIImage) async -> String {
        return await withCheckedContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: "")
                return
            }
            
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    print("Error en OCR: \(error.localizedDescription)")
                    continuation.resume(returning: "")
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                let recognizedText = extractTextWithStructure(from: observations)
                continuation.resume(returning: recognizedText)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["es", "en"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("Error al ejecutar OCR: \(error.localizedDescription)")
                    continuation.resume(returning: "")
                }
            }
        }
    }
    
    private static func extractTextWithStructure(from observations: [VNRecognizedTextObservation]) -> String {
        let sortedObservations = observations.sorted { obs1, obs2 in
            let y1 = obs1.boundingBox.minY
            let y2 = obs2.boundingBox.minY
            let x1 = obs1.boundingBox.minX
            let x2 = obs2.boundingBox.minX
            
            if abs(y1 - y2) < 0.02 {
                return x1 < x2
            }
            return y1 > y2
        }
        
        var result = ""
        var lastY: CGFloat = -1
        var lineTexts: [String] = []
        
        for observation in sortedObservations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            let currentY = observation.boundingBox.minY
            
            if lastY > 0 && abs(currentY - lastY) > 0.02 {
                result += lineTexts.joined(separator: " ") + "\n"
                lineTexts.removeAll()
            }
            
            lineTexts.append(topCandidate.string)
            lastY = currentY
        }
        
        if !lineTexts.isEmpty {
            result += lineTexts.joined(separator: " ")
        }
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func parsePageRange(_ range: String, totalPages: Int) -> [Int] {
        var pages: [Int] = []
        let components = range.split(separator: ",")
        
        for component in components {
            let trimmed = component.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("-") {
                let bounds = trimmed.split(separator: "-")
                if bounds.count == 2,
                   let start = Int(bounds[0]),
                   let end = Int(bounds[1]) {
                    let clampedEnd = min(end, totalPages)
                    pages.append(contentsOf: start...clampedEnd)
                }
            } else if let page = Int(trimmed), page <= totalPages {
                pages.append(page)
            }
        }
        
        return pages.sorted()
    }
}
