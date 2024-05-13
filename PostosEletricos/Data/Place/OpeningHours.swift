//
//  OpeningHours.swift
//  PostosEletricos
//
//  Created by Ramon Santos on 08/05/24.
//

import Foundation

// MARK: - OpeningHours

struct OpeningHours: Codable, Equatable, Hashable {
    
    let openNow: Bool?
    let periods: [Period]?
    let weekdayText: [String]?

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case periods
        case weekdayText = "weekday_text"
    }

    init(
        openNow: Bool? = nil,
        periods: [Period]? = nil,
        weekdayText: [String]? = nil
    ) {
        self.openNow = openNow
        self.periods = periods
        self.weekdayText = weekdayText
    }
}

struct Period: Codable, Equatable, Hashable {
    let open: PeriodDayAndTime?
    let close: PeriodDayAndTime?
}

struct PeriodDayAndTime: Codable, Equatable, Hashable {
    let date: String?
    let day: Int?
    let time: String?
    let truncated: Bool?

    init(
        date: String? = nil,
        day: Int? = nil,
        time: String? = nil,
        truncated: Bool? = nil
    ) {
        self.date = date
        self.day = day
        self.time = time
        self.truncated = truncated
    }
}

extension Period {
    func dayOfWeek() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "e"

        if let openDay = self.open?.day,
           let closeDay = self.close?.day,
           closeDay == openDay {
            if let date = formatter.date(from: String(openDay)) {
                formatter.dateFormat = "EEEE"
                return formatter.string(from: date)
            }
        } else if let openDay = self.open?.day {
            if let date = formatter.date(from: String(openDay)) {
                formatter.dateFormat = "EEEE"
                return formatter.string(from: date)
            }
        } else if let closeDay = self.close?.day {
            if let date = formatter.date(from: String(closeDay)) {
                formatter.dateFormat = "EEEE"
                return formatter.string(from: date)
            }
        }
        return ""
    }

    func formattedOpenTime() -> String {
        return formatTime(time: self.open?.time ?? "")
    }

    func formattedCloseTime() -> String {
        return formatTime(time: self.close?.time ?? "")
    }

    private func formatTime(time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        return ""
    }
}
