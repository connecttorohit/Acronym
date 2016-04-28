//
//  AppDelegate.h
//  Acronym
//
//  Created by Rohit Kumar on 4/20/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

/**
 This is a simple iPhone app created to look up meanings of Acronyms.
 
 App has two screens.
 
 1. Acronyms & Meanings screen:
 This has a textfield which accepts valid Acronyms.
 On entering the text and hit "search" key, webservice is made and corresponding meanings are shown in a table view.
 If no meanings are found / if any webservice errors, an alert is shown with appropriate message.
 
 2. Variations screen: This screen lists all possible variations for a meaning.
 Again a table view is used to show the content.
 
 
 Below URL is used to fetch the meanings:
 
 http://www.nactem.ac.uk/software/acromine/rest.html
 
 It's a GET request
 
 Below open source libraries are being used:
 
 1.  "AFNetworking" - For REST calls https://github.com/AFNetworking/AFNetworking
 
 2. "MBProgressHUD" - For displaying the HUD when task is happening in background thread  https://github.com/jdg/MBProgressHUD
 
 */

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

