//
//  InfoViewController.swift
//  Todoey
//
//  Created by Jimmy Chung on 2019-04-24.
//  Copyright © 2019 Jimmy Chung. All rights reserved.
//

import UIKit
import SafariServices
class InfoViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        scrollView.delegate=self
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.frame.size
    }
    

    @IBAction func privacyButton(_ sender: Any) {
        print("hello")
        let url=URL(string: "https://taskup.online")
        let safariVC=SFSafariViewController(url:url!)
        present(safariVC, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
