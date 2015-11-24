//
//  ViewController.swift
//  Hackathon
//
//  Created by Wojciech Tyziniec on 20/11/15.
//  Copyright © 2015 Wojciech Tyziniec. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift
import AVKit
import AVFoundation

class StartViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, LGChatControllerDelegate {

    
    // MARK: Properties
    let socket = SocketIOClient(socketURL: "gcc-team.cloudapp.net:8000", options: [.Log(true), .ForcePolling(true)])
    var player = AVPlayer()

    /// Text field do wprowadzania nazwy uzytkownika
    @IBOutlet weak var textField: UITextField!
    
    /// Testowy print danych pobranych od usera
    @IBOutlet weak var labelData: UILabel!
    
    /// Picker i jego dane
    @IBOutlet weak var langPicker: UIPickerView!
    /// ATM polski, angielski, niemiecki, hiszpanski, rosyjski, japoński, włoski, arabski, chiński
    let pickerData = ["PL", "EN", "DE", "ES", "RU", "JP", "IT", "AR", "ZH"]
    var pickerChoice: String = ""
    /// tmp zmienne
    var tmpMessage = ""
    var tmpLanguage = ""
    var tmpStatus = false
    var tmpUsername = ""
    var flaga = ""
    /// Narzędzia takie jak np - JSONStringify
    let tools = Utilities()
    let synthesizer = AVSpeechSynthesizer()

    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerChoice = pickerData[0]
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerChoice = pickerData[row]
    }
    
    /**
    Funkcja wywoływana podczas pierwszego załadowania widoku
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        langPicker.dataSource = self
        langPicker.delegate = self
        
   
        socket.on("connected"){data, ack in
            if let json = data[0] as? NSDictionary {
                self.tmpStatus = json["status"] as! Bool
                print("Status teraz to: \(self.tmpStatus)")
                if(self.tmpStatus == true)
                {
                    self.sendGreeting(self.tmpUsername, lang: self.pickerChoice)
                }
            }
        }
        self.socket.connect()
        
    }
    
    func sendGreeting(from: String, lang: String) {
        let jsonGreeting: [AnyObject] = [
            ["from": from, "lang" : lang]
        ]
        
        let jsonString = tools.JSONStringify(jsonGreeting, prettyPrinted: false)
        print(jsonString)
        self.socket.emit("greeting", jsonGreeting)
        
    }

    func sendMessage(msg: String, lang: String, from: String)
    {
        let jsonMessage: [AnyObject] = [
            ["msg":msg, "lang":lang, "from":from]
        ]
        
        let jsonString = tools.JSONStringify(jsonMessage, prettyPrinted: false)
        print(jsonString)
        self.socket.emit("message", jsonMessage)
    }
    
    
    func textToSpeech(txt: String, lang: String) {
        let utterance = AVSpeechUtterance(string: txt)
        utterance.rate = 0.5
        utterance.voice = AVSpeechSynthesisVoice(language: lang)
        synthesizer.speakUtterance(utterance)
    }
    
    @IBAction func sendData(sender: AnyObject) {
        //playRemoteFile()
        //textToSpeech(tmpMessage)
        tmpUsername = textField.text!
        labelData.text = "Błąd połączenia z serwerem!"
        pickerChoice = pickerChoice.lowercaseString
        sendGreeting(tmpUsername, lang: pickerChoice)
        if(tmpStatus == true)
        {
            self.dismissViewControllerAnimated(true, completion: nil)
                launchChatController()
        }
        else {
            print("Status jest blad!")
        }
    }
    
    func launchChatController() {
        let chatController = LGChatController()
        chatController.tableView.reloadData()
        
        self.navigationController?.pushViewController(chatController, animated: true)
        chatController.delegate = self
        socket.on("message") {data, ack in
            if let json = data[0] as? NSDictionary {
                self.tmpMessage = json["msg"] as! String
                self.tmpLanguage = json["to"] as! String
                self.textToSpeech(self.tmpMessage, lang: self.tmpLanguage)
                print(json["msg"]!)
                self.flaga = json["lang"] as! String
                if(self.flaga == "pl")
                {
                    self.tmpMessage = "🇵🇱" + self.tmpMessage
                }
                else if(self.flaga == "es")
                {
                    self.tmpMessage = "🇪🇸" + self.tmpMessage
                }
                else if(self.flaga == "fr")
                {
                    self.tmpMessage = "🇫🇷" + self.tmpMessage
                }
                else if(self.flaga == "de")
                {
                    self.tmpMessage = "🇩🇪" + self.tmpMessage
                }
                else if(self.flaga == "en")
                {
                    self.tmpMessage = "🇬🇧" + self.tmpMessage
                }
                let odp = LGChatMessage(content: self.tmpMessage, sentBy: .Opponent)
                chatController.messages += [odp]
                chatController.tableView.reloadData()
                chatController.scrollToBottom()
        
            }
        }
    }
    
    // MARK: LGChatControllerDelegate
    
    func chatController(chatController: LGChatController, didAddNewMessage message: LGChatMessage ) {
        
        let jsonMessage: [AnyObject] = [
            ["msg":message.content, "lang":pickerChoice, "from":tmpUsername]
        ]
        let jsonString = tools.JSONStringify(jsonMessage, prettyPrinted: false)
        print(jsonString)
        self.socket.emit("message", jsonMessage)
        
        
        print("Wyslano wiadomosc: \(message.content)")
    }
    
    func shouldChatController(chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
        
        return true
    }
    
    
    func stylizeChatInput() {
        LGChatInput.Appearance.backgroundColor = UIColor.yellowColor()
        LGChatInput.Appearance.includeBlur = true
        //LGChatInput.Appearance.textViewBackgroundColor = <#UIColor#>
    }
    

    
    func playRemoteFile() {
        
        let url = "http://static1.grsites.com/archive/sounds/cartoon/cartoon013.mp3"
        let playerItem = AVPlayerItem( URL:NSURL( string:url )! )
        player = AVPlayer(playerItem:playerItem)
        player.rate = 1.0;
        player.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  

}

