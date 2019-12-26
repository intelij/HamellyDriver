//
//  ChatVC.swift
//  GoferDriver
//
//  Created by bowshul sheik rahaman on 12/01/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatVC: UIViewController ,ChatViewProtocol{
    
    //MARK: Protocol implementation
    var chatInteractor: ChatInteractorProtocol?
    
    var messages: [ChatModel] = [ChatModel]()
    
    var firstTime : Bool = true
    let preference = UserDefaults.standard
    func setChats(_ message: [ChatModel]) {
        self.messages = message
        if self.firstTime{
            self.chatTableView.springReloadData()
            self.firstTime = false
        }else{
            self.chatTableView.reloadData()
        }
        let count = self.messages.count - 1
        if count >= 0{
            self.chatTableView.scrollToRow(at: IndexPath(row: count, section: 0),
                                           at: .bottom,
                                           animated: true)
        }
        
    }
    //MARK: Outlets
    @IBOutlet weak var riderAvatar : UIImageView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var backBtn : UIButton!
    @IBOutlet weak var driverName : UILabel!
    @IBOutlet weak var driverRating : UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet var chatPlaceholder: UIView!
    @IBOutlet weak var noChatMessage: UILabel!
    
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var bottomChatBar: UIView!
    //MARK: Actions
    @IBAction func BackAct(_ sender: UIButton) {
        _ = self.setSemantic(false)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        guard let msg = self.messageTextField.text,!msg.isEmpty else{return}
        let chat = ChatModel(message: msg, type: .driver)
        //        self.chatInteractor?.append(message: chat)
        ChatInteractor.instance.append(message: chat)
        if self.messages.count == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                ChatInteractor.instance.getAllChats(ForView : self, AndObserve: true)
            }
        }
        
        self.messageTextField.text = String()
    }
    
    var riderImage : UIImage?
    var ridername = "Rider".localize
    var rating = 0.0
    
    
//    override var preferredStatusBarStyle: UIStatusBarStyle{
//        return .lightContent
//    }
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        self.initGesture()
        self.initPipeLines()
        
//        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
//        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
//            statusBar.backgroundColor = UIColor.ThemeMain//UIColor(red: 39.0 / 255.0, green: 112.0 / 255.0, blue: 184.0 / 255.0, alpha: 1.0)
//        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if shouldCloseOnWillAppear{
            self.BackAct(self.backBtn)
            self.shouldCloseOnWillAppear = false
            return
        }
        ChatInteractor.instance.getAllChats(ForView : self, AndObserve: true)
        
//        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
//        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
//            statusBar.backgroundColor = UIColor.ThemeMain//UIColor(red: 39.0 / 255.0, green: 112.0 / 255.0, blue: 184.0 / 255.0, alpha: 1.0)
//        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        ChatInteractor.instance.getAllChats(ForView : nil, AndObserve: true)
    }
    
    //MARK: initailalizer
    func initView(){
        if self.setSemantic(true){
            self.backBtn.setTitle("I", for: .normal)
        }else{
            self.backBtn.setTitle("e", for: .normal)
        }
        // self.chatTableView.isElevated = true
        
        //Set Image
        if let dImage = self.riderImage{
            self.riderAvatar.image = dImage
        }else if let thumb_str = preference.string(forKey: TRIP_RIDER_THUMB_URL),
            let thumb_url = URL(string: thumb_str) {
             self.riderAvatar.sd_setImage(with: thumb_url)
        }else{
            self.riderAvatar.image = UIImage(named: "user_dummy.png") ?? UIImage()
        }
        
        //Set name
        if !self.ridername.isEmpty && self.ridername != "Rider".localize{
            self.driverName.text = self.ridername
        }else if let name = preference.string(forKey: TRIP_RIDER_NAME){
            self.driverName.text = name
        }else{
            self.driverName.text = "Rider".localize
        }
        //Set Rating
        if rating != 0.0{
            self.driverRating.isHidden = false
            self.driverRating.text = "\(rating)⭑"
        }else if let str_rating = preference.string(forKey: TRIP_RIDER_RATING),
            let _rating = Double(str_rating),
            _rating != 0.0{
            self.rating = _rating
            self.driverRating.isHidden = false
            self.driverRating.text = "\(_rating)⭑"
        }else{
            self.driverRating.isHidden = true
        }
        self.messageTextField.autocorrectionType = .no
        self.riderAvatar.isRoundCorner = true
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
        
        self.messageTextField.placeholder =  "Type a message...".localize
        self.noChatMessage.text = "No messages, yet.".localize
        
        
        
        self.bottomChatBar.isRoundCorner = true
        self.bottomChatBar.border(0.5, .gray)
        
        self.bottomChatBar.elevate(2.0)
        self.chatTableView.reloadData()
    }
    func initPipeLines(){
        _ = PipeLine.createEvent(withName: "CHAT_OBSERVER") { [weak self] in
            ChatInteractor.instance.getAllChats(ForView : self, AndObserve: true)
        }
    }
    var chatTableRect : CGRect!
    var isKeyboardOpen = false
    func initGesture(){
        self.chatTableView.addAction(for: .tap) {
            self.view.endEditing(true)
        }
        self.view.addAction(for: .tap) {
            self.view.endEditing(true)
        }
        self.bottomChatBar.addAction(for: .tap) {
            
        }
        self.chatTableRect = self.chatTableView.frame
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.chatTableRect = self.chatTableView.frame
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardShowning), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.KeyboardHidded), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    @objc func KeyboardShowning(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.15) {
            self.bottomChatBar.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height)
            
            var contentInsets:UIEdgeInsets
            //(UIApplication.shared.statusBarOrientation)
//            if UIApplication.shared.statusBarOrientation.isPortrait {
//
//                contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0);
//            }
//            else {
//                contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.width, right: 0.0);
//
//            }
//            self.chatTableView.contentInset = contentInsets
            
            let count = self.messages.count - 1
            if count > 0{
                self.chatTableView.scrollToRow(at: IndexPath(row: count, section: 0),
                                               at: .bottom,
                                               animated: true)
            }
            self.view.layoutIfNeeded()
        }
        
        
    }
    //hide the keyboard
    @objc func KeyboardHidded(notification: NSNotification)
    {
        
        UIView.animate(withDuration: 0.15) {
            self.bottomChatBar.transform = .identity
            self.chatTableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0);
            let count = self.messages.count - 1
            if count > 0{
                self.chatTableView.scrollToRow(at: IndexPath(row: count, section: 0),
                                               at: .bottom,
                                               animated: true)
            }
            self.view.layoutIfNeeded()
        }
    }
    private var shouldCloseOnWillAppear = false
    func riderCancelledTrip(notification: Notification)
    {
        self.shouldCloseOnWillAppear = true
        self.BackAct(self.backBtn)
    }
    //MARK: init with story
    class func initWithStory(withTripId trip_id:String) -> ChatVC{
        let view = UIStoryboard(name: STORY_PAYMENT, bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
 
            ChatInteractor.instance.initialize(withTrip: trip_id)
      
        
        
        return view
    }
    
    
}

extension ChatVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.messages.count
        if count > 0{
            self.chatTableView.backgroundView = nil
            return count
        } else{
            self.chatTableView.backgroundView = self.chatPlaceholder
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.row]
        if message.type == .rider{
            let cell = tableView.dequeueReusableCell(withIdentifier: SenderCell.identifier) as! SenderCell
            cell.setCell(withMessage: message,avatar: self.riderAvatar.image ?? UIImage(named: "user_dummy.png")! )
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: ReceiverCell.identifier) as! ReceiverCell
            cell.setCell(withMessage: message)
            return cell
        }
    }
    
    
}


//MARK: Cells

class SenderCell : UITableViewCell{
    @IBOutlet weak var messageLbl : UILabel!
    @IBOutlet weak var avatarImage : UIImageView!
    @IBOutlet weak var background : UILabel!
    
    static var identifier = "SenderCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    func setCell(withMessage message: ChatModel,avatar : UIImage){
        self.messageLbl.text = message.message
        self.avatarImage.image = avatar
        self.avatarImage.isRoundCorner = true
        self.avatarImage.elevate(2.0, radius: self.avatarImage.height(ofCent: 50),
                                 opacity: 0.5, fillcolor: .clear, shadowColor: .ThemeInactive)
        self.background.elevate(2.0, radius: 6, opacity: 0.5, fillcolor: UIColor(hex :"EFEFF4"), shadowColor: .gray)
        
    }
}
class ReceiverCell : UITableViewCell{
    @IBOutlet weak var messageLbl : UILabel!
    @IBOutlet weak var background : UILabel!
    
    static var identifier = "ReceiverCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    func setCell(withMessage message: ChatModel){
        self.messageLbl.text = message.message
        self.background.elevate(2.0, radius: 6, opacity: 0.5, fillcolor: UIColor(hex :"1FBAD6"), shadowColor: .gray)
        // dump(message)"76D6FF"
        
    }
    
}
