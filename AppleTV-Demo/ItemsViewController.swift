//
//  ItemsViewController.swift
//  AppleTV-Demo
//
//  Created by Nicky Gerritsen on 27-12-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import UIKit

class ItemsViewController: UICollectionViewController {
    var livestream: LiveStream!

    var items: [Item]?
    var totalItemCount: Int?

    private let cellComposer = ItemCellComposer()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadAdditionalItems()
    }

    /**
        Load an adiitional set of items
    */
    func loadAdditionalItems() {
        do {
            let itemsRequest = try ApiManager.newRequest(command: "item", action: "view")
            itemsRequest.setArgument("offset", value: self.items?.count ?? 0)
            itemsRequest.setArgument("order", value: "desc")
            itemsRequest.execute { [weak self] response in
                if response.valid {
                    if let extraItems: [Item] = response.typedBody() {
                        if self?.items == nil {
                            self?.items = []
                        }

                        self?.totalItemCount = response.header.allFields["count"] as? Int

                        if extraItems.count > 0 {
                            var indexPaths: [NSIndexPath] = []
                            if let start = self?.items?.count {
                                for var i = 0; i < extraItems.count; i++ {
                                    indexPaths.append(NSIndexPath(forItem: start + i, inSection: 0))
                                }

                                self?.items?.appendContentsOf(extraItems)
                                self?.collectionView?.insertItemsAtIndexPaths(indexPaths)
                            }
                        }
                    }
                }
            }
        } catch {
            self.displayLoadingErrorAlert()
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // The collection view shows all items in a single section.
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Dequeue a cell from the collection view.
        return collectionView.dequeueReusableCellWithReuseIdentifier(R.reuseIdentifier.itemCell, forIndexPath: indexPath)!
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? ItemCell else { fatalError("Expected to display a `ItemCell`.") }

        if indexPath.row + 1 == items?.count && totalItemCount > items?.count {
            self.loadAdditionalItems()
        }

        if let item = items?[indexPath.row] {

            // Configure the cell.
            cellComposer.composeCell(cell, withItem: item)
        }
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        if let item = items?[indexPath.row] {
//            let itemDetailViewController = R.storyboard.itemDetail.itemDetail!
//            itemDetailViewController.item = item
//            presentViewController(itemDetailViewController, animated: true, completion: nil)
//        }
    }

    private func displayLoadingErrorAlert() {
        let title = "Kan gemist niet laden"
        let message = "Probeer het a.u.b. opnieuw"
        displayOKAlert(title, message: message)
    }
}
