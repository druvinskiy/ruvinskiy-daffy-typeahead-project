//
//  UITableView+Ext.swift
//  RuvinskiyDaffyTypeaheadProject
//
//  Created by David Ruvinskiy on 12/19/22.
//

import UIKit

extension UITableView {
    
    func removeExcessCells() {
        tableFooterView = UIView(frame: .zero)
    }
}

extension UITableViewController {
    func reloadDataOnMainThread() {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}
