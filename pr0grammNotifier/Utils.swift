import Cocoa
import UserNotifications

class Utils {
    static func getMaximumItem(itemfeed:ItemFeed) -> Item? {
        var retItem: Item? = nil
        var maxId = 0
        
        for obj in itemfeed.items {
            if (maxId < obj.id) {
                maxId = obj.id
                retItem = obj
            }
        }
        
        return retItem
    }
    
    static func createDBFile() -> String {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
           let fileURL = documentsDirectory.appendingPathComponent("notifier.db")
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try "".write(to: fileURL, atomically: true, encoding: .utf8)
                } catch {
                    print(error)
                }
            }
            return fileURL.path
        } else {
            return "notifier.db"
        }
        
    }
    
    static func notification(title:String, subtitle:String, tag:String) {
        let mathContent = UNMutableNotificationContent()
        mathContent.title = title
        mathContent.subtitle = subtitle
        mathContent.body = tag
        mathContent.badge = 1
        mathContent.categoryIdentifier = "mathQuizCategory"
        mathContent.sound = UNNotificationSound.default
        
        let quizTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let quizRequestIdentifier = "mathQuiz"
        let request = UNNotificationRequest(identifier: quizRequestIdentifier, content: mathContent, trigger: quizTrigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            //11 -
            print(error as Any)
        }
    }
}


