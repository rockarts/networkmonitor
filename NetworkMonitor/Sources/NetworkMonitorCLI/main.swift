import Foundation
import NetworkMonitor


Task {
    await NetworkMonitor.shared.startMonitoring()
}

let url = URL(string: "https://api.thedogapi.com/v1/images/search")!
let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
    if let error = error {
        print("Main completion handler - Error: \(error.localizedDescription)")
    } else if let data = data {
        print("Main completion handler - Received data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
    }
}
task.resume()

_ = readLine()

Task {
    await NetworkMonitor.shared.stopMonitoring()
    exit(0)
}

RunLoop.main.run()
