//
//  TweetsViewController.h
//  GridImagesFromRest
//
//  Created by Ricardo Gonzales on 3/1/15.
//  Copyright (c) 2015 Ricardo Gonzales. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TweetsViewController : UITableViewController

// Me quede en el minuto 28

@property (nonatomic, strong) NSString *hashTag;

@property (nonatomic, strong) NSMutableArray* results;
@property (nonatomic, strong) ACAccountStore* accountStore;
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, strong) NSMutableData* requestData;
@property (nonatomic, strong) NSURL* apiURL;

@end
