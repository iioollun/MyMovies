//
//  NowPlayingViewController.swift
//  MyMovies
//
//  Created by Un on 10/14/16.
//  Copyright © 2016 Un. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class NowPlayingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    
    var movies = [NSDictionary]()
    var filterMovies = [NSDictionary]()
    let lowResUrl = "https://image.tmdb.org/t/p/w45"
    let highResUrl = "https://image.tmdb.org/t/p/original"
    let refreshControl = UIRefreshControl()
    var inSearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove separator line if UITableViewCells are empty
        TableView.tableFooterView = UIView()
        
        // create search
        createSearchBar()

        // Do any additional setup after loading the view.
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        TableView.insertSubview(refreshControl, at: 0)
        
        TableView.dataSource = self
        TableView.delegate = self
        loadMoviesNowPlaying()
        
    }
    
    func createSearchBar() {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
    }
    
    func loadMoviesNowPlaying() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, error) in
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        
                                        self.movies = responseDictionary["results"] as! [NSDictionary]
                                        self.filterMovies = self.movies
                                        self.TableView.reloadData()
                                        self.hideError()
                                        
                                    }
                                }
                                if error != nil {
                                    self.showError()
                                }
                                MBProgressHUD.hide(for: self.view, animated: true)
                                
            })
        
        refreshControl.endRefreshing()
        task.resume()
    }
    
    func hideError(){
        if errorView.isHidden == false {
            errorView.isHidden = true
        }
    }
    
    func showError(){
        if errorView.isHidden {
            errorView.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowTableView = movies.count
        if inSearchMode{
            rowTableView = filterMovies.count
        }
        return rowTableView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TableView.dequeueReusableCell(withIdentifier: "movieNowPlayingCell") as! MovieNowPlayingCell
        
        var moviesData = movies
        
        if inSearchMode {
            moviesData = filterMovies
        }
        
        cell.titleLabel.text = moviesData[indexPath.row]["title"] as? String
        cell.overviewLabel.text = moviesData[indexPath.row]["overview"] as? String
        
        
        if let posterPath = moviesData[indexPath.row]["poster_path"] as? String {
            
            
            let smallImageRequest = NSURLRequest(url: NSURL(string: (lowResUrl + posterPath))! as URL)
            let largeImageRequest = NSURLRequest(url: NSURL(string: (highResUrl + posterPath))! as URL)
            
            cell.posterView.setImageWith(
                smallImageRequest as URLRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    // imageResponse will be nil if the image is cached
                    if smallImageResponse != nil {
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = smallImage;
                        
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            
                            cell.posterView.alpha = 1.0
                            
                            }, completion: { (sucess) -> Void in
                                
                                // The AFNetworking ImageView Category only allows one request to be sent at a time
                                // per ImageView. This code must be in the completion block.
                                cell.posterView.setImageWith(
                                    largeImageRequest as URLRequest,
                                    placeholderImage: smallImage,
                                    success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                        
                                        cell.posterView.image = largeImage;
                                        
                                    },
                                    failure: { (request, response, error) -> Void in
                                        // do something for the failure condition of the large image request
                                        // possibly setting the ImageView's image to a default image
                                })
                        })
                    }else{
                        
                        cell.posterView.setImageWith(
                            largeImageRequest as URLRequest,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                
                                cell.posterView.image = largeImage;
                                
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
            cell.posterView.image = nil
        }
        
        
        return cell
    }
    
    /* SEARCH BAR FUNC */
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        inSearchMode = false
        TableView.reloadData()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        if searchBar.text == nil || searchBar.text == "" {
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.text = ""
            searchBar.resignFirstResponder()
            inSearchMode = false
            TableView.reloadData()
        }else{
            searchBar.setShowsCancelButton(true, animated: true)
            inSearchMode = true
            
            filterMovies = movies.filter({ (movie) -> Bool in
                let movieTitle = movie["title"] as! String
                if movieTitle.range(of: searchText) != nil {
                    return true
                }else{
                    return false
                }
            })
            
            TableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let nextVC = segue.destination as! DetailViewController
        
        let indexPath = TableView.indexPathForSelectedRow
        
        var moviesData = movies
        if inSearchMode {
            moviesData = filterMovies
        }
        
        nextVC.posterUrl = moviesData[(indexPath?.row)!]["poster_path"] as? String
        nextVC.titleFilm = moviesData[(indexPath?.row)!]["title"] as? String
        nextVC.overviewFilm = moviesData[(indexPath?.row)!]["overview"] as? String
        nextVC.popularCount = moviesData[(indexPath?.row)!]["popularity"] as? Float
        nextVC.voteCount = moviesData[(indexPath?.row)!]["vote_average"] as? Float
        nextVC.dateRelease = moviesData[(indexPath?.row)!]["release_date"] as? String
        
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadMoviesNowPlaying()
    }
    


}
