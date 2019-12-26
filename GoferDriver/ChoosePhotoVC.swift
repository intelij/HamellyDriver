/**
* ChoosePhotoVC.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/



import UIKit
import Foundation

protocol ChoosePhotoDelegate
{
    func onPhotoChoosedDelegateTapped(btnTag:Int)
}

class ChoosePhotoVC : UIViewController
{
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var viewObjectHolder: UIView!
   
    var strFirstName = ""
    var strLastName = ""
    var isFromOther : Bool = false
    var delegate: ChoosePhotoDelegate?
    // MARK: - ViewController Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        btnCancel.layer.borderColor = UIColor.ThemeMain.cgColor
        btnCancel.setTitleColor(.ThemeMain, for: .normal)
        btnCancel.layer.borderWidth = 1.0
    }
    //set the animation if the page loaded
    func setupShareAppViewAnimationWithView(_ view:UIView)
    {
        view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIView.AnimationOptions.allowUserInteraction, animations:
            {
                view.transform = CGAffineTransform.identity
                view.alpha = 1.0;
        },  completion: { (finished: Bool) -> Void in
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        setupShareAppViewAnimationWithView(viewObjectHolder)
    }

    // MARK: Navigating to Email field View
    /*
     */
    @IBAction func onAlertTapped(_ sender:UIButton!)
    {
        if sender.tag == 11 || sender.tag == 22
        {
            dismiss(animated: true, completion: {
                self.delegate?.onPhotoChoosedDelegateTapped(btnTag:sender.tag)
            })
        }
        else
        {
            dismiss(animated: true, completion: nil)
        }
    }
    
}
