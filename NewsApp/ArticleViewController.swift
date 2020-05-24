//
//  ArticleViewController.swift
//  NewsApp
//
//  Created by oleG on 24/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {

    @IBOutlet var articleImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    
    var articleTitle: String?
    var articleContent: String?
    var articleData: Data?
    var articleAdress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleLabel.text = articleTitle
        contentLabel.text = articleContent
        articleImageView.image = UIImage(data: articleData!)
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
