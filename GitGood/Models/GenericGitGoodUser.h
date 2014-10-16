//
//  GenericGitGoodUser.h
//  GitGood
//
//  Created by Stephen Meriwether on 10/16/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericGitGoodUser : NSObject

// get the github username & password
- (NSString *)username;
- (void)setUsername:(NSString*)username;

@end
