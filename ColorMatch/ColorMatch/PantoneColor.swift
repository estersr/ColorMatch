//
//  PantoneColor.swift
//  ColorMatch
//
//  Created by Esther Ramos on 17/10/25.
//

//
//  PantoneColor.swift
//  ColorMatch
//
//  Created by Esther Ramos on 17/10/25.
//

import Foundation
import SwiftUI

struct RGBColor: Codable {
    let r: Int
    let g: Int
    let b: Int
}

struct PantoneColor: Identifiable, Codable {
    let id: String
    let name: String
    let hex: String
    let rgb: RGBColor
    let pantoneCode: String
    let year: Int?
    
    // For backward compatibility
    var r: Int { rgb.r }
    var g: Int { rgb.g }
    var b: Int { rgb.b }
    
    var color: Color {
        Color(hex: hex)
    }
    
    var uiColor: UIColor {
        UIColor(hex: hex)
    }
}

// Extension for Color conversion
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255))
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255,
                  green: CGFloat(g) / 255,
                  blue: CGFloat(b) / 255,
                  alpha: CGFloat(a) / 255)
    }
}

// Color matching utilities
struct ColorMatch {
    static func findClosestPantone(to color: UIColor, from colors: [PantoneColor]) -> PantoneColor? {
        guard !colors.isEmpty else { return nil }
        
        var closestColor: PantoneColor?
        var smallestDistance = Double.greatestFiniteMagnitude
        
        let colorRGB = color.rgbComponents
        
        for pantone in colors {
            let distance = colorDistance(
                r1: Double(colorRGB.r), g1: Double(colorRGB.g), b1: Double(colorRGB.b),
                r2: Double(pantone.rgb.r), g2: Double(pantone.rgb.g), b2: Double(pantone.rgb.b)
            )
            
            if distance < smallestDistance {
                smallestDistance = distance
                closestColor = pantone
            }
        }
        
        return closestColor
    }
    
    private static func colorDistance(r1: Double, g1: Double, b1: Double,
                                      r2: Double, g2: Double, b2: Double) -> Double {
        // Using CIEDE2000 would be more accurate, but this is simpler
        let dr = r1 - r2
        let dg = g1 - g2
        let db = b1 - b2
        return sqrt(dr * dr + dg * dg + db * db)
    }
}

extension UIColor {
    var rgbComponents: (r: Int, g: Int, b: Int) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Int(r * 255), Int(g * 255), Int(b * 255))
    }
}


