//
//  LKTipsView.h
//  Lookin
//
//  Created by Li Kai on 2019/5/8.
//  https://lookin.work
//

#import "LKBaseView.h"
#import "LookinAppInfo.h"

@interface LKTipsView : LKBaseView

@property(nonatomic, weak) id bindingObject;

@property(nonatomic, copy) NSString *title;

/// 请外部不要直接修改 button 的 text 等属性，而是要通过下面的 buttonText 和 buttonImage 来设置
@property(nonatomic, strong, readonly) NSButton *button;

/// buttonText 和 buttonImage 只有一个会生效，请勿同时设置
@property(nonatomic, copy) NSString *buttonText;
@property(nonatomic, strong) NSImage *buttonImage;

@property(nonatomic, strong) NSImage *image;

- (void)setImageByDeviceType:(LookinAppInfoDevice)type;

@property(nonatomic, weak) id target;

@property(nonatomic, assign) SEL clickAction;
@property(nonatomic, copy) void (^didClick)(LKTipsView *tipsView);

-(void)setInternalInsetsRight:(CGFloat)value;

@end

@interface LKRedTipsView : LKTipsView

- (void)startAnimation;
- (void)endAnimation;

@end
