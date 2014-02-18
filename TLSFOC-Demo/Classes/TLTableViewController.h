//
//  TLTableViewController.h
//  TLSFOC-Demo
//
//  Created by Ash Furrow on 2013-07-29.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMMoveTableView.h"


@class TLTableViewController;

@protocol TLTableViewControllerDelegate <NSObject>

- (void)tableViewController:(TLTableViewController *)viewController didChangeEditing:(BOOL)editing;
- (void)presentActionSheet:(UIActionSheet *)actionSheet fromViewController:(TLTableViewController *)viewController;

@end

@interface TLTableViewController : UIViewController <FMMoveTableViewDataSource, FMMoveTableViewDelegate>

@property (nonatomic, strong) IBOutlet FMMoveTableView *tableView;

@property (nonatomic, weak) id<TLTableViewControllerDelegate> delegate;

- (void)insertNewObject:(id)sender;
- (void)deleteSelectedCells;

@end
