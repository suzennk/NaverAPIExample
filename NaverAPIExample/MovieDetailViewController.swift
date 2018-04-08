//
//  MovieDetailViewController.swift
//  NaverAPIExample
//
//  Created by MBP04 on 2018. 4. 5..
//  Copyright © 2018년 codershigh. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    var urlString:String?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let urlStr = urlString {
            let url = URL (string: urlStr);
            let request = URLRequest(url: url!);
            webView.loadRequest(request);
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    @IBAction func forwardButtonPressed(_ sender: Any) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    @IBAction func reloadButtonPressed(_ sender: Any) {
        webView.reload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
