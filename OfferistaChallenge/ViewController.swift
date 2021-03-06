//
//  ViewController.swift
//  OfferistaChallenge
//
//  Created by Feliks Scholze on 03.03.17.
//  Copyright © 2017 Feliks Scholze. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var section1CollectionView: UICollectionView!
    @IBOutlet weak var section3CollectionView: UICollectionView!
    @IBOutlet weak var section2CollectionView: UICollectionView!
    
    let SECTION1_ENTRIES = 4 // Number of Products in Section 1
    var arraySection1 = [Product]() // array to hold all 4 Products of Section 1
    
    let SECTION3_ENTRIES = 9 // Number of Products in Section 1
    var arraySection3 = [Product]() // array to hold all Products of Section 3
    
    var section2_entries = 4 // Number of Products in Section 1
    var arraySection2 = [Product]() // array to hold all Products of Section 3
    
    let URL_SECTION_1 = "https://s3-eu-west-1.amazonaws.com/offerista-challenge/1.json"
    let URL_SECTION_2 = "https://s3-eu-west-1.amazonaws.com/offerista-challenge/2.json"
    let URL_SECTION_3 = "https://s3-eu-west-1.amazonaws.com/offerista-challenge/3.json"
    
    var currentProductTitle = ""
    
    struct Product {
        var category = ""
        var title = ""
        var imageUrl = ""
        var price = ""
        var company = ""
    }
    
    func downloadData(url: String, section: Int) {
        // Download Data
        if let _url = URL(string: url) {
            
            let request = NSMutableURLRequest(url: _url)
            
            // Task wird defintiert
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                if error != nil {
                    print(error)
                } else {
                    if let unwrappedData = data {
                        
                        do {
                            let jsonResult = try JSONSerialization.jsonObject(with: unwrappedData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                            // Section 1
                            if section == 1 {
                                for i in 0...(self.SECTION1_ENTRIES-1) {
                                    self.arraySection1.append(self.jsonToProduct(json: jsonResult[i] as! NSDictionary))
                                }
                                DispatchQueue.main.sync(execute: {
                                    self.section1CollectionView.reloadData()
                                })
                            } else
                            
                            // Section 2
                                if section == 2 {
                                    for i in 0...(self.section2_entries-1) {
                                        self.arraySection2.append(self.jsonToProduct(json: jsonResult[i] as! NSDictionary))
                                    }
                                    DispatchQueue.main.sync(execute: {
                                        self.section2CollectionView.reloadData()
                                    })
                            } else
                            // Section 3
                            if section == 3 {
                                for i in 0...(self.SECTION3_ENTRIES-1) {
                                    self.arraySection3.append(self.jsonToProduct(json: jsonResult[i] as! NSDictionary))
                                }
                                DispatchQueue.main.sync(execute: {
                                    self.section3CollectionView.reloadData()
                                })
                            }
                        } catch {
                            print("JSON Processing Failed")
                        }
                        
                    }
                }
            }
            // start task
            task.resume()
        }
    }

    func jsonToProduct(json: NSDictionary) -> Product { // Make a Product struct of json entry
        var _product = Product()
        _product.title = json["title"] as! String
        _product.category = json["category"] as! String
        _product.imageUrl = json["image"] as! String
        _product.price = json["price"] as! String
        _product.company = json["company"] as! String
        
        return _product
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        downloadData(url: URL_SECTION_1, section: 1)
        downloadData(url: URL_SECTION_2, section: 2)
        downloadData(url: URL_SECTION_3, section: 3)
        
        self.pageControl.currentPage = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    
    // Collection Views
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView.tag == 1) { // Section 1
            return SECTION1_ENTRIES
        }
        if (collectionView.tag == 3) { // Section 3
            return SECTION3_ENTRIES
        }
        if (collectionView.tag == 2) { // Section 3
            return section2_entries
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView.tag {
        case 1:
            let cell: Section1CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Section1CollectionViewCell
            let _index = indexPath.row
            if (arraySection1.count >= SECTION1_ENTRIES) {
                cell.setTitel(title: arraySection1[_index].title)
                cell.setCategory(category: arraySection1[_index].category)
                cell.setImage(url: arraySection1[_index].imageUrl)
                cell.tag = _index
            }
            return cell
        case 2:
            let cell: Section2CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Section2CollectionViewCell
            if (arraySection2.count >= section2_entries) {
                let _index = indexPath.row
                cell.setImage(url: arraySection2[_index].imageUrl)
                cell.tag = _index
            }
            return cell
        case 3:
            let cell: Section3CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Section3CollectionViewCell
           
            if (arraySection3.count >= SECTION3_ENTRIES) {
                
                let _index = indexPath.row
                cell.setTitel(title: arraySection3[_index].title)
                cell.setCompany(company: arraySection3[_index].company)
                cell.setImage(url: arraySection3[_index].imageUrl)
                cell.tag = _index
                cell.setPrice(price: arraySection3[_index].price)
            }
            
            
            return cell
        default:
            print("error - collectionView")
            let cell: Section1CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Section1CollectionViewCell
            return cell
        }
    }
    
    
    func downloadMoreForSection2(lastEntryIndex: Int) {
        self.section2_entries += 5
        if let _url = URL(string: URL_SECTION_2) {
            
            let request = NSMutableURLRequest(url: _url)
            
            // Task wird defintiert
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                if error != nil {
                    print(error)
                } else {
                    if let unwrappedData = data {
                        do {
                            let jsonResult = try JSONSerialization.jsonObject(with: unwrappedData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                            for i in lastEntryIndex...(self.section2_entries-1) {
                                if (i<jsonResult.count) {
                                    if let dict = jsonResult[i] as? NSDictionary {
                                        self.arraySection2.append(self.jsonToProduct(json: dict))
                                    } else {
                                        self.section2_entries = i
                                        return
                                    }
                                } else {
                                    self.section2_entries = i
                                    return
                                }
                                
                            }
                            DispatchQueue.main.sync(execute: {
                                self.section2CollectionView.reloadData()
                            })
                        } catch {
                            print("JSON Processing Failed")
                        }
                    }
                }
            }
            // task wird gestartet
            task.resume()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 { // if Section 1, then change page controller
            self.pageControl.currentPage = indexPath.row
        } else {
            if collectionView.tag == 2 { // if section 2, then download more images
                if (indexPath.row >= section2_entries-4) {
                    downloadMoreForSection2(lastEntryIndex: section2_entries)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var _product = Product()
        switch collectionView.tag {
        case 1: // Section 1
            _product = arraySection1[indexPath.row]
        case 2: // Section 2
            _product = arraySection2[indexPath.row]
        case 3: // Section 3
            _product = arraySection3[indexPath.row]
        default:
            return
        }
        currentProductTitle = _product.title
        performSegue(withIdentifier: "showProduct", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProduct" {
            let secondViewController = segue.destination as! DetailViewController
            secondViewController.productTitle = currentProductTitle
        }
    }
}

