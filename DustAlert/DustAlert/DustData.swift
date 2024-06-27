//
//  DustData.swift
//  DustAlert
//
//  Created by Florian Fourcade on 25/06/2024.
//
import Foundation

struct DustData: Codable, Identifiable {
    let id = UUID()
    let longitude: [Double]
    let latitude: [Double]
    let time: [Int]
    let duaod550: [[[Double]]]
    
    var averageDustLevel: Double {
        let flatArray = duaod550.flatMap { $0.flatMap { $0 } }
        let total = flatArray.reduce(0, +)
        return total / Double(flatArray.count)
    }

    var readableDate: String {
        return DateFormatter.localizedString(from: Date(timeIntervalSince1970: TimeInterval(time.first ?? 0)), dateStyle: .short, timeStyle: .short)
    }
}


struct CAMSResponse: Codable {
    let forecasts: [DustData]
}


struct DustForecast: Codable {
    let date: String
    let data: DustData
}
