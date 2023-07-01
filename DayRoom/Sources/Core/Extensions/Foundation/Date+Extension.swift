//
//  String+Formatted.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/19.
//

import Foundation

public extension Date {
    init(dateString: String, format: String = "yyyy. MM. dd") {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIZ") as Locale
        let date = formatter.date(from: dateString)!
        self.init(timeInterval: 0, since: date)
    }
    
    var dayroomMonth: String {
        let formatter: DateFormatter = .init()
        formatter.dateStyle = .medium
        return self.toString(format: "MMMM, yyyy", formatter: formatter)
    }
    
    func toString(format: String, formatter: DateFormatter = .init()) -> String {
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var year: Int {
        Calendar.current.dateComponents(in: .current, from: self).year!
    }
    
    var month: Int {
        Calendar.current.dateComponents(in: .current, from: self).month!
    }
    
    var day: Int {
        Calendar.current.dateComponents(in: .current, from: self).day!
    }
    
    var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    func isSameDay(_ date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func dday(_ endDate: Date) -> Int {
        Calendar.current.dateComponents([.day], from: self, to: endDate).day ?? 0
    }
    
    static var today: Self { return .init() }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var isToday: Bool {
        Date.today.startOfDay.isSameDay(startOfDay)
    }
    
    var isPastDay: Bool {
        Date.today.startOfDay.dday(startOfDay) <= 0
    }
    
    var isFutureDay: Bool {
        Date.today.startOfDay.dday(startOfDay) > 0
    }
    
    private func weekday(_ calendar: Calendar = .current) -> Int {
        return calendar.component(.weekday, from: self)
    }
    
    var weekday: Weekday {
        return Weekday(rawValue: weekday()) ?? .sunday
    }
    
    enum Weekday: Int, Identifiable {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
        
        public var id: Self { self }
        
        public var korean: String {
            switch self {
            case .sunday: return "일요일"
            case .monday: return "월요일"
            case .tuesday: return "화요일"
            case .wednesday: return "수요일"
            case .thursday: return "목요일"
            case .friday: return "금요일"
            case .saturday: return "토요일"
            }
        }
        
        public var english: String {
            switch self {
            case .sunday: return "sunday"
            case .monday: return "monday"
            case .tuesday: return "tuesday"
            case .wednesday: return "wednesday"
            case .thursday: return "thursday"
            case .friday: return "friday"
            case .saturday: return "saturday"
            }
        }
    }
}
