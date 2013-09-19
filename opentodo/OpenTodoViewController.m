//
//  OpenTodoViewController.m
//  opentodo
//
//  Created by Frank Münchmeyer on 27.08.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import "OpenTodoViewController.h"
#import "OpenToDoDetailViewController.h"

@interface OpenTodoViewController ()
@property (strong) NSMutableArray *todos;

@end

@implementation OpenTodoViewController
@synthesize localStorage;
@synthesize iCloudStorage;
@synthesize trelloStorage;

@synthesize trelloBoard;
@synthesize trelloList;
@synthesize trelloAppKey;
@synthesize trelloToken;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OpenToDoDetailViewController *destViewController = segue.destinationViewController;

    if ([[segue identifier] isEqualToString:@"UpdateToDo"] && !self.iCloudStorage) {
        NSManagedObject *selectedToDo = [self.todos objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        destViewController.todo = selectedToDo;
    } else if ([[segue identifier] isEqualToString:@"UpdateToDo"] && self.iCloudStorage) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                          message:@"It's not possible to edit an iCloud Todo!"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
    
    destViewController.localStorage = self.localStorage;
    destViewController.iCloudStorage = self.iCloudStorage;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.localStorage) {
        NSManagedObjectContext *context = [self managedObjectContext];
        
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Delete object from database
            [context deleteObject:[self.todos objectAtIndex:indexPath.row]];
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                return;
            }
            
            // Remove device from table view
            [self.todos removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (self.iCloudStorage) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:@"ICLOUD_TODOS"];
            self.todos = self.iCloudToDos;
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.localStorage) {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ToDo"];
        self.todos = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
        [self.tableView reloadData];
    } else if (self.iCloudStorage) {
        //  Observer to catch changes from iCloud
        NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(storeDidChange:)
                                                     name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                   object:store];
        
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        
        // Observer to catch the local changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didAddNewToDo:)
                                                     name:@"New ToDo"
                                                   object:nil];
        self.todos = self.iCloudToDos;
    }

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.todos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (self.localStorage) {
        NSManagedObject *todo = [self.todos objectAtIndex:indexPath.row];

        UILabel *title = (UILabel *)[cell viewWithTag:1];
        title.text = [NSString stringWithFormat:@"%@", [todo valueForKey:@"title"]];
        
        UILabel *label = (UILabel *)[cell viewWithTag:2];
        label.text = [NSString stringWithFormat:@"%@", [todo valueForKey:@"label"]];
    } else if (self.iCloudStorage) {
        NSMutableArray *todo = [self.todos valueForKey:@"ToDo"];

        UILabel *title = (UILabel *)[cell viewWithTag:1];
        title.text = [NSString stringWithFormat:@"%@", [todo valueForKey:@"title"]];
        
        UILabel *label = (UILabel *)[cell viewWithTag:2];
        label.text = [NSString stringWithFormat:@"%@", [todo valueForKey:@"label"]];
    }
    
    return cell;
}

- (NSArray *)iCloudToDos
{
    if (_iCloudToDos) {
        //return _iCloudToDos;
    }

    _iCloudToDos = [[[NSUbiquitousKeyValueStore defaultStore] arrayForKey:@"ICLOUD_TODOS"] mutableCopy];
    if (_iCloudToDos) {
        NSString* todoString = _iCloudToDos.firstObject;
        NSData* todoData = [todoString dataUsingEncoding:NSUTF8StringEncoding];
        _iCloudToDos = [NSJSONSerialization JSONObjectWithData:todoData options:NSJSONReadingMutableLeaves error:nil];
    }

    if (!_iCloudToDos) {
        _iCloudToDos = [NSMutableArray array];
    }

    return _iCloudToDos;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (self.localStorage) {
        self.navigationItem.title = @"Local Storage";
    } else if (self.iCloudStorage) {
        self.navigationItem.title = @"iCloud Storage";
        //self.navigationItem.leftBarButtonItem = self.editButtonItem;
        
        //  Observer to catch changes from iCloud
        NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(storeDidChange:)
                                                     name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                                   object:store];
        
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        
        // Observer to catch the local changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didAddNewToDo:)
                                                     name:@"New ToDo"
                                                   object:nil];

        self.todos = self.iCloudToDos;
    } else if (self.trelloStorage) {
        self.navigationItem.title = @"Trello Storage";
        
        NSLog(@"Token: %@ | AppKey: %@ | Board: %@ | List: %@", self.trelloToken, self.trelloAppKey, self.trelloBoard, self.trelloList);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Observer New ToDo

- (void)didAddNewToDo:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString *noteStr = [userInfo valueForKey:@"ToDo"];
    [self.iCloudToDos addObject:noteStr];
    
    // Update data on the iCloud
    [[NSUbiquitousKeyValueStore defaultStore] setArray:self.iCloudToDos forKey:@"ICLOUD_TODOS"];
    
    // Reload the table view to show changes
    [self.tableView reloadData];
}

#pragma mark - Observer

- (void)storeDidChange:(NSNotification *)notification
{
    // Retrieve the changes from iCloud
    _iCloudToDos = [[[NSUbiquitousKeyValueStore defaultStore] arrayForKey:@"ICLOUD_TODOS"] mutableCopy];
    
    // Reload the table view to show changes
    [self.tableView reloadData];
}
@end
