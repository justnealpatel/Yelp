//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Neal Patel on 2/13/16.
//  Copyright (c) 2015 Neal Patel. All rights reserved.
//

import UIKit

extension BusinessesViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, FiltersViewControllerDelegate {

    @IBOutlet weak var restaurantTableView: UITableView!
    
    var businesses: [Business]!
    let searchController = UISearchController(searchResultsController: nil)
    var filteredBusinesses = [Business]()
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = restaurantTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - restaurantTableView.bounds.size.height
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && restaurantTableView.dragging) {
                isMoreDataLoading = true
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, restaurantTableView.contentSize.height, restaurantTableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                // Code to load more results
                loadMore()
            }
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredBusinesses = businesses.filter{ businesses in
            return businesses.name!.lowercaseString.containsString(searchText.lowercaseString)}
        print(filteredBusinesses)
        restaurantTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchBar.barTintColor = UIColor(red: 231/255, green: 119/255, blue: 118/255, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 231/255, green: 119/255, blue: 118/255, alpha: 1.0)
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, restaurantTableView.contentSize.height, restaurantTableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        restaurantTableView.addSubview(loadingMoreView!)
        
        var insets = restaurantTableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        restaurantTableView.contentInset = insets
        restaurantTableView.dataSource = self
        restaurantTableView.delegate = self
        restaurantTableView.rowHeight = UITableViewAutomaticDimension
        restaurantTableView.estimatedRowHeight = 120
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        restaurantTableView.tableHeaderView = searchController.searchBar
        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.restaurantTableView.reloadData()
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        })

/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
    }
    
    func loadMore() {
        Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.restaurantTableView.reloadData()
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active && searchController.searchBar.text != "" {
            return filteredBusinesses.count
        } else {
            if businesses != nil {
                return businesses!.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = restaurantTableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        if searchController.active && searchController.searchBar.text != "" {
            cell.business = filteredBusinesses[indexPath.row]
        } else {
            cell.business = businesses[indexPath.row]
        }
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        let categories = filters["categories"] as! [String]
        Business.searchWithTerm("Restaurants", sort: nil, categories: categories, deals: nil) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.restaurantTableView.reloadData()
        }
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