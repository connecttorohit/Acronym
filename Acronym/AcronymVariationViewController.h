//
//  AcronymVariationViewController.h
//  Acronym
//
//  Created by Rohit Kumar on 4/28/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AcronymResult.h"

/**
 @class AcronymVariationViewController
 
 @details The AcronymVariationViewController class displays the variations of an acronym in table view.
 
 */

@interface AcronymVariationViewController : UIViewController

@property (nonatomic,strong) AcronymMeaning *meaning;

@end
