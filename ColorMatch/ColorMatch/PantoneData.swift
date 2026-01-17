//
//  PantoneData.swift
//  ColorMatch
//
//  Created by Esther Ramos on 17/10/25.
//

import Foundation
import UIKit

class PantoneData {
    static let colors: [PantoneColor] = [
        // Classic Pantone Colors
        PantoneColor(id: "p1", name: "Classic Blue", hex: "#0F4C81", rgb: RGBColor(r: 15, g: 76, b: 129), pantoneCode: "19-4052", year: 2020),
        PantoneColor(id: "p2", name: "Living Coral", hex: "#FF6F61", rgb: RGBColor(r: 255, g: 111, b: 97), pantoneCode: "16-1546", year: 2019),
        PantoneColor(id: "p3", name: "Ultra Violet", hex: "#6B5B95", rgb: RGBColor(r: 107, g: 91, b: 149), pantoneCode: "18-3838", year: 2018),
        PantoneColor(id: "p4", name: "Greenery", hex: "#88B04B", rgb: RGBColor(r: 136, g: 176, b: 75), pantoneCode: "15-0343", year: 2017),
        PantoneColor(id: "p5", name: "Rose Quartz", hex: "#F7CAC9", rgb: RGBColor(r: 247, g: 202, b: 201), pantoneCode: "13-1520", year: 2016),
        PantoneColor(id: "p6", name: "Serenity", hex: "#91A8D0", rgb: RGBColor(r: 145, g: 168, b: 208), pantoneCode: "15-3919", year: 2016),
        PantoneColor(id: "p7", name: "Marsala", hex: "#955251", rgb: RGBColor(r: 149, g: 82, b: 81), pantoneCode: "18-1438", year: 2015),
        PantoneColor(id: "p8", name: "Radiant Orchid", hex: "#B565A7", rgb: RGBColor(r: 181, g: 101, b: 167), pantoneCode: "18-3224", year: 2014),
        
        // Additional popular Pantone colors
        PantoneColor(id: "p9", name: "Emerald", hex: "#009473", rgb: RGBColor(r: 0, g: 148, b: 115), pantoneCode: "17-5641", year: 2013),
        PantoneColor(id: "p10", name: "Tangerine Tango", hex: "#DD4124", rgb: RGBColor(r: 221, g: 65, b: 36), pantoneCode: "17-1463", year: 2012),
        PantoneColor(id: "p11", name: "Honeysuckle", hex: "#D65076", rgb: RGBColor(r: 214, g: 80, b: 118), pantoneCode: "18-2120", year: 2011),
        PantoneColor(id: "p12", name: "Turquoise", hex: "#45B8AC", rgb: RGBColor(r: 69, g: 184, b: 172), pantoneCode: "15-5519", year: 2010),
        PantoneColor(id: "p13", name: "Mimosa", hex: "#EFC050", rgb: RGBColor(r: 239, g: 192, b: 80), pantoneCode: "14-0848", year: 2009),
        PantoneColor(id: "p14", name: "Blue Iris", hex: "#5A5B9F", rgb: RGBColor(r: 90, g: 91, b: 159), pantoneCode: "18-3943", year: 2008),
        PantoneColor(id: "p15", name: "Chili Pepper", hex: "#9B1B30", rgb: RGBColor(r: 155, g: 27, b: 48), pantoneCode: "19-1557", year: 2007),
        
        // Basic colors for better matching
        PantoneColor(id: "b1", name: "True Red", hex: "#BF1932", rgb: RGBColor(r: 191, g: 25, b: 50), pantoneCode: "19-1664", year: nil),
        PantoneColor(id: "b2", name: "Sun Yellow", hex: "#FEDD00", rgb: RGBColor(r: 254, g: 221, b: 0), pantoneCode: "14-0852", year: nil),
        PantoneColor(id: "b3", name: "Green Flash", hex: "#79C753", rgb: RGBColor(r: 121, g: 199, b: 83), pantoneCode: "16-6340", year: nil),
        PantoneColor(id: "b4", name: "Blue Depths", hex: "#263056", rgb: RGBColor(r: 38, g: 48, b: 86), pantoneCode: "19-3929", year: nil),
        PantoneColor(id: "b5", name: "Pure White", hex: "#FFFFFF", rgb: RGBColor(r: 255, g: 255, b: 255), pantoneCode: "11-0601", year: nil),
        PantoneColor(id: "b6", name: "Jet Black", hex: "#000000", rgb: RGBColor(r: 0, g: 0, b: 0), pantoneCode: "19-0303", year: nil),
        PantoneColor(id: "b7", name: "Warm Gray", hex: "#D6D2C4", rgb: RGBColor(r: 214, g: 210, b: 196), pantoneCode: "14-4105", year: nil),
        PantoneColor(id: "b8", name: "Cool Gray", hex: "#D0D0CE", rgb: RGBColor(r: 208, g: 208, b: 206), pantoneCode: "14-4102", year: nil),
    ]
    
    static func getTopMatches(for color: UIColor, count: Int = 5) -> [PantoneColor] {
        var distances: [(color: PantoneColor, distance: Double)] = []
        
        let colorRGB = color.rgbComponents
        
        for pantone in colors {
            let distance = PantoneData.colorDistance(
                r1: Double(colorRGB.r), g1: Double(colorRGB.g), b1: Double(colorRGB.b),
                r2: Double(pantone.rgb.r), g2: Double(pantone.rgb.g), b2: Double(pantone.rgb.b)
            )
            distances.append((pantone, distance))
        }
        
        return distances
            .sorted { $0.distance < $1.distance }
            .prefix(count)
            .map { $0.color }
    }
    
    // Helper function for color distance calculation
    private static func colorDistance(r1: Double, g1: Double, b1: Double,
                                      r2: Double, g2: Double, b2: Double) -> Double {
        // Simple Euclidean distance
        let dr = r1 - r2
        let dg = g1 - g2
        let db = b1 - b2
        return sqrt(dr * dr + dg * dg + db * db)
    }
}
