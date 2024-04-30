//
//  Date+Ext.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 29/04/24.
//

import Foundation

extension Date {
    func convertToMonthYearFormat() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyy"
        return dateFormatter.string(from: self)
    }
    
    func convertToDisplayFormat() -> String {
        guard let date = self.convertToMonthYearFormat() else { return "N/A" }
        return date
    }
}
