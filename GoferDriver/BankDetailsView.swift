//
//  BankDetailsView.swift
//  GoferDriver
//
//  Created by trioangle on 18/05/19.
//  Copyright © 2019 Vignesh Palanivel. All rights reserved.
//

import UIKit

class BankDetailsView: UIView {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var lineLabel: UILabel!
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commitonInit()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        commitonInit()
//    }
//
//    private func commitonInit() {
//       Bundle.main.loadNibNamed("BankDetails", owner: nil, options: nil)
//        
//    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func getView() -> BankDetailsView {
        return UINib(nibName: "BankDetails", bundle: nil).instantiate(withOwner: nil, options: nil).first as! BankDetailsView
    }
    
//    func getParameters(titleLabel:String?,placeHolder:String?,lineColor:UIColor = UIColor.lightGray,textValue:String = ""){
//        label.text = titleLabel
//        textField.text = textValue
//        textField.placeholder = placeHolder
//        lineLabel.backgroundColor = lineColor
//    }
    func defaultColor(){
        lineLabel.backgroundColor = .lightGray
    }
    func changeColor(){
        lineLabel.backgroundColor = .ThemeLight
    }
    

}
