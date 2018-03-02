//
//  ViewController.swift
//  SwiftExample
//
//  Created by Jason Chen on 17/02/18.
//  Copyright © 2018 Jason Chen. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var db: OpaquePointer?
    var heroList = [Hero]()
    
    @IBOutlet weak var tableViewHeroes: UITableView!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldPowerRanking: UITextField!
    
    @IBAction func buttonDelete(_ sender: UIButton) {
        let selectedIndex = IndexPath(row: sender.tag, section: 0)
        
        // And finally do whatever you need using this index :
        
        tableViewHeroes.selectRow(at: selectedIndex, animated: true, scrollPosition: .none)
        
        // Now if you need to access the selected cell instead of just the index path, you could easily do so by using the table view's cellForRow method
        
        let selectedCell = tableViewHeroes.cellForRow(at: selectedIndex)
        if (selectedCell == nil) {
            return
        }
        var name: String = (selectedCell?.textLabel?.text)!
        let temp = name.components(separatedBy: ":")
        name = temp[1].trimmingCharacters(in: .whitespaces)
        
        var stmt: OpaquePointer?
        
        // delete query statement
        let queryString = "DELETE FROM Heroes WHERE name='" + name + "'"
        
        // prepare the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing delete: \(errmsg)")
            return
        }
        
        // execute the query to delete value
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure deleting hero: \(errmsg)")
            return
        }
        
        readValues()
    }
    
    @IBAction func buttonSave(_ sender: UIButton) {
        // get name from textfield
        let name = textFieldName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        // get power ranking from textfield
        let powerRanking = textFieldPowerRanking.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // name validation
        if(name?.isEmpty)!{
            textFieldName.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        // power ranking validation
        if(powerRanking?.isEmpty)!{
            textFieldName.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        var stmt: OpaquePointer?
        
        // insert query statement
        let queryString = "INSERT INTO Heroes (name, powerrank) VALUES (?,?)"
        
        // prepare the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        // bind the name
        if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        // bind the power ranking
        if sqlite3_bind_int(stmt, 2, (powerRanking! as NSString).intValue) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }

        // execute the query to insert value
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        // reset the textfield
        textFieldName.text=""
        textFieldPowerRanking.text=""
        
        readValues()

        print("Herro saved successfully")
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heroList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let hero: Hero
        hero = heroList[indexPath.row]
        cell.textLabel?.text = "Name: " + hero.name!
        cell.detailTextLabel?.text = "Power Ranking: " + String(hero.powerRanking)
        return cell
    }
    
    func readValues(){
        // clear the list
        heroList.removeAll()

        // select query statement
        let queryString = "SELECT * FROM Heroes"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        // traverse through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let powerrank = sqlite3_column_int(stmt, 2)
            
            // add heroes to the list
            heroList.append(Hero(id: Int(id), name: String(describing: name), powerRanking: Int(powerrank)))
        }
        
        // reload the data
        self.tableViewHeroes.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
        // create local database in the phone
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("HeroesDatabase.sqlite")
        
        // open connection to database
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        // create the Heroes table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Heroes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, powerrank INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        readValues()
    }
}

