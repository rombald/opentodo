//
//  OpenTodoTrelloAuthViewController.m
//  opentodo
//
//  Created by Frank Münchmeyer on 17.09.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import "OpenTodoTrelloAuthViewController.h"

@interface OpenTodoTrelloAuthViewController ()

@end

@implementation OpenTodoTrelloAuthViewController
@synthesize webView;
@synthesize spinnerBackground;
@synthesize spinner;

@synthesize trelloToken;

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

    webView.delegate = self;
    
    NSURL *url = [NSURL URLWithString:@"https://trello.com/1/authorize?key=9305fdfeca9d8484d1674a628e368137&expiration=never&name=OpenTodo&response_type=token&scope=read,write"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)web_view
{
    [spinnerBackground setHidden:NO];
    [spinner setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)web_view
{
    [spinnerBackground setHidden:YES];
    [spinner setHidden:YES];

    NSString *htmlBody = [web_view stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    self.trelloToken = [[htmlBody substringWithRange:NSMakeRange(133, 65)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *appKey = @"9305fdfeca9d8484d1674a628e368137";
    NSString *trelloTest = [NSString stringWithFormat:@"https://trello.com/1/members/my/boards?key=%@&token=%@", appKey, self.trelloToken];
    
    NSURL *trelloTestUrl = [NSURL URLWithString:trelloTest];
    NSURLRequest *request = [NSURLRequest requestWithURL:trelloTestUrl];
    
    NSURLResponse *response;
    NSError *error;
    //send it synchronous
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

    if (!error) {
        [self performSegueWithIdentifier:@"selectTrelloPrefs" sender:self];
    } else {
        NSLog(@"Error: %@", error);
        NSLog(@"Response from server = %@", responseString);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
