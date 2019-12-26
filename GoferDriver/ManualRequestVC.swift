//
//  ManualRequestVC.swift
//  Gofer
//
//  Created by trioangle on 04/04/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import UIKit
import AVFoundation

class ManualRequestVC: UIViewController {
    
    @IBOutlet weak var mainHolderView : UIView!
    @IBOutlet weak var subHolderView : UIView!
    
    @IBOutlet weak var busIV : UIImageView!
    @IBOutlet weak var headingL : UILabel!
    
    @IBOutlet weak var contentStackHolder : UIStackView!
    
    @IBOutlet weak var acceptBtn : UIButton!
    
    
    @IBOutlet weak var nameField : ManualStackContentV!
    @IBOutlet weak var phoneField : ManualStackContentV!
    @IBOutlet weak var locationField : ManualStackContentV!
    @IBOutlet weak var timeField : ManualStackContentV!
    
    var request : ManualRequestModel!
    
      var player: AVAudioPlayer?
    let AUDIO_PLAY_SPEED = 0.7
    let myThread = DispatchQueue.init(label: "MyThread")
    var continuePlaying = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initFields()
        self.initView()
        self.initGestures()
        self.presentContent()
        self.loopAndPlay()
        
        // Do any additional setup after loading the view.
    }
    func initView(){
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.mainHolderView.elevate(8)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.12)
            self.busIV.image = UIImage(named: iApp.img.taxiIcon)?.withRenderingMode(.alwaysTemplate)
            self.busIV.tintColor = .ThemeLight
        }
    }
    func initGestures(){
        if self.request.tripStatus != .manualBookiingCancelled{
            self.phoneField.addAction(for: .tap) {
                self.continuePlaying = false
                self.contactRider()
            }
        }
        self.view.addAction(for: .tap) {
            //  self.dismiss(animated: true, completion: nil)
        }
        self.mainHolderView.addAction(for: .tap) {
            
        }
        
    }
    func initFields(){
        self.nameField.setView(withName: request.riderFullName, image: iApp.img.account)
        self.phoneField.setView(withName: request.displayNumber, image: iApp.img.phone)
        self.locationField.setView(withName: request.pickUpAddress, image: iApp.img.mapMarker)
        self.timeField.setView(withName: request.displayTime, image: iApp.img.clockOutline)
        
        self.contentStackHolder.insertArrangedSubview(self.timeField, at: 0)
        self.contentStackHolder.insertArrangedSubview(self.locationField, at: 0)
        self.contentStackHolder.insertArrangedSubview(self.phoneField, at: 0)
        self.contentStackHolder.insertArrangedSubview(self.nameField, at: 0)
        
        switch self.request.tripStatus {
        case .manuallyBookedReminder:
            self.headingL.text = "Manual Booking Reminder"
        case .manualBookiingCancelled:
            self.headingL.text = "Manual Booking Cancelled"
        default:
            self.headingL.text = "Manually Booked For Ride"
        }
       
    }
    func presentContent(){
        self.mainHolderView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 1.3,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 10,
                       options: [.curveEaseInOut],
                       animations: {
                         self.mainHolderView.transform = .identity
        }) { (_) in
            
        }
    }
    func dismissContent(){
        UIView.animate(withDuration: 1.3,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 10,
                       options: [.curveEaseInOut],
                       animations: {
                        self.mainHolderView.transform = CGAffineTransform(scaleX: 0, y: 0)
        }) { (_) in
            if self.isPresented(){
                self.dismiss(animated: false, completion: nil)
            }else{
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    func contactRider(){
        if let phoneCallURL:NSURL = NSURL(string:"tel://\(request.riderPhoneNo)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL as URL)) {
                application.openURL(phoneCallURL as URL);
            }
        }
    }
    var playCounter = 0
    func loopAndPlay(){
        
        self.myThread.async {
            while self.continuePlaying{
                self.playSound("manual_booking_notification_sound")
                sleep(3)
                self.playCounter += 1
                if self.playCounter > 1{
                    self.continuePlaying = false
                }
            }
        }
        
    }
    func playSound(_ fileName: String) {
        let url = Bundle.main.url(forResource: fileName, withExtension: "mp3")!
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    class func initWithStory(forRequest req : ManualRequestModel) -> ManualRequestVC{
        let story = Stories.trip.instance
        let vc = story.instantiateViewController(withIdentifier: "ManualRequestVC") as! ManualRequestVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.request = req
        return vc
    }
    //MARK:-Actions
    @IBAction func onAcceptBtn(_ sender : UIButton){
        self.player?.stop()
        self.continuePlaying = false
        self.dismissContent()
    }
}
class ManualStackContentV : UIView{
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var placeImage : UIImageView!
    override func awakeFromNib() {
    }
    func setView(withName name : String,image : String){
        self.label.text = name
        self.setImage(withName: image)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.isCurvedCorner = true
            self.backgroundColor = UIColor(hex: "F6F6F6")
        }
    }
    func setImage(withName name: String){
        let image = UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
        self.placeImage.image = image
        self.placeImage.tintColor = .ThemeLight
    }
    
}
