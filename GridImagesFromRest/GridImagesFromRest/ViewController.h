//
//  ViewController.h
//  GridImagesFromRest
//
//  Created by Ricardo Gonzales on 2/28/15.
//  Copyright (c) 2015 Ricardo Gonzales. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *wrickCollectionView;
@property (strong, nonatomic) NSMutableArray *menuItems;

@property (nonatomic) CGPoint lastOffset;

@end

