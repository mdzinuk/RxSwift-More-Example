//
//  RxTableViewController.swift
//  RxNetworking
//
//  Created by Md. Arafat Hossain zinuk on 7/30/17.
//  Copyright © 2017 Md. Arafat Hossain zinuk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

/*
 This project shows only the github latest activity of RxSwift(i.e likes, comments)
 */
class RxTableViewController: UITableViewController {
    
    let repo = "ReactiveX/RxSwift"
    
    fileprivate let events = BehaviorRelay<[GithubModel]>(value: [])
    fileprivate let bag = DisposeBag()
    fileprivate let lastModified = BehaviorRelay<String>(value: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Github"
        
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        
        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refresh()
        
        //
        lastModified.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe({
                refreshControl.attributedTitle = NSAttributedString(string: $0.element ?? "")
            }).disposed(by: bag)
    }
    
    @objc func refresh() {
        fetchEvents(repo: repo)
    }
    
    func fetchEvents(repo: String) {
        // Create Observable to rxSwift repo
        
        _ = Observable.from([repo])
            .map { URL(string: "https://api.github.com/repos/\($0)/events") }
            .filter { $0 != nil } // filter nil URL
            .map { URLRequest(url: $0!) } // Map URL request(response, data)
            .flatMapLatest { request in
                return URLSession.shared.rx.response(request: request) // receives the full response from the web server
            }
            .share(replay: 1) //to share the observable and keep in a buffer the last emitted event
            .filter { response, _ in
                return 200..<300 ~= response.statusCode // return response when status code are between 200 and 300
            }
            .map { [weak self](response, data) -> [[String: Any]] in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []), let result = jsonObject as? [[String: Any]], let lastModifled = response.allHeaderFields["Last-Modified"] as? String else {
                    return []
                }
                self?.lastModified.accept(lastModifled)
                return result
            }
            .filter { (objects: [[String : Any]]) -> Bool in
                return objects.count > 0 // If data array is greater than 0
            }
            .map { (objects: [[String : Any]]) -> [GithubModel] in
                return objects.compactMap(GithubModel.init) // Merge/ remove nil model
            }
            .retry(3) // If faile try 3 times
            .observeOn(MainScheduler.instance) // Subscribe data into main thread
            .subscribe(onNext: { [weak self] (models: [GithubModel]) in
                self?.processEvents(models)
                }, onError: { error in
                    print(error)
            })
            .disposed(by: bag)
    }
    
    func cachedFileURL(_ fileName: String) -> URL {
        return FileManager.default
            .urls(for: .cachesDirectory, in: .allDomainsMask)
            .compactMap { $0 }
            .first!
            .appendingPathComponent(fileName)
    }
    
    
    func processEvents(_ models: [GithubModel]) {
        
        print("main: \(Thread.isMainThread)")
        var updatedEvents = models + events.value
        if updatedEvents.count > 50 {
            updatedEvents = Array<GithubModel>(updatedEvents.prefix(upTo: 50))
        }
        events.accept(updatedEvents)
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Table Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events.value[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.repo + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
        cell.imageView?.kf.setImage(with: event.imageUrl, placeholder: UIImage(named: "blank-avatar"))
        return cell
    }
    
}
