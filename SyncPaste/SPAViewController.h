//
//  SPAViewController.h
//  SyncPaste
//
//  Created by Giles Williams on 11/07/2013.
//  Copyright (c) 2013 Giles Williams. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>

@interface SPAViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property bool firstAppear;
@property bool loggedIn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (retain) DBDatastore *dataStore;
@property (retain) DBTable *clipTbl;
@property (retain) NSArray *clips;

- (IBAction)pressedAdd:(id)sender;
- (IBAction)pressedLogout:(id)sender;

@end
