//
//  OpenToDoDetailViewController.h
//  opentodo
//
//  Created by Frank Münchmeyer on 27.08.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenToDoDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *storageWarning;
@property (weak, nonatomic) IBOutlet UITextField *labelTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *dueTime;


- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@property (strong) NSManagedObject *todo;
@property NSMutableArray *trelloCard;

@property BOOL localStorage;
@property BOOL iCloudStorage;

@end
