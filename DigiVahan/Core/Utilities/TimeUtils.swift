//
//  TimeUtils.swift
//  DigiVahan
//
//  Created by Mr Ash on 14/06/26.
//

import Foundation

class TimeUtils {

    static let knownFormats = [
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
        "yyyy-MM-dd HH:mm:ss",
        "yyyy-MM-dd HH:mm",
        "yyyy-MM-dd hh:mm:ss a",
        "yyyy-MM-dd hh:mm a",
        "dd-MM-yyyy HH:mm:ss",
        "dd-MM-yyyy HH:mm",
        "dd-MM-yyyy hh:mm:ss a",
        "dd-MM-yyyy hh:mm a",
        "MM/dd/yyyy HH:mm:ss",
        "MM/dd/yyyy hh:mm:ss a",
        "dd MMM yyyy HH:mm:ss",
        "dd MMM yyyy hh:mm:ss a",
        "EEE MMM dd HH:mm:ss z yyyy",
        "dd/MM/yyyy HH:mm:ss",
        "dd/MM/yyyy hh:mm:ss a",
        "dd/MM/yyyy HH:mm",
        "dd/MM/yyyy hh:mm a",
        "dd MMM yyyy, hh:mm a",
        "dd-MMM-yyyy",
        "yyyy-MM-dd",
        "dd-MM-yyyy",
        "MM/dd/yyyy",
        "dd MMM yyyy",
        "dd/MM/yyyy",
        "HH:mm:ss",
        "HH:mm",
        "hh:mm:ss a",
        "hh:mm a"
    ]

    static func parseDateSafely(_ dateString: String?) -> Date? {

        guard let dateString = dateString,
              !dateString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        for format in knownFormats {

            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale.current
            formatter.isLenient = false

            if let date = formatter.date(from: dateString) {
                return date
            }
        }

        return nil
    }

    static func calculateAge(from birthDate: Date) -> Int {

        let calendar = Calendar.current
        let today = Date()

        let age = calendar.dateComponents([.year], from: birthDate, to: today).year ?? 0

        return max(age, 0)
    }

    static func getDatePart(from dateString: String?, type: String?) -> String {

        guard let parsedDate = parseDateSafely(dateString),
              let type = type?.lowercased() else {
            return ""
        }

        let calendar = Calendar.current

        switch type {

        case "year":
            return String(calendar.component(.year, from: parsedDate))

        case "month":
            return String(calendar.component(.month, from: parsedDate))

        case "day", "date":
            return String(calendar.component(.day, from: parsedDate))

        case "hour":
            return String(calendar.component(.hour, from: parsedDate))

        case "minute":
            return String(calendar.component(.minute, from: parsedDate))

        case "second":
            return String(calendar.component(.second, from: parsedDate))

        case "age":
            return String(calculateAge(from: parsedDate))

        default:
            return ""
        }
    }
    
    // MARK: - Convert Date Format
    static func convertDateFormat(
        _ dateString: String?,
        outputFormat: String
    ) -> String {

        guard let dateString = dateString,
              let parsedDate = parseDateSafely(dateString) else {
            return dateString ?? ""
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputFormat
        outputFormatter.locale = Locale.current

        return outputFormatter.string(from: parsedDate)
    }
    
    
    // MARK: - Time Ago

        static func getTimeAgo(_ dateString: String?) -> String {

            guard let pastDate = parseDateSafely(dateString) else {
                return "Invalid date"
            }

            let now = Date()
            let diff = now.timeIntervalSince(pastDate)

            if diff < 0 {
                return "In the future"
            }

            let seconds = Int(diff)
            let minutes = seconds / 60
            let hours = minutes / 60
            let days = hours / 24

            if seconds < 60 {
                return "Just now"
            } else if minutes < 60 {
                return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
            } else if hours < 24 {
                return "\(hours) hour\(hours == 1 ? "" : "s") ago"
            } else if days == 1 {
                return "Yesterday"
            } else if days < 30 {
                return "\(days) days ago"
            } else if days < 365 {
                let months = days / 30
                return "\(months) month\(months == 1 ? "" : "s") ago"
            } else {
                let years = days / 365
                return "\(years) year\(years == 1 ? "" : "s") ago"
            }
        }


        // MARK: - Convert Date To Milliseconds

        static func convertDateToMillis(
            _ dateString: String?,
            format: String? = nil
        ) -> Int64 {

            var date: Date?

            if let format = format,
               let dateString = dateString {

                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale.current

                date = formatter.date(from: dateString)

            } else {

                date = parseDateSafely(dateString)
            }

            return Int64((date?.timeIntervalSince1970 ?? 0) * 1000)
        }

        // MARK: - Convert Timestamp To Date

        static func convertTimestampIntoDate(
            _ value: Int64,
            responseTitle: String
        ) -> String {

            let timestamp = value < 10000000000 ? value * 1000 : value

            let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)

            let formatter = DateFormatter()
            formatter.locale = Locale.current

            switch responseTitle.lowercased() {

            case "time":
                formatter.dateFormat = "hh:mm a"

            case "date":
                formatter.dateFormat = "dd-MM-yyyy"

            default:
                formatter.dateFormat = "dd-MM-yyyy hh:mm a"
            }

            return formatter.string(from: date)
        }

        // MARK: - 24 Hour To 12 Hour

        static func convert24HourTo12Hour(_ time: String?) -> String? {

            guard let date = parseDateSafely(time) else {
                return nil
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"

            return formatter.string(from: date)
        }

        // MARK: - Current Date

        static func getCurrentDate(_ format: String) -> String {

            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = .current
            formatter.locale = Locale.current

            return formatter.string(from: Date())
        }

        // MARK: - Is Date Expired

        static func isDateExpired(
            currentDateString: String?,
            targetDateString: String?
        ) -> Bool {

            guard let currentDate = parseDateSafely(currentDateString),
                  let targetDate = parseDateSafely(targetDateString)
            else {
                return true
            }

            return targetDate < currentDate
        }

        // MARK: - Days Difference

        static func getDaysDifference(
            _ startDateString: String?,
            _ endDateString: String?
        ) -> Int {

            guard let startDate = parseDateSafely(startDateString),
                  let endDate = parseDateSafely(endDateString)
            else {
                return 0
            }

            let diff = abs(endDate.timeIntervalSince(startDate))

            return Int(diff / (24 * 60 * 60))
        }
    
    // MARK: - Convert UTC To Device Local Time

    static func convertUtcToDeviceTime(
        _ utcTime: String?,
        outputFormat: String = "dd MMM yyyy, hh:mm a"
    ) -> String {

        guard let utcTime = utcTime,
              !utcTime.isEmpty else {
            return ""
        }

        let utcFormatter = DateFormatter()
        utcFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        utcFormatter.locale = Locale(identifier: "en_US_POSIX")
        utcFormatter.timeZone = TimeZone(abbreviation: "UTC")

        guard let date = utcFormatter.date(from: utcTime) else {
            print("❌ Failed to parse UTC time: \(utcTime)")
            return ""
        }

        let localFormatter = DateFormatter()
        localFormatter.dateFormat = outputFormat
        localFormatter.locale = Locale.current
        localFormatter.timeZone = .current

        let result = localFormatter.string(from: date)

        print("""
        ==========================
        UTC Time      : \(utcTime)
        Device Zone   : \(TimeZone.current.identifier)
        Local Time    : \(result)
        ==========================
        """)

        return result
    }
    
    
}
