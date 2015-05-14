//
//  TweetsViewController.m
//  GridImagesFromRest
//
//  Created by Ricardo Gonzales on 3/1/15.
//  Copyright (c) 2015 Ricardo Gonzales. All rights reserved.
//

#import "TweetsViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TweetsViewController ()

@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong) NSURLSession *session;


@end

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Hash> %@", self.hashTag);
    
    self.apiURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/"];
    self.accountStore = [[ACAccountStore alloc] init];
    
    if ( ![self userHasAccessToTwitter] ) {
        
        NSLog(@"No twitter, agrega un alert aquí y notifica al usuario");
        
    } else {
        
        NSLog(@"Tenemos twitter");
        
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
            
            // Definimos un diccionario
            NSDictionary *params = @{@"q": self.hashTag};
            
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodGET
                                                              URL:[self.apiURL URLByAppendingPathComponent:@"search/tweets.json"]
                                                       parameters:params];
            
            NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
            request.account = twitterAccounts.lastObject;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.connection = [[NSURLConnection alloc] initWithRequest:[request preparedURLRequest] delegate:self];
                
                //Cerramos el request.
                // Indica al usuario que algo esta pasando, se esta cargando (networkActivityIndicadorVisible)
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            });
            
        }];
    }
    
}

-(BOOL)userHasAccessToTwitter {
    
    //Preguntar bien que es esto.
    // Bueno esto esta en la documentacion de twitter.
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



 /* Connection methods */

// Conexion
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    self.requestData = [NSMutableData data];
}

// Conexión
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [[self requestData] appendData:data];
}

// Finalizó la carga
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (self.requestData) {
        
        NSError *jsonError;
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:self.requestData options:NSJSONReadingAllowFragments error:&jsonError];
        
        self.results = dictionary[@"statuses"];
        
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.requestData = nil;
    [self.refreshControl endRefreshing];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

// Error en la carga o conexión
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.connection = nil;
    self.requestData = nil;
    [self.refreshControl endRefreshing];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];

    });
    
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.results count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"celltweet" forIndexPath:indexPath];
    
    NSDictionary *tweet = (self.results)[indexPath.row];
    
    UILabel* label = (UILabel*)[cell viewWithTag:1];
    label.text = [NSString stringWithFormat:@"@%@", tweet[@"user"][@"screen_name"]];
    
    UILabel* tweetLabel = (UILabel*)[cell viewWithTag:2];
    tweetLabel.text = tweet[@"text"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSURL *profileImageURL = [NSURL URLWithString:(tweet[@"user"])[@"profile_image_url"] ];
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profileImageURL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:3];
            imageView.image = image;
            
        });
        
        
    });

    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
