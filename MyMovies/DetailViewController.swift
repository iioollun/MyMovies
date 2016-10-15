//
//  DetailViewController.swift
//  MyMovies
//
//  Created by Un on 10/14/16.
//  Copyright © 2016 Un. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var popularLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var popularIcon: UIImageView!
    @IBOutlet weak var voteIcon: UIImageView!
    
    
    var posterUrl: String!
    var titleFilm: String!
    var overviewFilm: String!
    var popularCount: Float!
    var voteCount: Float!
    var dateRelease: String!
    
    let lowResUrl = "https://image.tmdb.org/t/p/w45"
    let highResUrl = "https://image.tmdb.org/t/p/original"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadPosterView()
        
        titleLabel.text = titleFilm
        overviewLabel.text = overviewFilm
        
        popularIcon.image = #imageLiteral(resourceName: "iconmonstr-favorite-4-16")
        voteIcon.image = #imageLiteral(resourceName: "iconmonstr-thumb-10-16")
        
        popularLabel.text = String(format: "%.2f", popularCount)
        voteLabel.text = String(format: "%.2f", voteCount)
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dateRelease)
        
        formatter.dateStyle = .long
        dateRelease = formatter.string(from: date!)
        
        dateLabel.text = dateRelease
        
        resizeScrollView()
        
    }
    
    func loadPosterView() {
        
        if posterUrl != nil {

            let smallImageRequest = NSURLRequest(url: NSURL(string: (lowResUrl + posterUrl))! as URL)
            let largeImageRequest = NSURLRequest(url: NSURL(string: (highResUrl + posterUrl))! as URL)
            
            posterView.setImageWith(
                smallImageRequest as URLRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    // imageResponse will be nil if the image is cached
                    if smallImageResponse != nil {
                        self.posterView.alpha = 0.0
                        self.posterView.image = smallImage;
                        
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            
                            self.posterView.alpha = 1.0
                            
                            }, completion: { (sucess) -> Void in
                                
                                // The AFNetworking ImageView Category only allows one request to be sent at a time
                                // per ImageView. This code must be in the completion block.
                                self.posterView.setImageWith(
                                    largeImageRequest as URLRequest,
                                    placeholderImage: smallImage,
                                    success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                        
                                        self.posterView.image = largeImage;
                                        
                                    },
                                    failure: { (request, response, error) -> Void in
                                        // do something for the failure condition of the large image request
                                        // possibly setting the ImageView's image to a default image
                                })
                        })
                    }else{
                        
                        self.posterView.setImageWith(
                            largeImageRequest as URLRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                self.posterView.image = largeImage;
                                
                            },
                            failure: { (request, response, error) -> Void in
                                // do something for the failure condition of the large image request
                                // possibly setting the ImageView's image to a default image
                        })
                        
                    }
                },
                failure: { (request, response, error) -> Void in
                    // do something for the failure condition
                    // possibly try to get the large image
            })
            
            
        }
        else {
            self.posterView.image = nil
        }
    }
    
    func resizeScrollView(){
        titleLabel.sizeToFit()
        overviewLabel.sizeToFit()
        
        let groupViewHeigth = groupView.bounds.height
        
        let groupViewNewHeight = titleLabel.bounds.height + overviewLabel.bounds.height + dateLabel.bounds.height + popularLabel.bounds.height + 70
        
        groupView.frame.size.height = groupViewNewHeight
        
        scrollView.contentSize.height = scrollView.bounds.height + (groupViewNewHeight - groupViewHeigth)
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
