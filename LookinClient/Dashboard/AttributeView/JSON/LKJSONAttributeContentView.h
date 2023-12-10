//
//  LKJSONAttributeContentView.h
//  LookinClient
//
//  Created by likai.123 on 2023/12/10.
//  Copyright © 2023 hughkli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKJSONAttributeContentView : LKBaseView

- (instancetype)initWithBigFont:(BOOL)bigFont;

- (void)renderWithJSON:(NSString *)json;

@end
