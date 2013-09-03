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

@synthesize localStorage;

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
    }
    
    NSString *prefix = @"Saving to ";
    if (self.localStorage) {
        [self.storageWarning setText:[prefix stringByAppendingString:@"Local Storage"]];
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
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
