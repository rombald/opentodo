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

@synthesize trelloList;
@synthesize trelloAppKey;
@synthesize trelloToken;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (self.localStorage) {
        self.navigationItem.title = @"Local Storage";
    } else if (self.iCloudStorage) {
        self.navigationItem.title = @"iCloud Storage";
        
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
        
        [self fetchTrelloToDos];
    }
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
    } else if (self.trelloStorage) {
        [self fetchTrelloToDos];
        [self.tableView reloadData];
    }
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OpenToDoDetailViewController *destViewController = segue.destinationViewController;

    if (self.trelloStorage) {
        destViewController.trelloAppKey = self.trelloAppKey;
        destViewController.trelloToken = self.trelloToken;
        destViewController.trelloList = self.trelloList;
    }
    
    if ([[segue identifier] isEqualToString:@"UpdateToDo"]) {
        if (self.iCloudStorage) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                              message:@"It's not possible to edit an iCloud Todo!"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
        } else if (self.localStorage) {
            NSManagedObject *selectedToDo = [self.todos objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
            destViewController.todo = selectedToDo;
        } else if (self.trelloStorage) {
            NSMutableArray *selectedToDo = [self.todos objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
            destViewController.trelloCard = selectedToDo;
        }
    }
    
    destViewController.localStorage = self.localStorage;
    destViewController.iCloudStorage = self.iCloudStorage;
    destViewController.trelloStorage = self.trelloStorage;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.localStorage) {
            NSManagedObjectContext *context = [self managedObjectContext];
            
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
        } else if (self.iCloudStorage) {
            [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:@"ICLOUD_TODOS"];
            self.todos = self.iCloudToDos;
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        } else if (self.trelloStorage) {
            NSMutableArray *toDeleteToDo = [self.todos objectAtIndex:indexPath.row];
            NSString *deleteTrelloCardUrl = [NSString stringWithFormat:@"https://trello.com/1/cards/%@?key=%@&token=%@", [toDeleteToDo valueForKey:@"id"], self.trelloAppKey, self.trelloToken];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:deleteTrelloCardUrl]];
            [request setHTTPMethod:@"DELETE"];
            NSURLResponse *response;
            NSError *error;
            
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            
            if (!error) {
                NSLog(@"Error: %@ | response: %@ | URL: %@", error, responseString, deleteTrelloCardUrl);
                
                [self fetchTrelloToDos];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                NSLog(@"Error: %@ | response: %@ | URL: %@", error, responseString, deleteTrelloCardUrl);
            }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.todos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (self.localStorage) {
        NSManagedObject *todo = [self.todos objectAtIndex:indexPath.row];

        UILabel *title = (UILabel *)[cell viewWithTag:1];
        title.text = [todo valueForKey:@"title"];
        
        UILabel *label = (UILabel *)[cell viewWithTag:2];
        label.text = [todo valueForKey:@"label"];
    } else if (self.iCloudStorage) {
        NSArray *todo = [self.todos valueForKey:@"ToDo"];

        UILabel *title = (UILabel *)[cell viewWithTag:1];
        title.text = [todo valueForKey:@"title"];
        
        UILabel *label = (UILabel *)[cell viewWithTag:2];
        label.text = [todo valueForKey:@"label"];
    } else if (self.trelloStorage) {
        NSArray *todo = [self.todos objectAtIndex:indexPath.row];
        
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        title.text = [todo valueForKey:@"name"];
        
        NSArray *trelloLabels = [todo valueForKey:@"labels"];
        
        UILabel *label = (UILabel *)[cell viewWithTag:2];

        if (trelloLabels.count > 1) {
            label.text = [trelloLabels.firstObject valueForKey:@"name"];
        }
    }
    
    return cell;
}

- (NSArray *)iCloudToDos
{
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


- (void)fetchTrelloToDos
{
    NSString *trelloCardUrl = [NSString stringWithFormat:@"https://trello.com/1/lists/%@?key=%@&token=%@&cards=all&card_fields=name,labels,desc,due",
                               [self.trelloList valueForKey:@"id"],
                               self.trelloAppKey,
                               self.trelloToken];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:trelloCardUrl]];
    NSURLResponse *response;
    NSError *error;

    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if (!error) {
        self.todos = [[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil] valueForKey:@"cards"];
    } else {
        NSLog(@"%@", error);
    }
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
