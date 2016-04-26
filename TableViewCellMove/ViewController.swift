//
//  ViewController.swift
//  TableViewCellMove
//
//  Created by Xinxibin on 16/4/26.
//  Copyright © 2016年 Xinxibin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var snapshotView:UIView?
    var sourceIndexPath:NSIndexPath?
    
    @IBOutlet weak var tableView: UITableView!
    
    var titleList:NSMutableArray = ["hello word","Xin","newWord","tableView","Cell","IndexPath","viewController","Main","storyboard","launchScreen"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action:#selector(ViewController.longPressGestureRecognized(_:)))
        self.tableView.addGestureRecognizer(longPress)
        self.tableView.registerNib(UINib(nibName: "MyTableViewCell",bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    
    func longPressGestureRecognized(sender:AnyObject) {
        
        let longPress = sender as! UILongPressGestureRecognizer
        let state = longPress.state
        let location = longPress.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        
        switch state {
        case .Began:
            
            if indexPath != nil {
                
                sourceIndexPath = indexPath
                
                let cell = self.tableView.cellForRowAtIndexPath(indexPath!)
                snapshotView = self.customSnapshotFromView(cell!)
                
                var center = cell?.center
                snapshotView?.center = center!
                snapshotView?.alpha = 0.0
                self.tableView.addSubview(snapshotView!)
                
                UIView.animateWithDuration(0.25, animations: {
                    center?.y = location.y
                    self.snapshotView?.center = center!
                    self.snapshotView?.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    self.snapshotView?.alpha = 0.98
                    cell?.alpha = 0.0
                    },completion: { (finished) in
                        
                        cell?.hidden = true
                })
            }
            
            break
        case .Changed:
            var  center = snapshotView?.center
            center?.y = location.y
            snapshotView?.center = center!
            
            if indexPath != nil && !(indexPath?.isEqual(sourceIndexPath))! {
                
                self.titleList.exchangeObjectAtIndex((indexPath?.row)!, withObjectAtIndex: (sourceIndexPath?.row)!)
                self.tableView.moveRowAtIndexPath(sourceIndexPath!, toIndexPath: indexPath!)
                sourceIndexPath = indexPath
                
            }
            break
            
        default:
            
            let cell = self.tableView.cellForRowAtIndexPath(sourceIndexPath!)
            cell?.alpha = 0.0
            
            UIView.animateWithDuration(0.25, animations: {
                self.snapshotView?.center = cell!.center
                self.snapshotView?.transform = CGAffineTransformIdentity
                self.snapshotView?.alpha = 0.0
                cell?.alpha = 1.0
                cell?.backgroundColor = UIColor.whiteColor()
                }, completion: { (finished) in
                    cell?.hidden = false
                    self.sourceIndexPath = nil
                    self.snapshotView?.removeFromSuperview()
                    self.snapshotView = nil
            })
            
            break
        }
        
    }
    
    func customSnapshotFromView(inputView:UIView) ->UIView {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        snapshot.layer.shadowOpacity = 0.4
        return snapshot
    }
    
}

extension ViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MyTableViewCell
        
        cell.textLabel?.text  = titleList[indexPath.row] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
}

extension ViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.titleList.removeObjectAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("\(titleList[indexPath.row])")
    }
    
}