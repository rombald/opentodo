//
//  OpenToDoDetailViewController.m
//  opentodo
//
//  Created by Frank Münchmeyer on 27.08.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import "OpenToDoDetailViewController.h"

@interface OpenToDoDetailViewController ()

@end

@implementation OpenToDoDetailViewController
@synthesize todo;
@synthesize trelloCard;

@synthesize localStorage;
@synthesize iCloudStorage;
@synthesize trelloStorage;

@synthesize trelloAppKey;
@synthesize trelloToken;
@synthesize trelloList;

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (self.todo) {
        [self.titleTextField setText:[self.todo valueForKey:@"title"]];
        [self.descriptionTextView setText:[self.todo valueForKey:@"desc"]];
        [self.labelTextField setText:[self.todo valueForKey:@"label"]];
        [self.dueTime setDate:[self.todo valueForKey:@"due_time"]];
    } else if (self.trelloCard) {
        [self.titleTextField setText:[self.trelloCard valueForKey:@"name"]];
        [self.descriptionTextView setText:[self.trelloCard valueForKey:@"desc"]];
        
        NSArray *labelArray = [self.trelloCard valueForKey:@"labels"];
        if (labelArray.count > 0) {
            [self.labelTextField setText:[labelArray.firstObject valueForKey:@"name"]];
        }

        if ([self.trelloCard valueForKey:@"due"] != (id)[NSNull null]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"];
            NSDate *dueTime = [dateFormatter dateFromString:[self.trelloCard valueForKey:@"due"]];

            [self.dueTime setDate:dueTime];
        }
    }
    
    NSString *prefix = @"Saving to ";
    if (self.localStorage) {
        [self.storageWarning setText:[prefix stringByAppendingString:@"Local Storage"]];
    } else if (self.iCloudStorage) {
        [self.storageWarning setText:[prefix stringByAppendingString:@"iCloud Storage"]];
    } else if (self.trelloStorage) {
        [self.storageWarning setText:[prefix stringByAppendingString:@"Trello Storage"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    if (self.localStorage) {
        NSManagedObjectContext *context = [self managedObjectContext];
        
        if (self.todo) {
            [self.todo setValue:self.titleTextField.text forKey:@"title"];
            [self.todo setValue:self.descriptionTextView.text forKey:@"desc"];
            [self.todo setValue:self.labelTextField.text forKey:@"label"];
            [self.todo setValue:self.dueTime.date forKey:@"due_time"];
        } else {
            NSManagedObjectModel *newToDo = [NSEntityDescription insertNewObjectForEntityForName:@"ToDo" inManagedObjectContext:context];
            [newToDo setValue:self.titleTextField.text forKey:@"title"];
            [newToDo setValue:self.descriptionTextView.text forKey:@"desc"];
            [newToDo setValue:self.labelTextField.text forKey:@"label"];
            [newToDo setValue:self.dueTime.date forKey:@"due_time"];
        }
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    } else if (self.iCloudStorage) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *stringDueTime = [dateFormatter stringFromDate:self.dueTime.date];

        NSDictionary *newTodo = [NSDictionary dictionaryWithObject:[
                                                                    NSDictionary dictionaryWithObjectsAndKeys:
                                                                    self.titleTextField.text, @"title",
                                                                    self.descriptionTextView.text, @"desc",
                                                                    self.labelTextField.text, @"label",
                                                                    stringDueTime, @"due_time",
                                                                    nil
                                                                    ]
                                                            forKey:@"ToDo"];

        NSString *jsonNewTodo = [[NSString alloc] initWithData:
                                 [NSJSONSerialization dataWithJSONObject:newTodo options:0 error:nil]
                                                      encoding:NSUTF8StringEncoding];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"New ToDo" object:self userInfo:[NSDictionary dictionaryWithObject:jsonNewTodo forKey:@"ToDo"]];
    } else if (self.trelloStorage) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"];
        NSString *stringDueTime = [dateFormatter stringFromDate:self.dueTime.date];
        
        NSString *saveTrelloCardUrl;
        NSMutableURLRequest *request;

        if (self.trelloCard) {
            saveTrelloCardUrl = [NSString stringWithFormat:@"https://trello.com/1/cards/%@?key=%@&token=%@&name=%@&desc=%@&labels=%@&due=%@",
                                 [self.trelloCard valueForKey:@"id"],
                                 self.trelloAppKey,
                                 self.trelloToken,
                                 [self.titleTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                 [self.descriptionTextView.text stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                 [self.labelTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                 stringDueTime];

            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:saveTrelloCardUrl]];
            [request setHTTPMethod:@"PUT"];
        } else {
            saveTrelloCardUrl = [NSString stringWithFormat:@"https://trello.com/1/cards/?key=%@&token=%@&name=%@&desc=%@&labels=%@&due=%@&idList=%@",
                                 self.trelloAppKey,
                                 self.trelloToken,
                                 [self.titleTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                 [self.descriptionTextView.text stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                 [self.labelTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"],
                                 stringDueTime,
                                 [self.trelloList valueForKey:@"id"]];

            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:saveTrelloCardUrl]];
            [request setHTTPMethod:@"POST"];
        }
        
        NSURLResponse *response;
        NSError *error;

        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        if (!error) {
            NSLog(@"Error: %@ | response: %@ | URL: %@", error, responseString, saveTrelloCardUrl);
        } else {
            NSLog(@"Error: %@ | response: %@ | URL: %@", error, responseString, saveTrelloCardUrl);
        }
    }
    
    [self.descriptionTextView resignFirstResponder];
    
    // Get the current date
    NSDate *pickerDate = [self.dueTime date];
    
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = pickerDate;
    localNotification.alertBody = self.titleTextField.text;
    localNotification.alertAction = @"Show me the item";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    // Dismiss the view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
