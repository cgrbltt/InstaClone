//
//  ViewStoryViewController.swift
//  InstaCloneFirebase
//
//  Created by Çağrı Bulut on 14.02.2021.
//  Copyright © 2021 Bulut. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class ViewStoryViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    var storyImages = [[Story]]()
    var selfStory = false
    var position = Int()
    var previusX = CGFloat(0)
    override func viewDidLoad() {
        super.viewDidLoad()
        let x = self.scrollView.frame.width
        let y = self.scrollView.frame.height
        
        for i in 0..<storyImages.count {
            let stories = storyImages[i]
            let view = UIView()
            
            let scrollView2 = UIScrollView()
            let xPosition = previusX
            scrollView2.frame = CGRect(x: xPosition, y: 0, width: x * CGFloat(stories.count), height:y)
            self.previusX += scrollView2.frame.width
            
            if i == 1 {scrollView2.backgroundColor = .black
            }
            else{
                scrollView2.backgroundColor = .yellow
            }
            
            for story in stories {
               var index = 0

                let imageView = UIImageView()
                imageView.sd_setImage(with: URL(string: story.postedImagelink))
                let xPosition = scrollView2.frame.width * CGFloat(index)
                
                imageView.frame = CGRect(x: xPosition, y: 0, width: x, height:y)
                scrollView2.addSubview(imageView)
             index += 1
 
            }
            self.scrollView.addSubview(scrollView2)
            self.scrollView.contentSize.width += scrollView.frame.width * CGFloat(stories.count)
            self.scrollView.contentOffset = CGPoint(x:414 * (position-1), y:0)
            self.scrollView.backgroundColor = .green
        }
    }
  
    @objc func leftViewTapped() {
        
    }
    
        @objc func rightViewTapped() {
            print("Right")
        }
    }


/* let touchArea = CGSize(width: 80, height: self.view.frame.height)
 let leftView = UIView(frame: CGRect(origin: .zero, size: touchArea))
 let rightView = UIView(frame: CGRect(origin: CGPoint(x: self.view.frame.width - touchArea.width, y: 0), size: touchArea))
 leftView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftViewTapped)))
 rightView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightViewTapped)))
 leftView.backgroundColor = .clear
 rightView.backgroundColor = .clear
 */
