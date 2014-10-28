//
//  NoFooterGroupSpecifier.m
//  UntetheredHeySiri
//
//  Created by Hamza Sood on 28/10/2014.
//  Copyright (c) 2014 Hamza Sood. All rights reserved.
//

#import "NoFooterGroupSpecifier.h"

@implementation NoFooterGroupSpecifier

- (void)setProperty:(id)property forKey:(id<NSCopying>)key {
    if (key == PSFooterTextGroupKey) {
        [self removePropertyForKey:PSFooterTextGroupKey];
        return;
    }
    [super setProperty:property forKey:key];
}

@end
