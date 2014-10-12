//
//  CoffeeListTableViewController.m
//  Coffee
//
//  Created by Robert Blafford on 10/9/14.
//  Copyright (c) 2014 Robert Blafford. All rights reserved.
//

#import "CoffeeListTableViewController.h"
#import "CoffeeListTableViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import "CoffeeCardViewController.h"
#import "CoffeeCard+Utility.h"

static NSString *CellIdentifier = @"CoffeeCardCellIdentifier";

@interface CoffeeListTableViewController ()

@property (nonatomic, strong) CoffeeListTableViewCell *dummyCell;

@end

@implementation CoffeeListTableViewController

- (void)loadCoffeeRecipies
{
    __weak CoffeeListTableViewController *weakSelf = self;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"WuVbkuUsCXHPx3hsQzus4SE" forHTTPHeaderField:@"Authorization"];
    [manager GET:@"https://coffeeapi.percolate.com/api/coffee/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [(NSArray *)responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {            
            [CoffeeCard coffeeCardWithInfo:obj inManagedObjectContext:weakSelf.managedObjectContext];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadCoffeeRecipies];

    [self.tableView registerClass:[CoffeeListTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[self imageWithImage:[UIImage imageNamed:@"drip.png"] convertToSize:CGSizeMake(70, 70)]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:self action:@selector(test)];
}

- (void)test
{
    [self.tableView reloadData];
}

- (void)configureCell:(CoffeeListTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CoffeeCard *object = (CoffeeCard*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = object.name;
    cell.detailTextLabel.text = object.desc;
    cell.imageView.image = [UIImage imageWithData:object.imageData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CoffeeListTableViewCell *cell = (CoffeeListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CoffeeCard *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // Fill the dummy cell just like the one at indexpath would appear so we can calulate the proper cell height
    if (!self.dummyCell)
        self.dummyCell = [[CoffeeListTableViewCell alloc] init];

    self.dummyCell.textLabel.text = object.name;
    self.dummyCell.detailTextLabel.text = object.desc;
    self.dummyCell.imageView.image = [UIImage imageWithData:object.imageData];

    // Force the content to layout with custom constraints created in updateConstraints
    [self.dummyCell setNeedsUpdateConstraints];
    [self.dummyCell updateConstraintsIfNeeded];
    
    // Set the width of the cell to match the width of the table view. This is important so that we'll get the
    // correct cell height for different table view widths if the cell's height depends on its width (due to
    // multi-line UILabels word wrapping, etc). We don't need to do this above in -[tableView:cellForRowAtIndexPath]
    // because it happens automatically when the cell is used in the table view.
    // Also note, the final width of the cell may not be the width of the table view in some cases, for example when a
    // section index is displayed along the right side of the table view. You must account for the reduced cell width.
    self.dummyCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(self.dummyCell.bounds));
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints.
    // (Note that you must set the preferredMaxLayoutWidth on multi-line UILabels inside the -[layoutSubviews] method
    // of the UITableViewCell subclass, or do it manually at this point before the below 2 lines!)
    [self.dummyCell setNeedsLayout];
    [self.dummyCell layoutIfNeeded];
    
    // Get the actual height required for the cell's contentView
    CGFloat height = [self.dummyCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    height += 1.0f;
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CoffeeCard *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    CoffeeCardViewController *coffeeDetailViewController = [[CoffeeCardViewController alloc] init];
    coffeeDetailViewController.coffeeItem = object;
    
    [self.navigationController pushViewController:coffeeDetailViewController animated:YES];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CoffeeCard" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}
/*
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(CoffeeListTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}*/


 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }



@end
