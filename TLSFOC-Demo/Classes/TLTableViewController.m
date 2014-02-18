//
//  TLTableViewController.m
//  TLSFOC-Demo
//
//  Created by Ash Furrow on 2013-07-29.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLTableViewController.h"

#import "TLSwipeForOptionsCell.h"
#import "TLContainerViewController.h"
#import "TLOverlayView.h"


@interface TLTableViewController () <TLSwipeForOptionsCellDelegate, TLOverlayViewDelegate, UIActionSheetDelegate> {
	NSMutableArray *_objects;
}

// We need to keep track of the most recently selected cell for the action sheet.
@property (nonatomic, weak) UITableViewCell *cellDisplayingMenuOptions;
@property (nonatomic, weak) UITableViewCell *mostRecentlySelectedMoreCell;
@property (nonatomic, strong) TLOverlayView *overlayView;

@end

@implementation TLTableViewController

@synthesize tableView;

- (void)viewDidLoad
{
	[super viewDidLoad];
//	self.navigationItem.rightBarButtonItem = self.editButtonItem;
//	
//	self.tableView.allowsSelectionDuringEditing = YES;
//	self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    for (int i = 0; i < 20; i++) {
        if (!_objects) {
            _objects = [[NSMutableArray alloc] init];
        }
        [_objects insertObject:[NSDate date] atIndex:0];
    }

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	// Need to do this to keep the view in a consistent state (layoutSubviews in the cell expects itself to be "closed")
	[[NSNotificationCenter defaultCenter] postNotificationName:TLSwipeForOptionsCellShouldHideMenuNotification object:self.tableView];
}

#pragma mark - Public Methods

// Method to delete the cells that are currently selected.
- (void)deleteSelectedCells
{
	NSArray *indexPathsOfSelectedCells = [self.tableView indexPathsForSelectedRows];

	// MUST be enumerated in reverse order otherwise the _objects indices become invalid.
	[indexPathsOfSelectedCells enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
		[_objects removeObjectAtIndex:obj.row];
	}];
	
	[self.tableView deleteRowsAtIndexPaths:indexPathsOfSelectedCells withRowAnimation:UITableViewRowAnimationAutomatic];
}

// Inserts a new object into the _objects array.
- (void)insertNewObject:(id)sender
{
	if (!_objects) {
		_objects = [[NSMutableArray alloc] init];
	}
	[_objects insertObject:[NSDate date] atIndex:0];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	
    [self.tableView reloadData];
    
	// Need to call this whenever we scroll our table view programmatically
	[[NSNotificationCenter defaultCenter] postNotificationName:TLSwipeForOptionsCellShouldHideMenuNotification object:self.tableView];
}

#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger numberOfRows = _objects.count;
	
    //#warning Implement this check in your table data source
	/******************************** NOTE ********************************
	 * Implement this check in your table view data source to ensure correct access to the data source
	 *
	 * The data source is in a dirty state when moving a row and is only being updated after the user
	 * releases the moving row
	 **********************************************************************/
	
	// 1. A row is in a moving state
	// 2. The moving row is not in it's initial section
//	if (tableView.movingIndexPath && tableView.movingIndexPath.section != tableView.initialIndexPathForMovingRow.section)
//	{
//		if (section == tableView.movingIndexPath.section) {
//			numberOfRows++;
//		}
//		else if (section == tableView.initialIndexPathForMovingRow.section) {
//			numberOfRows--;
//		}
//	}
	
	return numberOfRows;
}

- (UITableViewCell *)tableView:(FMMoveTableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TLSwipeForOptionsCell *cell = (TLSwipeForOptionsCell *)[tv dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

	NSDate *object = _objects[indexPath.row];
	cell.textLabel.text = [object description];
    cell.scrollViewDetailLabel.text = @"";
	cell.delegate = self;
	
	return cell;
}

- (void)moveTableView:(FMMoveTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"DID SELECT ROW AT INDEX PATH %@",indexPath);
}

- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
//	NSArray *movie = [[self.movies objectAtIndex:fromIndexPath.section] objectAtIndex:fromIndexPath.row];
//	[[self.movies objectAtIndex:fromIndexPath.section] removeObjectAtIndex:fromIndexPath.row];
//	[[self.movies objectAtIndex:toIndexPath.section] insertObject:movie atIndex:toIndexPath.row];
//	
//	DLog(@"Moved row from %@ to %@", fromIndexPath, toIndexPath);
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//	// Return NO if you do not want the specified item to be editable.
//	return YES;
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return UITableViewCellEditingStyleNone;
//}
//
//- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
//	[super setEditing:editing animated:animated];
//	[[NSNotificationCenter defaultCenter] postNotificationName:TLSwipeForOptionsCellShouldHideMenuNotification object:self.tableView];
//	[self.delegate tableViewController:self didChangeEditing:editing];
//}

#pragma UIScrollViewDelegate Methods 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[[NSNotificationCenter defaultCenter] postNotificationName:TLSwipeForOptionsCellShouldHideMenuNotification object:scrollView];
}

#pragma mark - TLOverlayViewDelegate Methods

- (UIView *)overlayView:(TLOverlayView *)view didHitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	BOOL shouldInterceptTouches = YES;
	
	CGPoint location = [self.tableView convertPoint:point fromView:view];
	CGRect rect = [self.tableView convertRect:self.cellDisplayingMenuOptions.frame toView:self.tableView];
	
   // NSLog(@"%@",self.cellDisplayingMenuOptions.frame);
    
	shouldInterceptTouches = CGRectContainsPoint(rect, location);
	if (shouldInterceptTouches) {
        NSLog(@"Inside should intercept");

    } else {
        NSLog(@"Inside should not intercept");
        [[NSNotificationCenter defaultCenter] postNotificationName:TLSwipeForOptionsCellShouldHideMenuNotification object:self.tableView];
    }

	
	return shouldInterceptTouches?[self.cellDisplayingMenuOptions hitTest:point withEvent:event]:view;
}

#pragma mark - TLSwipeForOptionsCellDelegate Methods

- (void)cell:(TLSwipeForOptionsCell *)cell didShowMenu:(BOOL)isShowingMenu
{
	self.cellDisplayingMenuOptions = cell;
	[self.tableView setScrollEnabled:!isShowingMenu];
	if (isShowingMenu) {
		if (!self.overlayView) {
			self.overlayView = [[TLOverlayView alloc] initWithFrame:self.tableView.bounds];
			[self.overlayView setDelegate:self];
		}
		
		[self.overlayView setFrame:self.view.bounds];
		[self.view addSubview:self.overlayView];
		
		for (id subview in [self.tableView subviews]) {
			if (![subview isEqual:cell] && [subview isKindOfClass:[TLSwipeForOptionsCell class]])
				[subview setUserInteractionEnabled:NO];
		}
	} else {
		[self.overlayView removeFromSuperview];
		
		for (id subview in [self.tableView subviews]) {
			if (![subview isEqual:cell] && [subview isKindOfClass:[TLSwipeForOptionsCell class]])
				[subview setUserInteractionEnabled:YES];
		}
	}
}

- (void)cellDidSelectDelete:(TLSwipeForOptionsCell *)cell
{
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	
	[_objects removeObjectAtIndex:indexPath.row];
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

@end
