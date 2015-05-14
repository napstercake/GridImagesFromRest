//
//  ViewController.m
//  GridImagesFromRest
//
//  Created by Ricardo Gonzales on 2/28/15.
//  Copyright (c) 2015 Ricardo Gonzales. All rights reserved.
//

#import "ViewController.h"
#import "TweetsViewController.h"

@interface ViewController ()

    @property (strong, nonatomic) NSURLSession *session;
    @property (strong, nonatomic) NSURLSessionConfiguration *sessionConfiguration;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //[UIColor colorWithRed:1 green:0.4431372549 blue:0.4431372549 alpha:1.0];
    //[UIColor colorWithRed:100 green:44.3 blue:44.3 alpha:1.0];
    //[UIColor colorWithHexString:textColorHex];
    
    //UIColor *mycolor = [UIColor pxColorWithHexValue:@"#BADA55"];
    
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:100 green:44.3 blue:44.3 alpha:1.0];
    
    /*
     Hi, you can't use hex code, you should use RGB, 
     in photoshop you can check the correct rgb data of this hex code. 
     and you can use this code for the 
     BarTintColor: for blackcolor this RGB 0 0 0: 
        [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0]; 
        Your hex code #FF7171 =  [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
     :) you should use rgb everywhere instead of hex in objective-c﻿
     */
    
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:1 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    

    //self.lastOffset = CGPointMake(0.5, 0.5);
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.menuItems = [[NSMutableArray alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://mejorandoios.herokuapp.com/api/courses/all"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration];
    
    NSURLSessionDataTask *task = [ self.session dataTaskWithRequest:request
                                                  completionHandler:^(NSData *data,
                                                                      NSURLResponse *response,
                                                                      NSError *error) {
                                                      
                                                      // Data
                                                      // Response: La data que devuelve.
                                                      // Error: Si existe algun error, lo lanza.
                                                  
                                                      NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *) response;
                                                      
                                                      // Check is the status is success (200)
                                                      if (urlResponse.statusCode == 200) {
                                                          
                                                          NSLog(@"It's working....");
                                                          [self handleResult:data];
                                                          
                                                      } else {
                                                          NSLog(@"Something is wrong here, cuz %@", error.description);
                                                      }
                                                      
                                                      
        
                                                  } ];
    
    [task resume];
    
}

-(void)handleResult:(NSData *)data {
    
    NSError *jsonError;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&jsonError];
    
    if (response) {
        
        //NSLog(@"%@", response);
        
        for (NSDictionary *dataDictionary in response[@"data"]) {
            [self.menuItems addObject:dataDictionary];
        }
    }
    
    //NSLog(@"Es tiempo de hacer reload en la tabla");
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.wrickCollectionView reloadData];
    });
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.menuItems count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *) [cell viewWithTag:10];
    
    // TODO LIST
    // Si self.menuItems tiene elementos, entonces hay que obtener la image_url del hash
    // Como accedemos a datos de un hash?
    // Tenemos que usar un NSDictionary
    // Ahora que ya tenemos el hash en un cellDictionarly
    // TEnemos que obtener la llave image_url, imageUrlString tendrá la url
    // Después tendremos que descargar esa imágen y lo haremos con un NSURLRequest
    // Y ese request se iniciará con un NSURLSessionDataTask
    // Obtén los dátos asincronamente.
    // Sí todo sale bien, setea el imageView.image
    //No olvides iniciar la tarea!!!
    
    
    // Check if the menu items is not empty
    if ( [self.menuItems count] > 0 ) {
        
        NSDictionary *cellDictionary = [self.menuItems objectAtIndex:indexPath.row];
        NSString *imageURLString = [cellDictionary objectForKey:@"image_url"];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        NSURLRequest *imageURLRequest = [NSURLRequest requestWithURL:imageURL];
        
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:imageURLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
            
            if ( urlResponse.statusCode == 200 ) {
                
                // Use the async method.
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = [UIImage imageWithData:data];
                });
                
            } else {
                NSLog(@"Algo malo paso por aqui.");
            }
            
        }];
        
        [task resume];
        
    }
    
    return cell;
    
}

/* When user clicks on any cell */
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *menuItemDictionary = [self.menuItems objectAtIndex:indexPath.row];
   // NSLog(@"Menu item dictionary: %@", menuItemDictionary);
    
    TweetsViewController *tweetViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tweetView"];
    
    tweetViewController.hashTag = [menuItemDictionary objectForKey:@"hashtag"];
    
    [self.navigationController pushViewController:tweetViewController animated:YES];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    NSLog(@"A: %f", self.wrickCollectionView.contentOffset.y);
    NSLog(@"B: %f", self.lastOffset.y);
    
    if ( self.wrickCollectionView.contentOffset.y < self.lastOffset.y ) {
        
        NSLog(@"Hidden bar!");
        //[self.navigationController setNavigationBarHidden:YES animated:YES];
        
    } else {
        NSLog(@"SHOW bar!");
        //[self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.lastOffset = self.wrickCollectionView.contentOffset;
}


@end





