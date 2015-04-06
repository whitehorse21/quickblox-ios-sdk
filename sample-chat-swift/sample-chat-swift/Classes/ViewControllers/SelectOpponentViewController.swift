//
//  SelectOpponentViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


class SelectOpponentViewController: LoginTableViewController {
    private let kChatSegueIdentifier = "goToChat"
    private var createdDialog: QBChatDialog?
    
    override func viewDidLoad() {
        self.checkCreateChatButtonState()
    }
    
    func checkCreateChatButtonState() {
        self.navigationItem.rightBarButtonItem?.enabled = tableView.indexPathsForSelectedRows()?.count != nil
    }
    
    // called when create chat button is pressed
    @IBAction func createChat() {
        var selectedIndexes = self.tableView.indexPathsForSelectedRows() as! [NSIndexPath]
        
        var usersToChat: [QBUUser] = []
        
        for indexPath in selectedIndexes {
            var cell = self.tableView.cellForRowAtIndexPath(indexPath)!
            
            var user = ConnectionManager.instance.usersDataSource.users[cell.tag]
            usersToChat.append(user)
        }
        
        var chatDialog = QBChatDialog()
        chatDialog.occupantIDs = usersToChat.map{ $0.ID }
        
        if usersToChat.count == 1 {
            chatDialog.type = QBChatDialogTypePrivate
        }
        else {
            chatDialog.type = QBChatDialogTypeGroup
            chatDialog.name = ", ".join(usersToChat.map({ $0.login ?? $0.email }))
        }
        
        QBRequest.createDialog(chatDialog, successBlock: { [weak self] (response: QBResponse!, createdDialog: QBChatDialog!) -> Void in
            SVProgressHUD.showSuccessWithStatus("Dialog created!")
            self!.createdDialog = createdDialog
            self?.performSegueWithIdentifier(self!.kChatSegueIdentifier, sender: nil)
            println(createdDialog)
            
            }) { (response: QBResponse!) -> Void in
                println(response.error.error)
                SVProgressHUD.showErrorWithStatus(response.error.error.localizedDescription)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kChatSegueIdentifier {
            if let chatVC = segue.destinationViewController as? ChatViewController {
                chatVC.dialog = self.createdDialog
            }
        }
    }
    
    /**
    UITableView delegate methods
    */
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.checkCreateChatButtonState()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.checkCreateChatButtonState()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section) - 1 // without current user
    }

}