import Cocoa

class UpdateNotifier: NSWindowController {

    @IBOutlet weak var versionTextField: NSTextField!
    @IBOutlet weak var featuresLabel: NSTextField!
    
    override var windowNibName : String! {
        return "UpdateNotifier"
    }
    
    func setData(version:String, features:[String]) {
        var featuresString = ""
        versionTextField.stringValue = version;
        for f in features {
            featuresString += "* " + f + "\n\n"
        }
        featuresLabel.stringValue = featuresString
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        NSApp.activate(ignoringOtherApps: true)
    }
    
}
