//
//  ViewController.swift
//  Project7
//
//  Created by Michael Ng on 6/12/22.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    var filterKeyword = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "More", image: nil, target: self , action: #selector(tapMore))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", image: nil , target: self, action: #selector(tapFilter))
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
    
    @objc func fetchJSON() {
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString){
            if let data = try? Data(contentsOf: url){
                parse(json: data)
                return
                }
            }
        
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        
    }
    
    @objc func tapFilter(){
        let ac = UIAlertController(title: "Filter...", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title:"Filter...", style: .default){ [weak self, weak ac] _ in
            self?.filterKeyword = ac?.textFields?[0].text ?? ""
            self?.filterData()
            self?.tableView.reloadData()
        })
        
        present(ac,animated: true)
    }
    
    @objc func tapMore(){
        let ac = UIAlertController(title: "Details", message: "This data comes from the We the People API of the WhiteHouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac,animated: true)
    }
    
    @objc func filterData(){
        if filterKeyword.isEmpty {
            filteredPetitions = petitions
            navigationItem.leftBarButtonItem?.title = "Filter"
            return
        }
        
        navigationItem.leftBarButtonItem?.title = "Filter (current: \(filterKeyword))"
        
        filteredPetitions = petitions.filter() { petition in
            if let _ = petition.title.range(of: filterKeyword, options: .caseInsensitive) {
                return true
            }
            if let _ = petition.body.range(of: filterKeyword, options: .caseInsensitive){
                return true
            }
            return false
        }
    }
    
    @objc func showError(){
        let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed; please check your connection and try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac,animated: true)
    }
    
    func parse(json: Data){
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json){
            petitions = jsonPetitions.results
            performSelector(onMainThread: #selector(filterData), with: nil, waitUntilDone: false)
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = petition.title
        content.secondaryText = petition.body
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}

