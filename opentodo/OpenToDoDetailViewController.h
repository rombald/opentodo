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

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@property (strong) NSManagedObject *todo;

@property BOOL localStorage;

@end
