//
//  main.swift
//  NetworkMonitor
//
//  Created by Steven Rockarts on 2024-10-05.
//

import Foundation
import NetworkMonitor

print("Network monitoring started. Press enter to exit.")
NetworkMonitor.shared.startMonitoring()

// Make a sample network request
let url = URL(string: "https://api.thedogapi.com/v1/images/search")!
let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
    if let error = error {
        print("Main completion handler - Error: \(error.localizedDescription)")
    } else if let data = data {
        print("Main completion handler - Received data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
    }
}
task.resume()

// Keep the app running
_ = readLine()
