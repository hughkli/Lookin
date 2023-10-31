//
//  LookinAttributesGroup+LookinClient.m
//  LookinClient
//
//  Created by LikaiMacStudioWork on 2023/10/31.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import "LookinAttributesGroup+LookinClient.h"
#import "LookinDashboardBlueprint.h"

@implementation LookinAttributesGroup (LookinClient)

- (NSString *)queryDisplayTitle {
    if (self.userCustomTitle.length > 0) {
        return self.userCustomTitle;
    } else {
        return [LookinDashboardBlueprint groupTitleWithGroupID:self.identifier];
    }
}

@end
