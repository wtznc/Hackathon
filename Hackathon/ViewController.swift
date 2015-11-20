//
//  ViewController.swift
//  Hackathon
//
//  Created by Wojciech Tyziniec on 20/11/15.
//  Copyright © 2015 Wojciech Tyziniec. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift

class ViewController: UIViewController {

    
    // MARK: Properties
    let socket = SocketIOClient(socketURL: "gcc-team.cloudapp.net:8000", options: [.Log(true), .ForcePolling(true)])
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var labelData: UILabel!
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addHandlers()
        self.socket.connect()
        
    }
    
    /**
     Funkcja wypisuje nam jsona jako string
     
     - parameter value:         przygotowany obiekt json
     - parameter prettyPrinted: wartosc ustawien, czy chcemy zeby wypisalo nam z lamaniem wierszy
     
     - returns: zwraca stringa z jsona
     */
    func JSONStringify(value: AnyObject, prettyPrinted:Bool = false) -> String {
        let options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions(rawValue: 0)
        
        if NSJSONSerialization.isValidJSONObject(value) {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(value, options: options)
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }
            } catch {
                print("error")
                
            }
        }
        return ""
    }
    
    
    
    /**
     Funkcja tworzy obiekt typu json z podanych parametrów
     
     - parameter from: nadawca
     - parameter lang: język
     */
    func sendGreeting(from: String, lang: String) {
        let jsonGreeting: [AnyObject] = [
            ["from": from, "lang" : lang]
        ]
        
        let jsonString = JSONStringify(jsonGreeting, prettyPrinted: false)
        print(jsonString)
        self.socket.emit("greeting", jsonString)
        
    }
    
    
    @IBAction func sendData(sender: AnyObject) {
        labelData.text = textField.text
        self.socket.emit("room")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addHandlers() {
        self.socket.on("message") { [weak self] data, ack in
            self?.handleStart()
            return
        }
    }
    
    func handleStart() {
        self.labelData.text = "cokolwiek"
    }
    

}

