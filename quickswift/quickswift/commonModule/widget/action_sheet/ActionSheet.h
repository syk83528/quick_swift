//  Created by Wildog on 7/25/18.
//  Copyright © 2018 Xiu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, ActionSheetOption) {
    ActionSheetOptionDimBackground = 1 << 0, // 背景变暗
    ActionSheetOptionShowCancelButton = 1 << 1, // 显示取消按钮
};

@interface ActionSheetItem : NSObject

@property (nonatomic, nullable, copy) void (^action)(ActionSheetItem * _Nonnull); // 事件
@property (nonatomic, nullable, strong) UIColor *backgroundColor; // 背景色，默认为 white
@property (nonatomic, assign) BOOL dismissAfterSelection; // 点击后隐藏 sheet，默认为 YES
@property (nonatomic, assign) BOOL userInteractionEnabled; // 禁止点击，默认为 NO

@property (nonatomic, nullable, copy) NSString *title; // 标题
@property (nonatomic, nullable, strong) UIFont *titleFont; // 标题字体
@property (nonatomic, nullable, strong) UIColor *titleColor; // 标题颜色
@property (nonatomic, nullable, copy) NSAttributedString *attributedTitle; // 富文本标题

@property (nonatomic, nullable, copy) NSString *subtitle; // 副标题
@property (nonatomic, nullable, strong) UIFont *subtitleFont; // 副标题字体
@property (nonatomic, nullable, strong) UIColor *subtitleColor; // 副标题颜色
@property (nonatomic, nullable, copy) NSAttributedString *attributedSubtitle; // 富文本副标题
@property (nonatomic, assign) CGFloat subtitleWidthRatio;
@property (nonatomic, assign) NSInteger subtitleMaxLines;

@property (nonatomic, nullable, strong) UIImage *icon; // 图标
@property (nonatomic, assign) CGFloat iconPadding; // 图标间距
@property (nonatomic, assign) UIControlContentHorizontalAlignment iconPosition; // 图标位置 左右

@property (nonatomic, assign) NSInteger tag; // 辅助 tag
@property (nonatomic, assign) CGFloat customHeight; // 强制自定义高度
@property (nonatomic, nullable, strong) UIView *customView; // 自定义 view

- (instancetype _Nonnull )initHeaderWithTitle:(id _Nullable )title subtitle:(id _Nullable)subtitle; // 创建顶部 item
- (instancetype _Nonnull )initWithTitle:(id _Nullable)title action:(void (^_Nullable)( ActionSheetItem * _Nonnull ))action;
- (instancetype _Nonnull )initWithTitle:(id _Nullable)title subtitle:(id _Nullable)subtitle action:(void (^_Nullable)( ActionSheetItem * _Nonnull ))action;
- (instancetype _Nonnull )initWithTitle:(id _Nullable)title icon:(UIImage * _Nullable)icon action:(void (^_Nullable)( ActionSheetItem * _Nonnull ))action;
- (instancetype _Nonnull )initWithTitle:(id _Nullable)title subtitle:(id _Nullable)subtitle icon:(UIImage * _Nullable)icon action:(void (^_Nullable)( ActionSheetItem * _Nonnull ))action;

@end

@interface ActionSheet : UIView

@property (nonatomic, copy) void (^ _Nullable action)(ActionSheetItem * __nonnull); // 事件，优先级比 item 的 action 低，点击取消时 item 为 nil
@property (nonatomic, assign) ActionSheetOption options;

+ (instancetype _Nonnull)shared;
- (instancetype _Nonnull)init;
- (void)showItems:(NSArray<ActionSheetItem *> *_Nullable)items onView:(UIView *_Nonnull)view withOptions:(ActionSheetOption)options;
- (void)dismiss;

@end
