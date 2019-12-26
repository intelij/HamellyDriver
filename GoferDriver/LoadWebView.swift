/**
* LoadWebView.swift
*
* @package GoferDriver
* @author Trioangle Product Team
* @version - Stable 1.0
* @link http://trioangle.com
*/

import UIKit
import MessageUI
import Social

class LoadWebView : UIViewController, UIWebViewDelegate {
//    @IBOutlet var scrollMenus: UIScrollView!
    @IBOutlet var webCommon: UIWebView!
    @IBOutlet var lblTitle: UILabel!
    var strPageTitle = ""
    var strWebUrl = ""
    var strCancellationFlexible = ""
    var appDelegate  = UIApplication.shared.delegate as! AppDelegate


    override func viewDidLoad()
    {
        super.viewDidLoad()
                
        self.navigationController?.isNavigationBarHidden = true
        lblTitle.text = strPageTitle
    }
    
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        UberSupport().showProgress(viewCtrl: self, showAnimation: true)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        UberSupport().removeProgress(viewCtrl: self)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool
    {
//        print((request.url?.absoluteString)! as String)
        return true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        UberSupport().removeProgress(viewCtrl: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func goBack()
    {
        OperationQueue.main.addOperation {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func onAddTitleTapped(_ sender:UIButton!)
    {
        
    }

    @IBAction func onAddSummaryTapped(_ sender:UIButton!)
    {
        
    }

    @IBAction func onBackTapped(_ sender:UIButton!)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onAddListTapped(){
        
    }
}

