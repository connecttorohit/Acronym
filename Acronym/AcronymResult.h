//
//  AcronymResult.h
//  Acronym
//
//  Created by Rohit Kumar on 4/21/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AcronymResult : NSObject

@property (nonatomic,copy) NSString *shortForm;
@property (nonatomic,strong) NSMutableArray *meanings;

@end

@interface AcronymMeaning : NSObject

@property (nonatomic, copy) NSString *meaning;
@property (nonatomic, assign) NSInteger frequency;
@property (nonatomic, assign) NSInteger since;

@end
