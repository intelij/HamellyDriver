//
//  ListPayoutsVC.swift
//  GoferDriver
//
//  Created by bowshul sheik rahaman on 25/01/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import UIKit

class ListPayoutsVC: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var paymentListTableView: UITableView!
    
    @IBOutlet weak var addStripeBtn: UIButton!
    @IBOutlet weak var addPaypalBtn: UIButton!
    @IBOutlet weak var placeHolderPayout : UIView!
    @IBOutlet weak var placeHolderText : UILabel!
    //MARK: Actions
    
    @IBAction func backAction(_ sender: Any) {
        appDelegate.uberTabBarCtrler.tabBar.isHidden = false
        _ = self.setSemantic(false)
        self.navigationController?.popViewController(animated: true)
    
    }
    @IBAction func addPaypalAction(_ sender: Any) {
//        let main_story = UIStoryboard(name: STORY_MAIN, bundle: nil)
//        let propertyView = main_story.instantiateViewController(withIdentifier: "AddPaymentVC") as! AddPaymentVC
        let paypalVC = PaypalPayoutVC.initWithStory()
        self.navigationController?.pushViewController(paypalVC, animated: true)
    }
    @IBAction func addStripeAction(_ sender: Any) {
        let vc = AddPayoutVC.initWithStory()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    var selctedIndex = 0
    var payoutDetailList = [PayoutDetail]()
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    //MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.setSemantic(true){
            self.backButton.setTitle("I", for: .normal)
            self.paymentListTableView.semanticContentAttribute = .forceRightToLeft
        }else{
            self.backButton.setTitle("e", for: .normal)
            //self.paymentListTableView.semanticContentAttribute = .forceRightToLeft
        }
        self.automaticallyAdjustsScrollViewInsets = false
        _ = PipeLine.createEvent(withName: "LAYOUT_SUB_VIEW") {
            self.view.layoutSubviews()
            self.view.layoutIfNeeded()
        }
        self.initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.uberTabBarCtrler.tabBar.isHidden = true
        self.fetchPayoutList()
       
    }
    
    func initView(){
//        payoutDetailList = [_payout,_payout,_payout,_payout,_payout]
        self.paymentListTableView.tableHeaderView?.isHidden = true// = nil
        self.paymentListTableView.tableFooterView?.isHidden = true// = nil
        self.paymentListTableView.delegate = self
        self.paymentListTableView.dataSource = self
        self.pageTitle.text = "Payouts".localize
        let holderText = "Setup your UBER payout method".localize.replacingOccurrences(of: "UBER", with: iApp.appName)
        let attributed = NSMutableAttributedString(string: holderText)
        do
        {
            let regex = try! NSRegularExpression(pattern: iApp.appName,options: .caseInsensitive)
            for match in regex.matches(in: holderText, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: holderText.count)) as [NSTextCheckingResult] {
                attributed.addAttribute(NSAttributedString.Key.font,
                                        value: UIFont(name: "ClanPro-News",
                                                      size: 18),
                                        range: match.range)
            }
            self.placeHolderText.attributedText = attributed
        }

        self.addPaypalBtn.setTitle("Add".localize+" Paypal "+"Payout".localize, for: .normal)
        self.addStripeBtn.setTitle("Add".localize+" Stripe "+"Payout".localize, for: .normal)
        self.addPaypalBtn.is_ClippedCorner = true
        self.addStripeBtn.is_ClippedCorner = true
        
        //self.paymentListTableView.sw
    }
    func fetchPayoutList(){
        PaymentInteractor.instance.getPayoutList { (payoutList) in
            self.payoutDetailList = payoutList
            
               self.paymentListTableView.reloadData()
        }
    }

    //MARK: initwithstory
    class func initWithStory() -> ListPayoutsVC{
        let view = UIStoryboard(name: STORY_PAYMENT, bundle: nil).instantiateViewController(withIdentifier: "ListPayoutsVC") as! ListPayoutsVC
        return view
    }

}
extension ListPayoutsVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.contentInset  = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.paymentListTableView.tableHeaderView?.isHidden = true// = nil
        self.paymentListTableView.tableFooterView?.isHidden = true// = nil
        if self.payoutDetailList.isEmpty{
            self.placeHolderPayout.frame = self.paymentListTableView.frame
            self.paymentListTableView.backgroundView = self.placeHolderPayout
            return 0
        }else{
            let white_view = UIView()
            white_view.frame = self.paymentListTableView.frame
            white_view.backgroundColor = .white
            self.paymentListTableView.backgroundView = white_view
            return self.payoutDetailList.count
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PayoutListCell.idententifier) as! PayoutListCell
        guard self.payoutDetailList.count > indexPath.row else{return cell}
        let payout = self.payoutDetailList[indexPath.row]
        cell.setCell(WithPayout: payout, index: indexPath.row)
        if payout.setDefault != "Yes"{
            cell.setAction(self)
        }
        return cell
    }
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
/*
   func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard self.payoutDetailList.count > indexPath.row else{
            return [UITableViewRowAction]()
        }
        let payout = self.payoutDetailList[indexPath.row]
        guard payout.setDefault != "Yes" else{return [UITableViewRowAction]()}
        let _default = UITableViewRowAction(style: .normal, title: "Make Default".localize) { (_, indexPath) in
     
     
            PaymentInteractor.instance.editPayout(withId: payout.payoutID, option: .setAsDefault, response: { (val) in
                if val{
                    self.fetchPayoutList()
                }
            })
        }
    _default.backgroundColor = .lightGray
        let _delete = UITableViewRowAction(style: .destructive, title: "Delete".localize) { (_, indexPath) in
            PaymentInteractor.instance.editPayout(withId: payout.payoutID, option: .delete, response: { (val) in
                if val{
                    self.fetchPayoutList()
                }
            })
        }
    _delete.backgroundColor = .red
    _default.backgroundColor = UIColor(hex: "24ACD0")
    
        return [_delete,_default]
    }
   
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard self.payoutDetailList.count > indexPath.row else{
            
            return UISwipeActionsConfiguration(actions: [])
        }
        let payout = self.payoutDetailList[indexPath.row]
        guard payout.setDefault != "Yes" else{return UISwipeActionsConfiguration(actions: [])}
        
        let _delete = UIContextualAction(style: .destructive, title: "Delete".localize) { (action, sourceView, completionHandler) in
            PaymentInteractor.instance.editPayout(withId: payout.payoutID, option: .delete, response: { (val) in
                if val{
                    self.fetchPayoutList()
                }
            })
            completionHandler(true)
        }
        let _default = UIContextualAction(style: .normal, title: "Make Default".localize) { (action, sourceView, completionHandler) in
            
            PaymentInteractor.instance.editPayout(withId: payout.payoutID, option: .setAsDefault, response: { (val) in
                if val{
                    self.fetchPayoutList()
                }
            })
            completionHandler(true)
        }
        _delete.backgroundColor = .red
        _default.backgroundColor = UIColor(hex: "24ACD0")
        let swipeAction = UISwipeActionsConfiguration(actions: [_delete,_default])
        swipeAction.performsFirstActionWithFullSwipe = false // This is the line which disables full swipe
    
        return swipeAction
    }
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.paymentListTableView.cellForRow(at: indexPath)?.isEditing = true
        
        //self.paymentListTableView.cellForRow(at: indexPath).swipe
    }
    
}
class PayoutListCell : UITableViewCell{
    
    @IBOutlet weak var payoutDisplayName: UILabel!
    @IBOutlet weak var defaultLabel: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var makeDefaultBtn: UIButton!
    @IBOutlet weak var adujustableSpaceConstaint: NSLayoutConstraint!
    
    var payout : PayoutDetail!
    var parentVC : ListPayoutsVC!
    var index : Int!
    static var idententifier : String{
        return "PayoutListCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
//        self.defaultLabel.text = "Default".localize
        self.defaultLabel.text = NSLocalizedString("Default", comment: "")//"Default".localize

    }
    func setCell(WithPayout payout: PayoutDetail,index : Int){
        self.payout = payout
        self.index = index
        self.payoutDisplayName.text = self.payout.paypalEmail
        self.defaultLabel.text = NSLocalizedString("Default", comment: "")//"Default".localize
        if self.payout.setDefault == "Yes"{
            self.defaultLabel.isHidden = false
            self.contentView.isUserInteractionEnabled = false
        }else{
            self.defaultLabel.isHidden = true
            self.contentView.isUserInteractionEnabled = true
        }
        self.close()
        
    }
    func setAction(_ view : ListPayoutsVC){
        self.parentVC = view
        
        self.deleteBtn.addAction(for: .tap) {
            PaymentInteractor.instance.editPayout(withId: self.payout.payoutID, option: .delete, response: { (val) in
                if val{
                    view.fetchPayoutList()
                }
            })
        }
        self.makeDefaultBtn.addAction(for: .tap) {
            PaymentInteractor.instance.editPayout(withId: self.payout.payoutID, option: .setAsDefault, response: { (val) in
                if val{
                    view.fetchPayoutList()
                }
            })
        }
        self.contentView.addAction(for: .tap) {
            if self.parentVC.selctedIndex != self.index{
                self.parentVC.selctedIndex = self.index
                _ = PipeLine.fireEvent(withName: "LIST_CELL_ANIMATION")
            }
           
                if self.adujustableSpaceConstaint.constant == 0{
                    self.open()
                }else{
                    self.close()
                }
        }
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(self.gesuteHandler(pan:)))
        self.contentView.addGestureRecognizer(gesture)
        
        _ = PipeLine.createEvent(withName: "LIST_CELL_ANIMATION") {
            if self.parentVC.selctedIndex != self.index{
                 self.close()
            
            }
        }
        
    }
    var movement = CGFloat(0)
    
    @objc func gesuteHandler(pan : UIPanGestureRecognizer){
        if self.parentVC.selctedIndex != index{
            self.parentVC.selctedIndex = index
            _ = PipeLine.fireEvent(withName: "LIST_CELL_ANIMATION")
        }
        let translation = pan.translation(in: self.contentView)
        let velocity = Double(pan.velocity(in: self.contentView).x)
        let stretch = Double(self.adujustableSpaceConstaint.constant)
        let xTranslaiton = Double(-translation.x)
        let movement : Double!
        if translation.x < 0{
            movement = stretch * 0.5 + xTranslaiton
        }else{
            movement = stretch + xTranslaiton * 0.1
        }
        
         let duraiton = Double(movement / velocity)
        print("∂",stretch,translation.x,movement)
        UIView.animate(withDuration: duraiton,
                       delay: 0,
                       usingSpringWithDamping: 0.35,
                       initialSpringVelocity: 50,
                       options: [.layoutSubviews,.allowUserInteraction],
                       animations: {
        switch pan.state{
        case .changed:
            switch movement ?? 0.0 {
            case let x where x < 0.0:
                self.close()
            case let x where x > 200.0:
                self.open()
            default:
                self.adujustableSpaceConstaint.constant = CGFloat(movement)
            }
        default:
                if stretch > 90{
                    self.open()
                }else{
                    self.close()
                }
            
        }
            }, completion: nil)
    }
    func open(){
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 10,
                       options: [.layoutSubviews,.allowUserInteraction],
                       animations: {
                        self.adujustableSpaceConstaint.constant = 200
                        PipeLine.fireEvent(withName: "LAYOUT_SUB_VIEW")
        }, completion: nil)
    }
    func close(){
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 10,
                       options: [.layoutSubviews,.allowUserInteraction],
                       animations: {
                        self.adujustableSpaceConstaint.constant = 0
                        PipeLine.fireEvent(withName: "LAYOUT_SUB_VIEW")

        }, completion: nil)
    }
}
