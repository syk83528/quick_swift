//  Created by Wildog on 7/25/18.
//  Copyright © 2018 Xiu. All rights reserved.
//

#import "ActionSheet.h"

#define PSActionSheetItemViewReuseTag 300


@interface ASButton : UIButton

@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat extraHeight;

@end

@implementation ASButton

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width += (self.titleEdgeInsets.left + self.titleEdgeInsets.right);
    size.height += (self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
    size.height += self.extraHeight;
    if (self.minWidth > 0 && size.width < self.minWidth) {
        size.width = self.minWidth;
    }
    return size;
}

@end


@implementation ActionSheetItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.titleFont = [UIFont systemFontOfSize:17];
        self.titleColor = UIColor.darkTextColor;
        self.subtitleFont = [UIFont systemFontOfSize:12];
        self.subtitleColor = UIColor.grayColor;
        self.subtitleWidthRatio = 0.7;
        self.subtitleMaxLines = 3;
        self.iconPadding = 5;
        self.iconPosition = UIControlContentHorizontalAlignmentLeft;
        self.dismissAfterSelection = YES;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title action:(void (^)(ActionSheetItem *))action {
    return [self initWithTitle:title subtitle:nil icon:nil action:action];
}

- (instancetype)initWithTitle:(id)title subtitle:(id)subtitle action:(void (^)(ActionSheetItem *))action {
    return [self initWithTitle:title subtitle:subtitle icon:nil action:action];
}

- (instancetype)initWithTitle:(id)title icon:(UIImage *)icon action:(void (^)(ActionSheetItem *))action {
    return [self initWithTitle:title subtitle:nil icon:icon action:action];
}

- (instancetype)initWithTitle:(id)title subtitle:(id)subtitle icon:(UIImage *)icon action:(void (^)(ActionSheetItem *))action {
    self = [self init];
    if (self) {
        if ([title isKindOfClass:[NSAttributedString class]]) {
            self.attributedTitle = title;
        } else if ([title isKindOfClass:[NSString class]]) {
            self.title = title;
        }
        if ([subtitle isKindOfClass:[NSAttributedString class]]) {
            self.attributedSubtitle = subtitle;
        } else if ([subtitle isKindOfClass:[NSString class]]) {
            self.subtitle = subtitle;
        }
        self.icon = icon;
        self.action = action;
    }
    return self;
}

- (instancetype)initHeaderWithTitle:(id)title subtitle:(id)subtitle {
    self = [self initWithTitle:title subtitle:subtitle icon:nil action:nil];
    if (self) {
        self.userInteractionEnabled = NO;
        self.dismissAfterSelection = NO;
    }
    return self;
}

@end

@interface ActionSheetItemView : UIView

@property (nonatomic, strong) ActionSheetItem *item;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) ASButton *titleButton;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, weak) ActionSheet *delegate;

@end

@interface ActionSheet ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIStackView *itemsContainer;
@property (nonatomic, strong) ActionSheetItemView *cancelButton;

- (void)didSelectItem:(NSDictionary *)userInfo;

@end

@implementation ActionSheetItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.clipsToBounds = YES;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.highlightColor = [UIColor colorWithWhite:0.9 alpha:1.0];

    self.bgView = [[UIView alloc] init];
    self.bgView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.bgView];

    [self.bgView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.bgView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.bgView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.bgView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;

    self.container = [[UIView alloc] init];
    self.container.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.container];

    self.titleButton = [[ASButton alloc] init];
    self.titleButton.userInteractionEnabled = NO;
    self.titleButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.container addSubview:self.titleButton];
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.container addSubview:self.subtitleLabel];

    self.line = [[UIView alloc] init];
    self.line.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.00];
    self.line.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.line];
    [self.line.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.line.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.line.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.line.heightAnchor constraintEqualToConstant:0.5].active = YES;
}

- (void)cleanup {
    self.item = nil;
    [self cleanViews];
}

- (void)cleanViews {
    NSArray<UIView *> *subviews = [self.container.subviews copy];
    for (UIView *obj in subviews) {
        if (obj != self.titleButton && obj != self.subtitleLabel) {
            [obj removeFromSuperview];
        }
    }
}

- (void)configure:(ActionSheetItem *)item {
    _item = item;
    CGFloat minHeight = UIScreen.mainScreen.bounds.size.width <= 320 ? 52 : 58;
    CGFloat topBottomPadding = UIScreen.mainScreen.bounds.size.width <= 320 ? 13 : 16;
    CGFloat gap = UIScreen.mainScreen.bounds.size.width <= 320 ? 2 : 4;

    self.userInteractionEnabled = item.userInteractionEnabled;
    self.bgView.backgroundColor = item.backgroundColor;
    
    for (NSLayoutConstraint *constriant in self.container.constraints) {
        constriant.active = NO;
    }

    if (item.customView) {
        self.titleButton.hidden = self.subtitleLabel.hidden = YES;
        [self cleanViews];
        [self.container addSubview:item.customView];
        [item.customView.leadingAnchor constraintEqualToAnchor:self.container.leadingAnchor].active = YES;
        [item.customView.trailingAnchor constraintEqualToAnchor:self.container.trailingAnchor].active = YES;
        [item.customView.topAnchor constraintEqualToAnchor:self.container.topAnchor].active = YES;
        [item.customView.bottomAnchor constraintEqualToAnchor:self.container.bottomAnchor].active = YES;
    } else {
        self.titleButton.hidden = NO;
        self.titleButton.titleLabel.font = item.titleFont;
        [self.titleButton setTitleColor:item.titleColor forState:UIControlStateNormal];
        [self.titleButton setImage:item.icon forState:UIControlStateNormal];
        self.titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.titleButton.titleLabel.transform = self.titleButton.imageView.transform = self.titleButton.transform = item.iconPosition == UIControlContentHorizontalAlignmentRight ? CGAffineTransformMakeScale(-1, 1) : CGAffineTransformIdentity;
        if (item.icon) {
            self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, item.iconPadding, 0, 0);
        }
        if (item.attributedTitle.length > 0) {
            [self.titleButton setAttributedTitle:item.attributedTitle forState:UIControlStateNormal];
        } else if (item.title.length > 0) {
            [self.titleButton setTitle:item.title forState:UIControlStateNormal];
        } else {
            self.titleButton.hidden = YES;
        }

        self.subtitleLabel.hidden = NO;
        self.subtitleLabel.font = item.subtitleFont;
        self.subtitleLabel.textColor = item.subtitleColor;
        self.subtitleLabel.numberOfLines = item.subtitleMaxLines;
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        if (item.attributedSubtitle.length > 0) {
            self.subtitleLabel.attributedText = item.attributedSubtitle;
        } else if (item.subtitle.length > 0) {
            self.subtitleLabel.text = item.subtitle;
        } else {
            self.subtitleLabel.hidden = YES;
        }

        for (NSLayoutConstraint *constriant in self.titleButton.constraints) {
            constriant.active = NO;
        }
        for (NSLayoutConstraint *constriant in self.subtitleLabel.constraints) {
            constriant.active = NO;
        }
        if (self.subtitleLabel.hidden) {
            [self.titleButton.centerXAnchor constraintEqualToAnchor:self.container.centerXAnchor].active = YES;
            [self.titleButton.centerYAnchor constraintEqualToAnchor:self.container.centerYAnchor].active = YES;
        } else {
            [self.titleButton.centerXAnchor constraintEqualToAnchor:self.container.centerXAnchor].active = YES;
            [self.titleButton.topAnchor constraintEqualToAnchor:self.container.topAnchor constant:topBottomPadding].active = YES;
            [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleButton.bottomAnchor constant:gap].active = YES;
            [self.subtitleLabel.bottomAnchor constraintEqualToAnchor:self.container.bottomAnchor constant:-(topBottomPadding + 2)].active = YES;
            [self.subtitleLabel.centerXAnchor constraintEqualToAnchor:self.container.centerXAnchor].active = YES;
            [self.subtitleLabel.widthAnchor constraintEqualToAnchor:self.container.widthAnchor multiplier:item.subtitleWidthRatio].active = YES;
        }
    }
    [self.container.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.container.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.container.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.container.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.container.widthAnchor constraintEqualToConstant:UIScreen.mainScreen.bounds.size.width - 12 * 2].active = YES;
    if (item.customHeight > 0) {
        [self.container.heightAnchor constraintEqualToConstant:item.customHeight].active = YES;
    } else {
        [self.container.heightAnchor constraintGreaterThanOrEqualToConstant:minHeight].active = YES;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    self.bgView.backgroundColor = self.highlightColor;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    self.bgView.backgroundColor = self.item ? self.item.backgroundColor : [UIColor whiteColor];
    CGPoint location = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(self.bounds, location)) {
        return;
    }
    if (!self.item) {
        return;
    }
    [self.delegate didSelectItem:@{@"item": self.item}];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(self.bounds, location)) {
        self.bgView.backgroundColor = self.highlightColor;
    } else {
        self.bgView.backgroundColor = self.item ? self.item.backgroundColor : [UIColor whiteColor];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    self.bgView.backgroundColor = self.item ? self.item.backgroundColor : [UIColor whiteColor];
}

@end

@implementation ActionSheet

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static ActionSheet *sheet = nil;
    dispatch_once(&onceToken, ^{
        sheet = [[ActionSheet alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return sheet;
}

- (instancetype)init {
    return [[ActionSheet alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    self.bgView = [[UIView alloc] init];
    [self.bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self addSubview:self.bgView];
    [self.bgView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.bgView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.bgView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.bgView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    self.bgView.translatesAutoresizingMaskIntoConstraints = NO;

    self.container = [[UIView alloc] init];
    self.container.clipsToBounds = YES;
    [self addSubview:self.container];
    [self.container.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12].active = YES;
    [self.container.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12].active = YES;
    CGFloat bottom = 0;
    if (@available(iOS 11.0, *)) {
        bottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    }
    [self.container.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-(12 + bottom)].active = YES;
    self.container.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *itemsContainerWrapper = [[UIView alloc] init];
    itemsContainerWrapper.clipsToBounds = YES;
    itemsContainerWrapper.layer.cornerRadius = 14;
    itemsContainerWrapper.translatesAutoresizingMaskIntoConstraints = NO;
    [self.container addSubview:itemsContainerWrapper];

    self.itemsContainer = [[UIStackView alloc] init];
    self.itemsContainer.spacing = 0;
    self.itemsContainer.alignment = UIStackViewAlignmentBottom;
    self.itemsContainer.axis = UILayoutConstraintAxisVertical;
    self.itemsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [itemsContainerWrapper addSubview:self.itemsContainer];
    [itemsContainerWrapper.leadingAnchor constraintEqualToAnchor:self.itemsContainer.leadingAnchor].active = YES;
    [itemsContainerWrapper.trailingAnchor constraintEqualToAnchor:self.itemsContainer.trailingAnchor].active = YES;
    [itemsContainerWrapper.topAnchor constraintEqualToAnchor:self.itemsContainer.topAnchor].active = YES;
    [itemsContainerWrapper.bottomAnchor constraintEqualToAnchor:self.itemsContainer.bottomAnchor].active = YES;

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:PSOverlayControlsShouldHideNotification object:nil];
}

- (void)configureItems:(NSArray<ActionSheetItem *> *)items {
    for (UIView *subview in [self.itemsContainer.arrangedSubviews copy]) {
        subview.hidden = YES;
        [self.itemsContainer removeArrangedSubview:subview];
    }
    [items enumerateObjectsUsingBlock:^(ActionSheetItem *item, NSUInteger idx, BOOL *stop) {
        ActionSheetItemView *cell = [self.itemsContainer viewWithTag:PSActionSheetItemViewReuseTag + idx];
        if (!cell) {
            cell = [[ActionSheetItemView alloc] init];
            cell.delegate = self;
            cell.tag = PSActionSheetItemViewReuseTag + idx;
        }
        cell.hidden = NO;
        [cell configure:item];
        cell.line.hidden = *stop;
        [self.itemsContainer addArrangedSubview:cell];
    }];
    for (NSLayoutConstraint *constriant in self.itemsContainer.constraints) {
        constriant.active = NO;
    }
    if (self.options & ActionSheetOptionShowCancelButton) {
        if (!self.cancelButton) {
            ActionSheetItem *cancelItem = [[ActionSheetItem alloc] initWithTitle:@"取消" action:nil];
            cancelItem.tag = -1;
            cancelItem.titleColor = UIColor.grayColor;
            self.cancelButton = [[ActionSheetItemView alloc] init];
            self.cancelButton.delegate = self;
            [self.cancelButton configure:cancelItem];
            self.cancelButton.layer.cornerRadius = 14;
            [self.container addSubview:self.cancelButton];
            [self.cancelButton.leadingAnchor constraintEqualToAnchor:self.container.leadingAnchor].active = YES;
            [self.cancelButton.trailingAnchor constraintEqualToAnchor:self.container.trailingAnchor].active = YES;
            [self.cancelButton.bottomAnchor constraintEqualToAnchor:self.container.bottomAnchor].active = YES;
        }
        [self.itemsContainer.leadingAnchor constraintEqualToAnchor:self.container.leadingAnchor].active = YES;
        [self.itemsContainer.trailingAnchor constraintEqualToAnchor:self.container.trailingAnchor].active = YES;
        [self.itemsContainer.topAnchor constraintEqualToAnchor:self.container.topAnchor].active = YES;
        [self.itemsContainer.bottomAnchor constraintEqualToAnchor:self.cancelButton.topAnchor constant:-6].active = YES;
    } else {
        [self.itemsContainer.leadingAnchor constraintEqualToAnchor:self.container.leadingAnchor].active = YES;
        [self.itemsContainer.trailingAnchor constraintEqualToAnchor:self.container.trailingAnchor].active = YES;
        [self.itemsContainer.topAnchor constraintEqualToAnchor:self.container.topAnchor].active = YES;
        [self.itemsContainer.bottomAnchor constraintEqualToAnchor:self.container.bottomAnchor].active = YES;
    }
}

- (void)didSelectItem:(NSDictionary *)userInfo {
    ActionSheetItem *item = userInfo[@"item"];
    if (item.dismissAfterSelection) {
        [self dismiss];
    }
    if (item.action) {
        item.action(item);
    } else if (self.action) {
        self.action(item.tag == -1 ? nil : item);
    }
}

- (void)showItems:(NSArray<ActionSheetItem *> *)items onView:(UIView *)view withOptions:(ActionSheetOption)options {
    if (self.superview) {
        return;
    }
    _options = options;
    [self configureItems:items];
    CGFloat bottom = 0;
    if (@available(iOS 11.0, *)) {
        bottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    }
    self.container.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.container.bounds) + bottom + 20);
    self.bgView.alpha = 0;
    [view addSubview:self];
    [self layoutIfNeeded];
    if (options & ActionSheetOptionDimBackground) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.bgView.alpha = 1;
        } completion:nil];
    }
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.4 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.container.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)dismiss {
    if (!self.superview || !CGAffineTransformIsIdentity(self.container.transform)) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    CGFloat bottom = 0;
    if (@available(iOS 11.0, *)) {
        bottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
        if (self.options & ActionSheetOptionDimBackground) {
            self.bgView.alpha = 0;
        }
        self.container.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.container.bounds) + bottom + 20);
    } completion:^(BOOL finished) {
        weakSelf.action = nil;
        for (UIView *view in weakSelf.itemsContainer.subviews) {
            if ([view isKindOfClass:[ActionSheetItemView class]]) {
                [(ActionSheetItemView *)view cleanup];
            }
        }
        [weakSelf removeFromSuperview];
    }];
}

//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
//    var location = [[touches anyObject] locationInView:self];
//    NSLog(@"12123: %@", NSStringFromCGPoint(location));
////    if (CGRectContainsPoint(self.bounds, location)) {
////        self.bgView.backgroundColor = self.highlightColor;
////    } else {
////        self.bgView.backgroundColor = self.item ? self.item.backgroundColor : [UIColor whiteColor];
////    }
//}

@end
