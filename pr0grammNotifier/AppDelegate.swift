import Cocoa
import UserNotifications
import SQLite

let DEFAULT_TAG = "Achtung Scheiße"
let DEFAULT_REFRESH_RATE = "60"
let VERSION = "1.1.0"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate, PreferencesWindowDelegate {
    var i = 0
    
    var dbPath: String = ""
    var db: Connection? = nil
    var database: Database? = nil
    var preferencesWindow: PerferenceWindow!
    var newestItem : Item? = nil
    var timer: Timer? = nil
    var updateNotifierWindow : UpdateNotifier!
    
    
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @IBAction func preferencesClicked(_ sender: Any) {
        preferencesWindow.db = database
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    func initFunction() {
        dbPath = Utils.createDBFile()
        do {
            db = try Connection(dbPath)
            database = Database(database: db!)
            database!.createDB()
            database!.clearDB()
        } catch {
            
        }
    }
    
    func checkUpdate() {
        updateNotifierWindow = UpdateNotifier()
        let updater = Updater(version:VERSION)
        updater.checkUpdate(callback:{(version, features) in
            DispatchQueue.main.async { // Make sure you're on the main thread here
                self.updateNotifierWindow.showWindow(nil)
                self.updateNotifierWindow.setData(version: version, features: features)
            }
            
        })
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if (newestItem != nil) {
            let id = newestItem?.id
            let strURL = "https://pr0gramm.com/new/" + String(id!)
            let url = URL(string: strURL)!
            NSWorkspace.shared.open(url)
        }
    }
    
    func preferencesDidUpdate() {
        createTimer()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
       
        let icon = NSImage(named: "statusIcon")
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        preferencesWindow = PerferenceWindow()
        preferencesWindow.delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (permissionGranted, error) in
        }

        let mathQuizCategory = UNNotificationCategory(identifier: "mathQuizCategory", actions: [], intentIdentifiers: [], options: [])

        UNUserNotificationCenter.current().setNotificationCategories([mathQuizCategory])
        UNUserNotificationCenter.current().delegate = self
        initFunction()
        
        createTimer()
        
        checkUpdate()
    }
    
    func createTimer() {
        let defaults = UserDefaults.standard
        let tag = defaults.string(forKey: "tag") ?? DEFAULT_TAG
        let refreshRate = defaults.string(forKey: "refresh") ?? DEFAULT_REFRESH_RATE
        let escapedTag = tag.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let urlstring = "https://pr0gramm.com/api/items/get?flags=1&tags=" + escapedTag!

        if (timer != nil) {
            timer!.invalidate()
            timer = nil
        }
        
        var refreshRateInt = Int(refreshRate)
        
        if ((refreshRateInt == nil) || (refreshRateInt! < 1)) {
            refreshRateInt = Int(DEFAULT_REFRESH_RATE)
        }
        
        self.getJSON(url:urlstring, database: database!, tag:tag)
        
        timer = Timer.scheduledTimer(withTimeInterval: Double(refreshRateInt!), repeats: true) { timer in
            self.getJSON(url:urlstring, database: self.database!, tag:tag)
        }
    }
    
    

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func getJSON(url:String, database: Database, tag:String) {
        
        let url = URL(string: url)!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            do {
                let jsonDecoder = JSONDecoder()
                let itemsFeed = try jsonDecoder.decode(ItemFeed.self, from: data)
                let maxItem = Utils.getMaximumItem(itemfeed:itemsFeed)
                let maxDBItem = database.getNewestItem()
                
                if (maxItem == nil) {
                    return
                }
                
                if (maxItem!.id > maxDBItem) {
                    self.newestItem = maxItem!
                    Utils.notification(title:"pr0grammNotifier", subtitle:"New Post : " + String(maxItem!.id) + " from " + maxItem!.user!, tag:"Tag: " + tag)
                }
                
                for it in itemsFeed.items {
                    database.insertItem(it: it)
                }
                
            } catch {
                print("JSONSerialization error:", error)
            }
        }

        task.resume()
    }
    
   
    
    
}

