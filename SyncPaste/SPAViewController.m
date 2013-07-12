//
//  SPAViewController.m
//  SyncPaste
//
//  Created by Giles Williams on 11/07/2013.
//  Copyright (c) 2013 Giles Williams. All rights reserved.
//

#import "SPAViewController.h"
#import "SPALoginViewController.h"
#import "WBSuccessNoticeView.h"
#import "WBErrorNoticeView.h"

@interface SPAViewController ()

@end

@implementation SPAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.firstAppear = YES;
    self.loggedIn = NO;
    self.editing = NO;
    self.clips = [[NSArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStateChanged) name:@"loginStateChanged" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    if(self.firstAppear) {
        
        self.refresh = [[UIRefreshControl alloc] init];
        [self.refresh addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refresh];
        
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
        [self.refresh beginRefreshing];
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
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [self.tableView reloadData];
            [self.refresh endRefreshing];
  //      });
    }
    else {
        [self.tableView reloadData];
        [self.refresh endRefreshing];
    }
}

- (NSString *)formattedDate:(NSDate *)date
{
    NSTimeInterval timeSinceDate = [[NSDate date] timeIntervalSinceDate:date];
    
    // print up to 24 hours as a relative offset
    if(timeSinceDate < 24.0 * 60.0 * 60.0)
    {
        int hoursSinceDate = (timeSinceDate / (60.0 * 60.0));
        int minutesSinceDate;
        switch(hoursSinceDate)
        {
            default: return [NSString stringWithFormat:@"%ih", hoursSinceDate];
            case 1: return @"1h";
            case 0:
                minutesSinceDate = (timeSinceDate / 60.0);
                return [NSString stringWithFormat:@"%im", minutesSinceDate];
                /* etc, etc */
                break;
        }
    }
    else
    {
        /* normal NSDateFormatter stuff here */
        return @"meh";
    }
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
        /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No data in clipboard" message:@"Copy some text from another app and then press the + button" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];*/
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Clipboard Empty" message:@"You need to copy some text into your clipboard from another app first!"];
        [notice show];
    }
}

- (IBAction)pressedEdit:(id)sender {
    /*self.loggedIn = NO;
    self.dataStore = nil;
    self.clipTbl = nil;
    self.clips = [[NSArray alloc] init];
    
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    [account unlink];
    
    [self loginStateChanged];
    
    SPALoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self presentViewController:loginVC animated:YES completion:^{
        
    }];*/
    
    if(!self.editing) {
        self.editing = YES;
        [sender setTitle:@"Done"];
        [self.tableView setEditing:YES animated:YES];
    }
    else {
        self.editing = NO;
        [sender setTitle:@"Edit"];
        [self.tableView setEditing:NO animated:YES];
    }
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        if(indexPath.row < self.clips.count) {
            DBRecord *clip = [self.clips objectAtIndex:indexPath.row];
            [clip deleteRecord];
            [self.dataStore sync:nil];
            NSMutableArray *newClips = [NSMutableArray arrayWithArray:self.clips];
            [newClips removeObjectAtIndex:indexPath.row];
            self.clips = newClips;
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClipCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ClipCell"];
    }
    
    if(indexPath.row < self.clips.count) {
        DBRecord *clip = [self.clips objectAtIndex:indexPath.row];
        
        if([clip[@"type"] isEqualToString:@"text"]) {
            cell.textLabel.text = clip[@"data"];
        }
        
        NSDate *created = (NSDate *)clip[@"created"];
        long timeSinceDate = abs([created timeIntervalSinceNow]);
        NSString *dateStr = @"";
        if(timeSinceDate < 24.0 * 60.0 * 60.0) {
            int hoursSinceDate = (timeSinceDate / (60.0 * 60.0));
            int minutesSinceDate;
            switch(hoursSinceDate)
            {
                default: dateStr = [NSString stringWithFormat:@"%ih", hoursSinceDate];
                case 1: dateStr =  @"1h";
                case 0:
                    minutesSinceDate = (timeSinceDate / 60.0);
                    dateStr = [NSString stringWithFormat:@"%im", minutesSinceDate];
                    /* etc, etc */
                    break;
            }
        }
        else {
            int daysSinceDate = (timeSinceDate / (24.0 * 60.0 * 60.0));
            dateStr = [NSString stringWithFormat:@"%id", daysSinceDate];
        }
        
        cell.detailTextLabel.text = dateStr;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row < self.clips.count) {
        DBRecord *clip = [self.clips objectAtIndex:indexPath.row];
        
        if([clip[@"type"] isEqualToString:@"text"]) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = clip[@"data"];
            
            WBSuccessNoticeView *notice = [WBSuccessNoticeView successNoticeInView:self.view title:@"Copied text to clipboard"];
            [notice show];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return(YES);
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}

@end
