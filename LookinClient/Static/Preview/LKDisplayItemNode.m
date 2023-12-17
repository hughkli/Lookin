//
//  LKDisplayItemNode.m
//  Lookin
//
//  Created by Li Kai on 2019/8/17.
//  https://lookin.work
//

#import "LKDisplayItemNode.h"
#import "LookinDisplayItem.h"
#import "LKPreferenceManager.h"
#import "LKHierarchyDataSource.h"

@interface LKDisplayItemNode () <LookinDisplayItemDelegate>

@property(nonatomic, strong) LKHierarchyDataSource *dataSource;

@property(nonatomic, strong) SCNNode *contentNode;
@property(nonatomic, strong) SCNPlane *contentPlane;

@property(nonatomic, strong) SCNGeometry *borderGeometry;
@property(nonatomic, strong) SCNNode *borderNode;
@property(nonatomic, strong) NSColor *borderColor;

@property(nonatomic, strong) SCNNode *maskNode;
@property(nonatomic, strong) SCNPlane *maskPlane;

@end

@implementation LKDisplayItemNode

- (instancetype)initWithDataSource:(LKHierarchyDataSource *)dataSource {
    NSLog(@"LKDisplayItemNode - init");
    
    if (self = [super init]) {
        self.dataSource = dataSource;
        
        self.contentPlane = [SCNPlane geometry];
        self.contentPlane.firstMaterial.doubleSided = YES;
        self.contentPlane.firstMaterial.lightingModelName = SCNLightingModelConstant;
        self.contentNode = [SCNNode nodeWithGeometry:self.contentPlane];
        self.contentPlane.firstMaterial.diffuse.contents = [NSColor clearColor];
        self.contentNode.position = SCNVector3Make(0, 0, 0);
        self.contentNode.name = @"screenshot";
        self.contentNode.categoryBitMask = LookinPreviewBitMask_NoLight;
        [self addChildNode:self.contentNode];
        
        // 注意这里并没有 add maskNode，需要的时候再 add
        self.maskPlane = [SCNPlane geometry];
        self.maskPlane.firstMaterial.doubleSided = YES;
        self.maskNode = [SCNNode nodeWithGeometry:self.maskPlane];
        self.maskNode.name = @"mask";
        self.maskNode.position = SCNVector3Make(0, 0, .001);
        self.maskNode.categoryBitMask = LookinPreviewBitMask_HasLight;
        
        self.borderNode = [SCNNode node];
        self.borderNode.name = @"border";
        self.borderNode.position = SCNVector3Make(0, 0, .002);
        self.borderNode.categoryBitMask = LookinPreviewBitMask_NoLight;
        [self addChildNode:self.borderNode];
    }
    return self;
}

- (void)setPreferenceManager:(LKPreferenceManager *)preferenceManager {
    _preferenceManager = preferenceManager;
    [preferenceManager.showHiddenItems subscribe:self action:@selector(_renderVisibility) relatedObject:nil];
    [preferenceManager.showOutline subscribe:self action:@selector(_renderImageAndColor) relatedObject:nil];
    [preferenceManager.isQuickSelecting subscribe:self action:@selector(_renderVisibility) relatedObject:nil];
}

- (void)setIsDarkMode:(BOOL)isDarkMode {
    _isDarkMode = isDarkMode;
    [self _renderImageAndColor];
}

- (void)setDisplayItem:(LookinDisplayItem *)displayItem {
    _displayItem = displayItem;
    
    /// 不能把 contents 设置成 nil，否则某些场景下会发生内容渲染错乱的情况
    self.contentPlane.firstMaterial.diffuse.contents = displayItem.backgroundColor ? : [NSColor clearColor];
    
    /// 这一句会使得 displayItem:propertyDidChange: 被立即调用，参数是 LookinDisplayItemProperty_None
    displayItem.previewItemDelegate = self;
    
//    self.name = [NSString stringWithFormat:@"DisplayItem(%@)", displayItem.title];
}

- (void)setBorderColor:(NSColor *)borderColor {
    _borderColor = borderColor;
    [self _renderborderColor];
}

- (void)setIndex:(NSUInteger)index {
    _index = index;
    self.contentNode.renderingOrder = index * 10;
    self.maskNode.renderingOrder = index * 10 + 1;
    self.borderNode.renderingOrder = index * 10 + 2;
}

- (void)_renderborderColor {
    self.borderGeometry.firstMaterial.diffuse.contents = self.borderColor;
}

- (SCNGeometry *)_makeBorderGeometryWithPlaneNode:(SCNNode *)planeNode {
    SCNVector3 max,min;
    [planeNode getBoundingBoxMin:&min max:&max];
    CGFloat xx = max.x - min.x;
    CGFloat yy = max.y - min.y;
    SCNVector3 vec[] = {
        max,
        SCNVector3Make(max.x, max.y - yy, max.z),
        SCNVector3Make(max.x - xx, max.y - yy, max.z),
        SCNVector3Make(max.x - xx, max.y, max.z),
    };
    GLubyte indexs[] = {0, 1, 1, 2, 2, 3, 3, 0};
    SCNGeometrySource *vecSource = [SCNGeometrySource geometrySourceWithVertices:vec count:4];
    NSData * indexData = [NSData dataWithBytes:indexs length:8];
    SCNGeometryElement *indexElement = [SCNGeometryElement geometryElementWithData:indexData primitiveType:SCNGeometryPrimitiveTypeLine primitiveCount:4 bytesPerIndex:sizeof(GLubyte)];
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[vecSource] elements:@[indexElement]];
    geometry.firstMaterial.doubleSided = YES;
    geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    return geometry;
}

- (void)_renderVisibility {
    BOOL displayingInHierarchy = self.displayItem.displayingInHierarchy;
    BOOL inHiddenHierarchy = self.displayItem.inHiddenHierarchy;
    BOOL showEvenWhenCollapsed = self.preferenceManager.isQuickSelecting.currentBOOLValue && !self.displayItem.superItem.preferToBeCollapsed;
    BOOL showHiddenItems = self.preferenceManager.showHiddenItems.currentBOOLValue;
    
    [SCNTransaction begin];
    
    BOOL canSelect;
    if (inHiddenHierarchy && !showHiddenItems) {
        self.contentNode.opacity = 0;
        self.borderNode.opacity = 0;
        self.maskNode.hidden = YES;
        canSelect = NO;
        
    } else if (displayingInHierarchy) {
        self.contentNode.opacity = 1;
        self.borderNode.opacity = 1;
        self.maskNode.hidden = NO;
        canSelect = YES;
        
    } else {
        self.contentNode.opacity = 0;
        self.maskNode.hidden = YES;
        if (showEvenWhenCollapsed) {
            self.borderNode.opacity = 1;
            canSelect = YES;
        } else {
            self.borderNode.opacity = 0;
            canSelect = NO;
        }
    }
    
    if (canSelect) {
        self.contentNode.categoryBitMask = LookinPreviewBitMask_Selectable|LookinPreviewBitMask_NoLight;
    } else {
        self.contentNode.categoryBitMask = LookinPreviewBitMask_Unselectable|LookinPreviewBitMask_NoLight;
    }
    
    [SCNTransaction commit];
}

- (void)_renderImageAndColor {
    BOOL isSelected = (self.dataSource.selectedItem == self.displayItem);
    BOOL isHovered = (self.dataSource.hoveredItem == self.displayItem);
    
    LookinImage *appropriateScreenshot = self.displayItem.appropriateScreenshot;
    NSAssert(MAX(appropriateScreenshot.representations.firstObject.pixelsWide, appropriateScreenshot.representations.firstObject.pixelsHigh) <= LookinNodeImageMaxLengthInPx , @"image is too large");
    self.contentPlane.firstMaterial.diffuse.contents = appropriateScreenshot;
    
    BOOL tooLargeToFetchScreenshot = !appropriateScreenshot && self.displayItem.doNotFetchScreenshotReason == LookinDoNotFetchScreenshotForTooLarge;
    
    // 更新 border 颜色
    if (isSelected || isHovered) {
        if (tooLargeToFetchScreenshot) {
            self.borderColor = LookinColorRGBAMake(255, 38, 0, .8);
        } else {
            self.borderColor = LookinColorMake(100, 146, 199);
        }
    } else if (self.preferenceManager.showOutline.currentBOOLValue) {
        if (tooLargeToFetchScreenshot) {
            self.borderColor = self.isDarkMode ? LookinColorRGBAMake(255, 38, 0, .5) : LookinColorRGBAMake(255, 38, 0, .6);
        } else {
            self.borderColor = self.isDarkMode ? LookinColorRGBAMake(160, 168, 189, .6) : LookinColorRGBAMake(120, 122, 124, .6);
        }
    } else {
        self.borderColor = [NSColor clearColor];
    }
    
    // 更新 mask 颜色
    NSColor *maskColor = nil;
    CGFloat maskOpacity = 0;
    if (tooLargeToFetchScreenshot) {
        maskColor = LookinColorMake(255, 38, 0);
        if (isSelected) {
            maskOpacity = .45;
        } else if (isHovered) {
            maskOpacity = .3;
        } else {
            maskOpacity = self.isDarkMode ? .17 : .2;
        }
    } else {
        maskColor = LookinColorMake(110, 183, 255);
        if (isSelected) {
            maskOpacity = .35;
        } else if (isHovered) {
            maskOpacity = .18;
        } else {
            maskOpacity = 0;
        }
    }
    if (maskOpacity > 0 && !self.maskNode.parentNode) {
        [self insertChildNode:self.maskNode atIndex:1];
    }
    self.maskNode.opacity = maskOpacity;
    self.maskPlane.firstMaterial.diffuse.contents = maskColor;
}

#pragma mark - <LookinDisplayItemDelegate>

- (void)displayItem:(LookinDisplayItem *)displayItem propertyDidChange:(LookinDisplayItemProperty)property {
    NSLog(@"LKDisplayItemNode - %@ did Change", @(property));
    
    if (property == LookinDisplayItemProperty_None || property == LookinDisplayItemProperty_FrameToRoot) {
        CGRect frameToRoot = [displayItem calculateFrameToRoot];
        
        CGFloat originX = frameToRoot.origin.x;
        CGFloat originY = frameToRoot.origin.y;
        CGFloat width = frameToRoot.size.width;
        CGFloat height = frameToRoot.size.height;
        CGFloat xOffSet = -self.screenSize.width / 2;
        CGFloat yOffSet = self.screenSize.height / 2;
        CGFloat transformedX = (originX + width / 2 + xOffSet) ;
        CGFloat transformedY = (-(originY + height / 2) + yOffSet);
        
        CGFloat factor = 0.01;
        
        self.contentPlane.width = width * factor;
        self.contentPlane.height = height * factor;
        
        self.maskPlane.width = self.contentPlane.width;
        self.maskPlane.height = self.contentPlane.height;
        
        SCNVector3 position = self.position;
        position.x = transformedX * factor;
        position.y = transformedY * factor;
        self.position = position;
        
        self.borderGeometry = [self _makeBorderGeometryWithPlaneNode:self.contentNode];
        self.borderNode.geometry = self.borderGeometry;
        [self _renderborderColor];
    }
    
    if (property == LookinDisplayItemProperty_None ||
        property == LookinDisplayItemProperty_IsExpandable ||
        property == LookinDisplayItemProperty_IsExpanded ||
        property == LookinDisplayItemProperty_SoloScreenshot ||
        property == LookinDisplayItemProperty_GroupScreenshot ||
        property == LookinDisplayItemProperty_IsSelected ||
        property == LookinDisplayItemProperty_IsHovered ||
        property == LookinDisplayItemProperty_AvoidSyncScreenshot) {
        [self _renderImageAndColor];
    }
    
    if (property == LookinDisplayItemProperty_None || property == LookinDisplayItemProperty_DisplayingInHierarchy || property == LookinDisplayItemProperty_InHiddenHierarchy) {
        [self _renderVisibility];
    }
}

@end
