import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PerferenceWindow: NSWindowController, NSWindowDelegate, NSTableViewDataSource {
    var delegate: PreferencesWindowDelegate?
    var db: Database? = nil
    
    @IBOutlet weak var refreshRateTextField: NSTextField!
    @IBOutlet weak var tagTextField: NSTextField!
    @IBOutlet weak var tableTags: NSTableView!
    
    
    override var windowNibName : String! {
        return "PerferenceWindow"
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        let defaults = UserDefaults.standard
        let tag = defaults.string(forKey: "tag") ?? DEFAULT_TAG
        let refresh = defaults.string(forKey: "refresh") ?? DEFAULT_REFRESH_RATE
        
        tagTextField.stringValue = tag
        refreshRateTextField.stringValue = refresh
        NSApp.activate(ignoringOtherApps: true)
    }
    
    
    func dialogOKCancel(question: String, text: String) {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @IBAction func clearButtonPressed(_ sender: Any) {
        if (db != nil) {
            db?.clearDB()
            dialogOKCancel(question:"pr0grammNotifier", text:"Cache cleared!")
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        
        let onlyIntFormatter = OnlyIntegerValueFormatter()
        let defaults = UserDefaults.standard
        let tag = defaults.string(forKey: "tag") ?? DEFAULT_TAG
        let refresh = defaults.string(forKey: "refresh") ?? DEFAULT_REFRESH_RATE
        
        tagTextField.stringValue = tag
        refreshRateTextField.stringValue = refresh
        refreshRateTextField.formatter = onlyIntFormatter
    }
    
    
    func windowWillClose(_ notification: Notification) {
        let defaults = UserDefaults.standard
        let refreshRateInt = Int(refreshRateTextField.stringValue)
        defaults.setValue(tagTextField.stringValue, forKey: "tag")
        if ((refreshRateInt != nil) && (refreshRateInt! > 0)) {
            defaults.setValue(refreshRateTextField.stringValue, forKey: "refresh")
        } else {
            defaults.setValue(DEFAULT_REFRESH_RATE, forKey: "refresh")
        }
        
        
        delegate?.preferencesDidUpdate()
    }
    
}
