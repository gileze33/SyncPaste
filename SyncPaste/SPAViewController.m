//
//  SPAViewController.m
//  SyncPaste
//
//  Created by Giles Williams on 11/07/2013.
//  Copyright (c) 2013 Giles Williams. All rights reserved.
//

#import "SPAViewController.h"
#import "SPALoginViewController.h"

@interface SPAViewController ()

@end

@implementation SPAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.firstAppear = YES;
    self.loggedIn = NO;
    self.clips = [[NSArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChanged) name:@"loginStateChanged" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    if(self.firstAppear) {
        DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
        if (account) {
            NSLog(@"App already linked yah");
            
            [self loginStateChanged];
        } else {
            SPALoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
            [self presentViewController:loginVC animated:YES completion:^{
                
            }];
        }
        
        self.firstAppear = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginStateChanged {
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
        self.loggedIn = YES;
        self.dataStore = [DBDatastore openDefaultStoreForAccount:account error:nil];
        self.clipTbl = [self.dataStore getTable:@"clips"];
    }
    else {
        self.loggedIn = NO;
    }
    
    self.navigationItem.leftBarButtonItem.enabled = self.loggedIn;
    self.navigationItem.rightBarButtonItem.enabled = self.loggedIn;
    self.tableView.userInteractionEnabled = self.loggedIn;
    [self reload];
}

- (void)reload {
    if(self.loggedIn) {
        [self.dataStore sync:nil];
        self.clips = [self.clipTbl query:@{  } error:nil];
    }
    [self.tableView reloadData];
}

- (IBAction)pressedAdd:(id)sender {
    NSString *clipData = [UIPasteboard generalPasteboard].string;
    if(clipData && ![clipData isEqualToString:@""]) {
        DBRecord *theClipRow = [self.clipTbl insert:@{ @"type": @"text", @"data": clipData, @"created": [NSDate dateWithTimeIntervalSinceNow:0] }];
        [self.dataStore sync:nil];
        
        [self reload];
    }
    else {
        NSLog(@"No data");
    }
}

- (IBAction)pressedLogout:(id)sender {
    self.loggedIn = NO;
    self.dataStore = nil;
    self.clipTbl = nil;
    self.clips = [[NSArray alloc] init];
    
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    [account unlink];
    
    [self loginStateChanged];
    
    SPALoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self presentViewController:loginVC animated:YES completion:^{
        
    }];
}


#pragma mark UITableViewDataSource methods

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.loggedIn) {
        return self.clips.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClipCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    
    if(indexPath.row < self.clips.count) {
        DBRecord *clip = [self.clips objectAtIndex:indexPath.row];
        
        if([clip[@"type"] isEqualToString:@"text"]) {
            cell.textLabel.text = clip[@"data"];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return(YES);
}

@end
