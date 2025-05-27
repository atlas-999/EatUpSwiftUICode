//
//  HourAndMinutw.swift
//  CommonsDining
//
//  Created by Caden Cooley on 4/12/25.
//

import Foundation

struct HourAndMinute {
    let hour: Int
    let minute: Int
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    func toString() -> String{
        var newHour = self.hour
        if newHour > 12 {
            newHour -= 12
        }
        return minute != 0 ? "\(newHour):\(self.minute)" : "\(newHour)"
    }
    
    static func ==(lhs: HourAndMinute, rhs: HourAndMinute) -> Bool {
        return lhs.hour == rhs.hour && rhs.minute == lhs.minute
    }
    
    static func >(lhs: HourAndMinute, rhs: HourAndMinute) -> Bool {
        if lhs.hour > rhs.hour {
            return true
        }
        else if lhs.hour == rhs.hour {
            if lhs.minute > rhs.minute {
                return true
            }
            else {
                return false
            }
        }
        return false
    }
    
    static func <(lhs: HourAndMinute, rhs: HourAndMinute) -> Bool {
        if lhs.hour < rhs.hour {
            return true
        }
        else if lhs.hour == rhs.hour {
            if lhs.minute < rhs.minute {
                return true
            }
            else {
                return false
            }
        }
        return false
    }
    
    static func >=(lhs: HourAndMinute, rhs: HourAndMinute) -> Bool {
        return lhs > rhs || lhs == rhs
    }
    
    static func <=(lhs: HourAndMinute, rhs: HourAndMinute) -> Bool {
        return lhs < rhs || lhs == rhs
    }
    
}
