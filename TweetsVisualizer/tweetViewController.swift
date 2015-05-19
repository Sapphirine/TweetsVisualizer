//
//  tweetViewController.swift
//  TweetsVisualizer
//
//  Created by Linyin Wu on 9/5/15.
//  Copyright (c) 2015 Linyin Wu. All rights reserved.
//

import UIKit

class tweetViewController: UIViewController {
    
    @IBOutlet weak var testName: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let background = UIImage(named: "1.jpg")
        self.view.backgroundColor = UIColor(patternImage: background!)
        
        if tweetToBeDetailed != nil {
            nameLabel.text = "@\(tweetToBeDetailed?.name)"
            println(tweetToBeDetailed?.name)
            println(nameLabel.text)
            testName.text = tweetToBeDetailed?.name
            
            timestamp.text = tweetToBeDetailed?.timestamp
            text.text = tweetToBeDetailed?.text
            
            let url = tweetToBeDetailed?.avatarUrl
            
            let imageData : NSData = NSData(contentsOfURL : NSURL(string : url!)!)!
            avatar.image = UIImage(data : imageData)
            
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
