//
//  ViewController.swift
//  BarTranslate
//
//  Created by Juan Manuel Tome on 24/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {
    
    var model = Model()
    var translations: [String:String] = [String:String]()
    
    @IBOutlet var hitCount: NSTextField!
    var hitCountNumber: Int = 0 {
        didSet {
            hitCount.stringValue = "\(hitCountNumber)"
        }
    }
    let defaults = UserDefaults.standard
    let dummyDictionary = ["the car":"das auto","the woman":"die frau","my name is juan":"ich heiße juan","i come from argentina":"ich komme aus argentinien","i like chocolate":"ich mag chocolade"]
    @IBOutlet var inputType: NSSegmentedControl!
    @IBOutlet var outputType: NSSegmentedControl!
    @IBOutlet var input: NSTextField! {
        didSet {
            textToTranslate = input.stringValue
        }
    }
    @IBOutlet var output: NSTextField!
    
    var from: Language? = .English
    var to: Language? = .German
    
    var textToTranslate: String!
    var translatedText: String!
    
    var translation: Translation? {
        didSet {
            if let text = translation?.translatedText {
                translatedText = text
                output.stringValue = translatedText
            }
        }
    }
    var showQuitAlert: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserDefaults()
        //languageChangeFrom(self)
//        model.translate(from: self.from!, to: self.to!) { (translation) in
//            self.translatedText = translation
//        }
        //translations["hola"] = "chau"
        print(translations)
        model.delegate = self 
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func languageChangeFrom(_ sender: NSSegmentedControl) {
        
        print("change from \(sender.selectedSegment)")
        
        switch sender.selectedSegment {
        case 0:
            self.from = .English
        case 1:
            self.from = .German
        default:
            self.from = .Spanish
        }
    }
    @IBAction func languageChangeTo(_ sender: NSSegmentedControl) {
        print("change to \(sender.selectedSegment)")
        
        switch sender.selectedSegment {
        case 0:
            self.to = .English
        case 1:
            self.to = .German
        default:
            self.to = .Spanish
        }
    }
    @IBAction func showTable(_ sender: NSButton) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "myTableView") as? TableViewController else { fatalError()}
        
        vc.translations = self.translations
        self.presentAsSheet(vc)
//        self.presentAsModalWindow(vc)
        
        
    }
    @IBAction func copyToPasteboard(_ sender: Any) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(output.stringValue, forType: .string)
    }
    
    @IBAction func quitApp(_ sender: NSButton) {
        quitAlert(sender) { (shouldQuit) in
            if shouldQuit {
                self.saveUserDefaults()
                NSApplication.shared.terminate(self)
                print("quitted")
                
            } else {
                print("didnt quit")
            }
            
        }
    }
    
    func saveUserDefaults() {
        defaults.set(translations, forKey: "translations")
    }
    func loadUserDefaults() {
        self.translations = defaults.object(forKey: "translations") as? [String:String] ?? [String:String]()
    }
    
    @objc func handleQuitSuppressionButtonClick(_ sender: NSButton) {
        self.showQuitAlert = false
    }
    func quitAlert(_ sender: NSButton, completion: @escaping (Bool)-> Void) {
        if showQuitAlert {
            let alert = NSAlert()
            alert.messageText = "Are you sure you want to quit?"
            alert.informativeText = "Sure to quit?"
            alert.addButton(withTitle: "Yes")
            alert.addButton(withTitle: "No")
            alert.showsSuppressionButton = true
            alert.suppressionButton?.title = "Dont show again"
            alert.suppressionButton?.target = self
            alert.suppressionButton?.action = #selector(handleQuitSuppressionButtonClick(_:))
                
            alert.beginSheetModal(for: self.view.window!) { (modalResponse) in
                switch modalResponse {
                case .alertFirstButtonReturn:
                    completion(true)
                case .alertSecondButtonReturn:
                    completion(false)
                default:
                    print("pepe")
                }
            }
        }
        completion(true)
    }
    
    @IBAction func translate(_ sender: Any) {
        
        print(from?.rawValue)
        print(to?.rawValue)
        
        //if we havent inputted a word bigger than 2 characters it wont translate
        guard input.stringValue.count >= 2 && input.stringValue != "  " else { return }
        print(input.stringValue)
        
        if translations.keys.contains(input.stringValue) {
            print("already on the system!")
            
            output.stringValue = translations[input.stringValue]!
        } else {
            model.translate(query: input.stringValue, from: self.from!, to: self.to!)
           
        }
        
    }
    func controlTextDidChange(_ obj: Notification) {
        print(input.stringValue)
      //  languageChange(self)
    }
    
    
    
    
}

extension ViewController: ModelDelegate {
    func dataFetched(_ data: Translation?) {
        
        if let data = data {
            self.translation = data
            translations[input.stringValue] = data.translatedText
            hitCountNumber += 1
        } else {
            print("api failed")
            translations = dummyDictionary
        }
        
    }
    
    
}
