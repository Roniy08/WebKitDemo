//
//  WebViewController.swift
//  AskCurioMath
//

import UIKit
import WebKit
import Foundation

protocol StepByDelegate : class {
    func updateUI(enable:Bool)
    
}

enum WebViewOperationType : Int {
    case  load
    case  refresh
}

class WebViewController: UIViewController , UIWebViewDelegate, UIActionSheetDelegate  {
    
   
    weak var  delegate : StepByDelegate?
    var jsonString = String()
    var webViewType : WebViewOperationType = .load

    @IBOutlet weak var stepWebView: WKWebView!
    
    override func loadView() {
        super.loadView()
       let contentController = WKUserContentController()
               contentController.add(self, name: "sumbitToiOS")
               let config = WKWebViewConfiguration()
               config.userContentController = contentController
               self.stepWebView = WKWebView( frame: self.view.bounds, configuration: config)
        
        self.view.addSubview(self.stepWebView)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.brown
        // Do any additional setup after loading the view.
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        stepWebView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        stepWebView.navigationDelegate = self
        stepWebView.load(request)
        
    }
    @IBAction func CloseBtn(_ sender: Any) {
            self.createJsonToPass(status: "closed")
            print(self.jsonString)
            self.stepWebView.evaluateJavaScript("fillDetails('\(self.jsonString)')")
        
    }
    
    func createJsonForJavaScript(for data: [String : Any]) -> String {
        var jsonString : String?
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            
            jsonString = String(data: jsonData, encoding: .utf8)!
            jsonString = jsonString?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\\", with: "")
            
        } catch {
            print(error.localizedDescription)
        }
        print(jsonString!)
        return jsonString!
    }
    
    func createJsonToPass(status : String) {
        
        let data = ["status": status as String]
        self.jsonString = createJsonForJavaScript(for: data)
        print("close sheet")
        
    }
    
    
}


//MARK: - Web view delegate methods

extension WebViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
   
        print("didFinish")
        print("hide loader")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    
    
}

//MARK: - Web view method to handle call backs

extension WebViewController : WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        let dict = message.body as? Dictionary<String, String>
        
        let userdata = UserData((dict?["status"] ?? "opened"))
        self.createJsonToPass(status: "opened")
        self.stepWebView.evaluateJavaScript("fillDetails('\(self.jsonString)')")
        
        if message.name == "sumbitToiOS" {
            self.sumbitToiOS(user: userdata)
        }
        
    }
    
    
    func sumbitToiOS(user:UserData){
        //refresh token or id
        print("sumbitToiOS")
        print("open sheet")
        showPhoneActionSheet()
        
    }
    
    func endCurrentChat(isEnded: Bool){
        self.navigationController?.popViewController(animated: true)
    }
    func showPhoneActionSheet() {
        let phoneActionSheet = UIAlertController(title: "Hello world", message: "Do you want to close sheet?", preferredStyle: .actionSheet)
        let callCloseAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            // here action on close
            self.createJsonToPass(status: "yes pressed")
            self.stepWebView.evaluateJavaScript("fillDetails('\(self.jsonString)')")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        { (action) in
            // here action on close
            self.createJsonToPass(status: "canceled sheet")
            self.stepWebView.evaluateJavaScript("fillDetails('\(self.jsonString)')")
        }
        phoneActionSheet.addAction(callCloseAction)
        phoneActionSheet.addAction(cancelAction)
        present(phoneActionSheet, animated: true, completion: nil)
    }
    
}
