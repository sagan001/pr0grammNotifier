import Foundation
import SQLite

class Database {
    var db: Connection? = nil
    
    init(database:Connection) {
        db = database
    }
    
    func clearDB() {
        do {
            try db!.execute("DELETE FROM items")
        } catch {
            print("delete error",error)
        }
    }
    
    func createDB() {
        do {
            try db!.execute("CREATE TABLE IF NOT EXISTS items (id integer PRIMARY KEY,image text NOT NULL,user text NOT NULL)")
        } catch {
            print("create error", error)
        }
    }
    
    func getNewestItem() -> Int {
        //var maxId = 0
        do {
            let maxId = try db!.scalar("select max(id) as maxid from items")
            if (maxId == nil) {
                return 0
            }
            let optionalCount : Int64 = Optional(maxId) as! Int64
            return Int(optionalCount)
        } catch {
            return 0
        }
    }
    
    func getItemById(id:Int) -> Int {
        do {
            let sql = "select count(*) from items where id = " + String(id)
            let maxId = try db!.scalar(sql)
            if (maxId == nil) {
                return 0
            }
            let optionalCount : Int64 = Optional(maxId) as! Int64
            return Int(optionalCount)
        } catch {
            return 0
        }
    }
    
    func insertItem(it:Item) {
        let indexOfItem = getItemById(id: it.id)
        if (indexOfItem == 0) {
            let sql = "INSERT INTO items ('id','image', 'user') VALUES (" + String(it.id) + ",'" + it.image! + "','" + it.user! + "')"
            do {
                try db!.execute(sql)
            } catch {
                
            }
        }
    }
}
