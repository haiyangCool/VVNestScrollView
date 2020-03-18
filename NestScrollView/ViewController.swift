//
//  ViewController.swift
//  NestScrollView
//
//  Created by 王海洋 on 2019/9/29.
//  Copyright © 2019 王海洋. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    lazy var topView = UIView()
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .lightGray
        topView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300)
        topView.backgroundColor = .brown
        
        let bottomView = TestView()
        bottomView.frame = CGRect(x: 0, y: 0, width: 414, height: UIScreen.main.bounds.size.height)
        bottomView.backgroundColor = UIColor.gray
      
        
        let nestView = NestScrollView(frame: self.view.bounds)
        
        nestView.backgroundColor = .brown
        nestView.setTopKeepHeight(90)
        nestView.set(topView, bottomView: bottomView)
        view.addSubview(nestView)
        
        
        
        // Do any additional setup after loading the view.
    }


}


