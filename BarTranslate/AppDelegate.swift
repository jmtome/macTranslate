//
//  AppDelegate.swift
//  BarTranslate
//
//  Created by Juan Manuel Tome on 24/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    public let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    public let popover = NSPopover()
    public var eventMonitor: EventMonitor?
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let button = statusItem.button {
            //button.image = NSImage(imageLiteralResourceName: "star")
            button.title = "★"
            button.target = self
            button.action = #selector(togglePopover(_:))
            
        }
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else { fatalError()}
        popover.contentViewController = vc
        //constructMenu()
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(event)
            }
        })
    }
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender)
            
        } else {
            showPopover(sender)
        }
    }
    
    func showPopover(_ sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(_ sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func constructMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Menu title", action: #selector(showSettings(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit App", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "Q"))
        statusItem.menu = menu
    }

    @objc func showSettings(_ sender: Any?) {
        
        
        //popoverView.behavior = .transient
        
        
    }
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

