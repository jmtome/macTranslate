//
//  TableViewController.swift
//  BarTranslate
//
//  Created by Juan Manuel Tome on 25/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import Cocoa

class TableViewController: NSViewController {
    
    @IBOutlet var tableView: NSTableView!
    var translations: [String:String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do view setup here.
    }
    
    @IBAction func dismiss(_ sender: NSButton) {
        self.dismiss(self)
    }
}



extension TableViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return translations.count
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let key = Array(self.translations.keys)[row]
        let value = self.translations[key]
        
        let columnIdentifier = tableColumn?.identifier
        
        if columnIdentifier == NSUserInterfaceItemIdentifier(rawValue: "wordColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "wordCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = key
            return cellView
        }
        if columnIdentifier == NSUserInterfaceItemIdentifier(rawValue: "translationColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "translationCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = value!
            return cellView
        } else {
            return nil
        }
   
    }
    
}
