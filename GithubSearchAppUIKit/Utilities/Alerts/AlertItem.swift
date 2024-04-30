//
//  AlertItem.swift
//  GithubSearchAppUIKit
//
//  Created by Reinaldo Camargo on 26/04/24.
//

import SwiftUI

struct AlertItem {
    let id = UUID()
    let title: String
    let message: String
}

struct AlertItemContext {
    //MARK: - Network error messages
    static let invalidURL = AlertItem(title: "Server Error",
                                      message: "The data received from server was invalid.")
    static let invalidResponse = AlertItem(title: "Server Error",
                                           message: "Invalid response from the server. Please try again later or contact support.")
    static let invalidData = AlertItem(title: "Server Error",
                                       message: "There was an issue connecting to the server. Invalid data returned.")
    static let unableToComplete = AlertItem(title: "Server Error",
                                            message: "Unable to complete your request at this time. Please check again later.")
    static let defaultError = AlertItem(title: "Server Error",
                                            message: "Unable to connect to the server. Please verify you connection.")
    
    //MARK: - GithubUser URL error messages
    static let invalidGithubUserURL = AlertItem(title: "Invalid URL",
                                            message: "The url attached  to this user is invalid.")
    
    //MARK: - GithubUser has no followers
    static let noFollowers = AlertItem(title: "No followers",
                                            message: "This user has no followers.")
}
