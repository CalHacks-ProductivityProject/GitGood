//
//  GenericGitGoodUser.m
//  GitGood
//
//  Created by Stephen Meriwether on 10/16/14.
//  Copyright (c) 2014 CalHacksProductivity. All rights reserved.
//

#import "GenericGitGoodUser.h"

@interface GenericGitGoodUser()

// Github Information
@property (nonatomic, copy) NSString *githubUsername;

@end

@implementation GenericGitGoodUser


#pragma mark - Getter Methods

- (NSString *)username
{
    return self.githubUsername;
}

- (void)setUsername:(NSString*)username
{
    _githubUsername = username;
}


@end
