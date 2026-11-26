#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#import <Vision/Vision.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>
#import <math.h>

static NSString * const DBLicenseActivateEndpoint = @"https://hhabjbw-001-site1.ktempurl.com/api/license/activate";
static NSString * const DBLicenseValidateEndpoint = @"https://hhabjbw-001-site1.ktempurl.com/api/license/validate";
static NSString * const DBTikTok = @"@tuatbonxyz";
static NSString * const DBSavedLicenseKey = @"com.doxbon.vds.savedLicenseKey";
static NSString * const DBFloatingButtonPositionKey = @"com.doxbon.vds.floatingButtonPosition";
static NSString * const DBZalo = @"0854582858";

@interface DBMenuController : UIViewController <PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic,strong) UIView *panel;
@property(nonatomic,strong) UITextField *keyField;
@property(nonatomic,strong) UILabel *statusLabel;
@property(nonatomic,strong) NSString *activeKey;
@property(nonatomic,strong) NSDate *expiryDate;
@property(nonatomic,strong) UIView *contentView;
@property(nonatomic,strong) NSString *expiryText;
@property(nonatomic,strong) UIButton *floatingButton;
@property(nonatomic,strong) UIScrollView *tabBar;
@property(nonatomic,strong) UIScrollView *contentScroll;
@property(nonatomic,strong) CAGradientLayer *panelGradient;
@property(nonatomic,strong) UILabel *headerSubtitle;
@property(nonatomic,strong) UIView *activeIndicator;
@property(nonatomic,strong) NSArray<UIButton *> *tabButtons;
@end

@interface DBPassthroughView : UIView
@end

@implementation DBPassthroughView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    // Outside visible controls, let the underlying Video Star window receive touches.
    return hit == self ? nil : hit;
}
@end

// Important: the transparent root controller must not become the hit target.
@interface DBPassthroughWindow : UIWindow
@end
@implementation DBPassthroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self.rootViewController.view) return nil;
    return hit;
}
@end

@interface DBRoundedPanelView : UIView
@end
@implementation DBRoundedPanelView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIBezierPath *shape = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:25.0];
    if (![shape containsPoint:point]) return nil;
    return [super hitTest:point withEvent:event];
}
@end

@implementation DBMenuController

- (void)loadView {
    self.view = [[DBPassthroughView alloc] initWithFrame:UIScreen.mainScreen.bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    [self buildPanel];
    [self showLogin];
    [self restoreSavedLicenseKey];
}

- (void)buildPanel {
    CGFloat screenW = CGRectGetWidth(UIScreen.mainScreen.bounds);
    CGFloat screenH = CGRectGetHeight(UIScreen.mainScreen.bounds);
    CGFloat panelW = MIN(350.0, screenW - 30.0);
    CGFloat panelH = MIN(410.0, screenH - 110.0);
    self.panel = [[DBRoundedPanelView alloc] initWithFrame:CGRectMake(0, 0, panelW, panelH)];
    self.panel.center = self.view.center;
    self.panel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.panel.backgroundColor = [UIColor colorWithRed:.025 green:.018 blue:.075 alpha:.985];
    self.panel.layer.cornerRadius = 25.0;
    self.panel.layer.borderWidth = 1.6;
    self.panel.layer.borderColor = [UIColor colorWithRed:.67 green:.28 blue:1 alpha:1].CGColor;
    self.panel.layer.shadowColor = [UIColor colorWithRed:.55 green:.12 blue:1 alpha:1].CGColor;
    self.panel.layer.shadowOpacity = .62;
    self.panel.layer.shadowRadius = 24;
    self.panel.layer.shadowOffset = CGSizeMake(0, 8);
    self.panel.clipsToBounds = NO;
    [self.view addSubview:self.panel];

    self.panelGradient = [CAGradientLayer layer];
    self.panelGradient.frame = self.panel.bounds;
    self.panelGradient.cornerRadius = 25.0;
    self.panelGradient.colors = @[
        (id)[UIColor colorWithRed:.12 green:.025 blue:.25 alpha:1].CGColor,
        (id)[UIColor colorWithRed:.025 green:.025 blue:.105 alpha:1].CGColor,
        (id)[UIColor colorWithRed:.018 green:.055 blue:.16 alpha:1].CGColor
    ];
    self.panelGradient.startPoint = CGPointMake(0, 0);
    self.panelGradient.endPoint = CGPointMake(1, 1);
    [self.panel.layer insertSublayer:self.panelGradient atIndex:0];

    // Bottom neon streak, matching the reference menu artwork.
    CAGradientLayer *streak = [CAGradientLayer layer];
    streak.frame = CGRectMake(0, panelH-5, panelW, 5);
    streak.colors = @[(id)[UIColor colorWithRed:.35 green:.12 blue:1 alpha:0].CGColor,
                      (id)[UIColor colorWithRed:.72 green:.18 blue:1 alpha:1].CGColor,
                      (id)[UIColor colorWithRed:.20 green:.48 blue:1 alpha:.85].CGColor];
    streak.startPoint = CGPointMake(0, .5);
    streak.endPoint = CGPointMake(1, .5);
    streak.cornerRadius = 3;
    [self.panel.layer addSublayer:streak];

    UILabel *star = [[UILabel alloc] initWithFrame:CGRectMake(13, 13, 30, 32)];
    star.text = @"★";
    star.font = [UIFont systemFontOfSize:27 weight:UIFontWeightBlack];
    star.textColor = [UIColor colorWithRed:.68 green:.25 blue:1 alpha:1];
    [self.panel addSubview:star];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(47, 13, panelW-100, 24)];
    title.text = @"DOXBON / VDS TOOL";
    title.font = [UIFont systemFontOfSize:15.5 weight:UIFontWeightHeavy];
    title.textColor = [UIColor colorWithRed:.78 green:.48 blue:1 alpha:1];
    [self.panel addSubview:title];

    self.headerSubtitle = [[UILabel alloc] initWithFrame:CGRectMake(48, 37, panelW-100, 15)];
    self.headerSubtitle.text = @"VIP CONTROL CENTER  •  ONLINE  ●";
    self.headerSubtitle.font = [UIFont systemFontOfSize:8.5 weight:UIFontWeightSemibold];
    self.headerSubtitle.textColor = [UIColor colorWithWhite:1 alpha:.76];
    [self.panel addSubview:self.headerSubtitle];

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.frame = CGRectMake(panelW-43, 14, 29, 29);
    close.backgroundColor = [UIColor colorWithRed:.30 green:.12 blue:.55 alpha:.75];
    close.layer.cornerRadius = 10;
    close.layer.borderWidth = 1;
    close.layer.borderColor = [UIColor colorWithRed:.58 green:.28 blue:1 alpha:.7].CGColor;
    [close setTitle:@"×" forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightLight];
    [close setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [close addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:close];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragPanel:)];
    [title addGestureRecognizer:pan];
    title.userInteractionEnabled = YES;

    self.tabBar = [[UIScrollView alloc] initWithFrame:CGRectMake(12, 58, panelW-24, 44)];
    self.tabBar.showsHorizontalScrollIndicator = NO;
    self.tabBar.scrollEnabled = NO;
    self.tabBar.backgroundColor = [UIColor colorWithWhite:1 alpha:.045];
    self.tabBar.layer.cornerRadius = 17;
    [self.panel addSubview:self.tabBar];

    NSArray *names = @[@"⌂\nHOME", @"▦\nQR LAB", @"▷\nMEDIA", @"⚙\nSETTINGS", @"ⓘ\nINFO"];
    NSMutableArray *buttons = [NSMutableArray array];
    CGFloat gap = 4.0;
    CGFloat tabW = floor((panelW-30.0-gap*4.0)/5.0);
    for (NSUInteger i=0; i<names.count; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = CGRectMake(3 + i*(tabW+gap), 3, tabW, 38);
        b.tag = i;
        b.layer.cornerRadius = 14;
        b.titleLabel.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBold];
        b.titleLabel.numberOfLines = 2;
        b.titleLabel.textAlignment = NSTextAlignmentCenter;
        b.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        b.titleLabel.adjustsFontSizeToFitWidth = YES;
        b.titleLabel.minimumScaleFactor = .8;
        [b setTitle:names[i] forState:UIControlStateNormal];
        [b setTitleColor:[UIColor colorWithWhite:1 alpha:.72] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(tabPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBar addSubview:b];
        [buttons addObject:b];
    }
    self.tabButtons = buttons;
    self.tabBar.contentSize = CGSizeMake(panelW-24, 44);

    self.contentScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(13, 110, panelW-26, panelH-122)];
    self.contentScroll.alwaysBounceVertical = YES;
    self.contentScroll.showsVerticalScrollIndicator = NO;
    self.contentScroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.panel addSubview:self.contentScroll];
    self.contentView = self.contentScroll;

    self.floatingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.floatingButton.frame = CGRectMake(16, MAX(100, screenH*.32), 50, 50);
    self.floatingButton.layer.cornerRadius = 25;
    self.floatingButton.backgroundColor = [UIColor colorWithRed:.30 green:.08 blue:.65 alpha:.98];
    self.floatingButton.layer.borderWidth = 1.7;
    self.floatingButton.layer.borderColor = [UIColor colorWithRed:.78 green:.32 blue:1 alpha:1].CGColor;
    self.floatingButton.layer.shadowColor = [UIColor colorWithRed:.68 green:.12 blue:1 alpha:1].CGColor;
    self.floatingButton.layer.shadowOpacity = .9;
    self.floatingButton.layer.shadowRadius = 15;
    [self.floatingButton setTitle:@"♛\nDB" forState:UIControlStateNormal];
    [self.floatingButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.floatingButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBlack];
    self.floatingButton.titleLabel.numberOfLines = 2;
    self.floatingButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.floatingButton addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
    // Drag the collapsed icon anywhere on screen; a normal tap still opens the menu.
    UIPanGestureRecognizer *iconPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragFloatingButton:)];
    iconPan.minimumNumberOfTouches = 1;
    [self.floatingButton addGestureRecognizer:iconPan];
    [self.view addSubview:self.floatingButton];
    NSString *savedPosition = [[NSUserDefaults standardUserDefaults] stringForKey:DBFloatingButtonPositionKey];
    if (savedPosition.length) {
        CGPoint point = CGPointFromString(savedPosition);
        if (isfinite(point.x) && isfinite(point.y) && !CGPointEqualToPoint(point, CGPointZero)) {
            self.floatingButton.center = point;
        }
    }
    self.floatingButton.hidden = YES;
    self.tabBar.hidden = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.panelGradient.frame = self.panel.bounds;
}

- (void)dragFloatingButton:(UIPanGestureRecognizer *)gesture {
    CGPoint delta = [gesture translationInView:self.view];
    CGPoint center = self.floatingButton.center;
    center.x += delta.x;
    center.y += delta.y;
    CGFloat halfW = CGRectGetWidth(self.floatingButton.bounds) * 0.5;
    CGFloat halfH = CGRectGetHeight(self.floatingButton.bounds) * 0.5;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    center.x = MIN(MAX(halfW, center.x), MAX(halfW, width-halfW));
    center.y = MIN(MAX(halfH, center.y), MAX(halfH, height-halfH));
    self.floatingButton.center = center;
    [gesture setTranslation:CGPointZero inView:self.view];
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        [[NSUserDefaults standardUserDefaults] setObject:NSStringFromCGPoint(self.floatingButton.center)
                                                  forKey:DBFloatingButtonPositionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)dragPanel:(UIPanGestureRecognizer *)gesture {
    CGPoint delta = [gesture translationInView:self.view];
    self.panel.center = CGPointMake(self.panel.center.x + delta.x,
                                    self.panel.center.y + delta.y);
    // Use CGPointMake instead of CGPointZero to avoid the unresolved linker symbol.
    [gesture setTranslation:CGPointMake(0.0, 0.0) inView:self.view];
}

- (UIButton *)button:(NSString *)title frame:(CGRect)frame action:(SEL)action {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = frame;
    b.backgroundColor = [UIColor colorWithRed:.27 green:.075 blue:.62 alpha:.98];
    b.layer.cornerRadius = 18;
    b.layer.borderWidth = 1;
    b.layer.borderColor = [UIColor colorWithRed:.58 green:.28 blue:1 alpha:.92].CGColor;
    b.layer.shadowColor = [UIColor colorWithRed:.48 green:.12 blue:1 alpha:1].CGColor;
    b.layer.shadowOpacity = .28;
    b.layer.shadowRadius = 9;
    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    b.titleLabel.adjustsFontSizeToFitWidth = YES;
    b.titleLabel.minimumScaleFactor = .75;
    [b addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:b];
    return b;
}

- (UILabel *)label:(NSString *)text frame:(CGRect)frame size:(CGFloat)size color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:size weight:UIFontWeightMedium];
    label.numberOfLines = 0;
    [self.contentView addSubview:label];
    return label;
}

- (void)updateTabSelection:(NSInteger)selected {
    [self.tabButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        BOOL active = ((NSInteger)idx == selected);
        button.backgroundColor = active
            ? [UIColor colorWithRed:.55 green:.16 blue:.92 alpha:.98]
            : [UIColor colorWithWhite:1 alpha:.025];
        button.layer.borderWidth = active ? 0.8 : 0.4;
        button.layer.borderColor = active
            ? [UIColor colorWithRed:.80 green:.42 blue:1 alpha:.95].CGColor
            : [UIColor colorWithWhite:1 alpha:.08].CGColor;
        button.layer.shadowColor = [UIColor colorWithRed:.62 green:.16 blue:1 alpha:1].CGColor;
        button.layer.shadowOpacity = active ? .45 : 0;
        button.layer.shadowRadius = active ? 9 : 0;
        [button setTitleColor:active ? UIColor.whiteColor : [UIColor colorWithWhite:1 alpha:.66]
                     forState:UIControlStateNormal];
    }];
}

- (void)tabPressed:(UIButton *)sender {
    switch (sender.tag) {
        case 0: [self showFeatures]; break;
        case 1: [self showQRTab]; break;
        case 2: [self showMediaTab]; break;
        case 3: [self showSettings]; break;
        case 4: [self showAboutTab]; break;
        default: break;
    }
}

- (void)showLogin {
    self.tabBar.hidden = YES;
    self.headerSubtitle.text = @"LICENSE AUTHENTICATION";
    for (UIView *v in self.contentView.subviews) [v removeFromSuperview];
    self.contentScroll.contentSize = self.contentScroll.bounds.size;

    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(8,24,self.contentView.bounds.size.width-16,30)];
    hint.text = @"Nhập VIP Key để tiếp tục";
    hint.textColor = UIColor.whiteColor;
    hint.textAlignment = NSTextAlignmentCenter;
    hint.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    [self.contentView addSubview:hint];

    self.keyField = [[UITextField alloc] initWithFrame:CGRectMake(8,76,self.contentView.bounds.size.width-16,42)];
    self.keyField.placeholder = @"DB-XXXX-XXXX";
    self.keyField.textColor = UIColor.whiteColor;
    self.keyField.tintColor = UIColor.purpleColor;
    self.keyField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.keyField.borderStyle = UITextBorderStyleRoundedRect;
    self.keyField.backgroundColor = [UIColor colorWithWhite:1 alpha:.10];
    self.keyField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"DB-XXXX-XXXX"
        attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:.55]}];
    [self.contentView addSubview:self.keyField];

    [self button:@"XÁC NHẬN KEY" frame:CGRectMake(8,132,self.contentView.bounds.size.width-16,42) action:@selector(validateKey)];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,188,self.contentView.bounds.size.width-16,42)];
    self.statusLabel.text = @"Kết nối máy chủ để xác thực";
    self.statusLabel.textColor = [UIColor colorWithWhite:1 alpha:.7];
    self.statusLabel.font = [UIFont systemFontOfSize:12];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 2;
    [self.contentView addSubview:self.statusLabel];
}

- (void)sendLicenseRequestTo:(NSString *)endpoint
                         key:(NSString *)key
                    deviceID:(NSString *)deviceID
                  completion:(void (^)(NSDictionary *json, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:endpoint];
    if (!url) {
        NSError *e = [NSError errorWithDomain:@"DoxBonLicense" code:1
                                     userInfo:@{NSLocalizedDescriptionKey:@"Địa chỉ API không hợp lệ."}];
        completion(nil, e);
        return;
    }

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    req.timeoutInterval = 20;
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSDictionary *payload = @{@"key":key, @"device_id":deviceID};
    NSError *serializationError = nil;
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&serializationError];
    if (serializationError || !req.HTTPBody) {
        completion(nil, serializationError);
        return;
    }

    [[[NSURLSession sharedSession] dataTaskWithRequest:req
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = nil;
        if (data.length) {
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([object isKindOfClass:NSDictionary.class]) json = (NSDictionary *)object;
        }
        completion(json, error);
    }] resume];
}

- (void)validateKey {
    NSString *rawKey = self.keyField.text;
    if (rawKey == nil) {
        rawKey = @"";
    }

    NSString *trimmedKey = [rawKey stringByTrimmingCharactersInSet:
        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *key = [trimmedKey uppercaseString];
    if (key.length < 8) {
        self.statusLabel.text = @"Vui lòng nhập VIP Key hợp lệ.";
        return;
    }

    self.statusLabel.text = @"Đang kích hoạt thiết bị...";
    NSString *deviceID = UIDevice.currentDevice.identifierForVendor.UUIDString ?: @"unknown-device";

    [self sendLicenseRequestTo:DBLicenseActivateEndpoint key:key deviceID:deviceID
                    completion:^(NSDictionary *activation, NSError *activationError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL activated = !activationError && [activation[@"ok"] respondsToSelector:@selector(boolValue)]
                             && [activation[@"ok"] boolValue];
            if (!activated) {
                NSString *message = [activation[@"error"] isKindOfClass:NSString.class]
                                    ? activation[@"error"] : @"Không thể kích hoạt key.";
                self.statusLabel.text = activationError ? @"Không kết nối được máy chủ." : message;
                return;
            }

            self.statusLabel.text = @"Đang kiểm tra giấy phép...";
            [self sendLicenseRequestTo:DBLicenseValidateEndpoint key:key deviceID:deviceID
                            completion:^(NSDictionary *validation, NSError *validationError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL valid = !validationError && [validation[@"ok"] respondsToSelector:@selector(boolValue)]
                                 && [validation[@"ok"] boolValue]
                                 && [@"active" isEqualToString:validation[@"status"]];
                    if (valid) {
                        self.activeKey = key;
                        [[NSUserDefaults standardUserDefaults] setObject:key forKey:DBSavedLicenseKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        id expiry = validation[@"expires_at"];
                        if ([expiry respondsToSelector:@selector(longLongValue)] && [expiry longLongValue] > 0) {
                            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[expiry longLongValue]];
                            NSDateFormatter *formatter = [NSDateFormatter new];
                            formatter.dateStyle = NSDateFormatterMediumStyle;
                            formatter.timeStyle = NSDateFormatterNoStyle;
                            self.expiryText = [formatter stringFromDate:date];
                        } else {
                            self.expiryText = @"Vĩnh viễn";
                        }
                        [self showDashboardWithExpiry:self.expiryText];
                    } else {
                        NSString *message = [validation[@"error"] isKindOfClass:NSString.class]
                                            ? validation[@"error"] : @"Key không hợp lệ hoặc đã hết hạn.";
                        self.statusLabel.text = validationError ? @"Không kết nối được máy chủ." : message;
                    }
                });
            }];
        });
    }];
}

- (void)restoreSavedLicenseKey {
    NSString *savedKey = [[NSUserDefaults standardUserDefaults] stringForKey:DBSavedLicenseKey];
    if (![savedKey isKindOfClass:NSString.class] || savedKey.length < 8) return;
    self.keyField.text = savedKey;
    self.statusLabel.text = @"Đang kiểm tra lại VIP Key đã lưu...";
    NSString *deviceID = UIDevice.currentDevice.identifierForVendor.UUIDString ?: @"unknown-device";
    [self sendLicenseRequestTo:DBLicenseValidateEndpoint key:savedKey deviceID:deviceID
                    completion:^(NSDictionary *validation, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL valid = !error && [validation[@"ok"] respondsToSelector:@selector(boolValue)]
                         && [validation[@"ok"] boolValue]
                         && [@"active" isEqualToString:validation[@"status"]];
            if (!valid) {
                // Keep the key in the field so the user can retry if the server was offline.
                self.statusLabel.text = error ? @"Không kết nối được máy chủ. Key vẫn được giữ lại." : @"Key không còn hoạt động. Vui lòng nhập key khác.";
                if (!error) {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DBSavedLicenseKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                return;
            }
            self.activeKey = savedKey;
            id expiry = validation[@"expires_at"];
            if ([expiry respondsToSelector:@selector(longLongValue)] && [expiry longLongValue] > 0) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[expiry longLongValue]];
                NSDateFormatter *formatter = [NSDateFormatter new];
                formatter.dateStyle = NSDateFormatterMediumStyle;
                formatter.timeStyle = NSDateFormatterNoStyle;
                self.expiryText = [formatter stringFromDate:date];
            } else {
                self.expiryText = @"Vĩnh viễn";
            }
            [self showDashboardWithExpiry:self.expiryText];
        });
    }];
}

- (void)showDashboardWithExpiry:(NSString *)expiry {
    self.expiryText = expiry ?: @"Không xác định";
    self.tabBar.hidden = NO;
    self.headerSubtitle.text = @"VIP ACCESS  •  PROTECTED SESSION";
    [self showFeatures];
}

- (void)clearDashboardContent {
    for (UIView *v in [self.contentView.subviews copy]) [v removeFromSuperview];
    self.contentScroll.contentOffset = CGPointZero;
}

- (void)finishContentAtY:(CGFloat)y {
    self.contentScroll.contentSize = CGSizeMake(self.contentScroll.bounds.size.width, MAX(y+12, self.contentScroll.bounds.size.height+1));
}

- (void)showFeatures {
    [self updateTabSelection:0];
    [self clearDashboardContent];
    CGFloat w = self.contentView.bounds.size.width;

    UIView *sectionMark = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 4, 17)];
    sectionMark.backgroundColor = [UIColor colorWithRed:.72 green:.24 blue:1 alpha:1];
    sectionMark.layer.cornerRadius = 2;
    [self.contentView addSubview:sectionMark];
    [self label:@"CONTROL CENTER" frame:CGRectMake(14,4,w-20,19) size:10 color:[UIColor colorWithWhite:.78 alpha:1]];
    [self label:@"Chào mừng trở lại DoxBon VIP  ♛" frame:CGRectMake(8,27,w-16,27) size:14.5 color:UIColor.whiteColor];

    UIView *status = [[UIView alloc] initWithFrame:CGRectMake(5,62,w-10,36)];
    status.backgroundColor = [UIColor colorWithRed:.025 green:.20 blue:.12 alpha:.78];
    status.layer.cornerRadius = 18;
    status.layer.borderWidth = 1.2;
    status.layer.borderColor = [UIColor colorWithRed:.08 green:.95 blue:.42 alpha:1].CGColor;
    status.layer.shadowColor = [UIColor colorWithRed:.02 green:.9 blue:.35 alpha:1].CGColor;
    status.layer.shadowOpacity = .22;
    status.layer.shadowRadius = 8;
    [self.contentView addSubview:status];
    UILabel *st = [[UILabel alloc] initWithFrame:CGRectMake(12,0,status.bounds.size.width-24,36)];
    st.text = [NSString stringWithFormat:@"●  VIP ACTIVE  •  %@                         ♛", self.expiryText ?: @"Vĩnh viễn"];
    st.font = [UIFont systemFontOfSize:10.5 weight:UIFontWeightBold];
    st.textColor = [UIColor colorWithRed:.48 green:1 blue:.68 alpha:1];
    st.adjustsFontSizeToFitWidth = YES;
    st.minimumScaleFactor = .78;
    [status addSubview:st];

    UIView *quickMark = [[UIView alloc] initWithFrame:CGRectMake(5,110,4,17)];
    quickMark.backgroundColor = [UIColor colorWithRed:.72 green:.24 blue:1 alpha:1];
    quickMark.layer.cornerRadius = 2;
    [self.contentView addSubview:quickMark];
    [self label:@"QUICK TOOLS" frame:CGRectMake(14,109,w-20,19) size:10 color:[UIColor colorWithWhite:.78 alpha:1]];

    CGFloat gap = 7;
    CGFloat cardW = (w-17-gap)/2.0;
    [self button:@"▦   BATCH QR     ›" frame:CGRectMake(5,134,cardW,43) action:@selector(startBatchQR)];
    [self button:@"▧   REPLACE MEDIA  ›" frame:CGRectMake(12+cardW,134,cardW,43) action:@selector(startReplaceMedia)];
    [self button:@"✦   ONE-TOUCH    ›" frame:CGRectMake(5,184,cardW,43) action:@selector(startOneTouchMedia)];
    [self button:@"⚙   SETTINGS     ›" frame:CGRectMake(12+cardW,184,cardW,43) action:@selector(showSettings)];

    UILabel *tip = [self label:@"ⓘ  QR LAB có thể quét nhiều ảnh đã chọn\nvà công cụ media hiện chỉ chọn ảnh." frame:CGRectMake(12,237,w-24,38) size:9.5 color:[UIColor colorWithWhite:.70 alpha:1]];
    tip.numberOfLines = 2;
    [self finishContentAtY:282];
}

- (void)showQRTab {
    [self updateTabSelection:1];
    [self clearDashboardContent];
    CGFloat w = self.contentView.bounds.size.width;
    [self label:@"QR LAB" frame:CGRectMake(5,5,w-10,23) size:16 color:[UIColor colorWithRed:.75 green:.56 blue:1 alpha:1]];
    [self label:@"Quét mã QR từ nhiều ảnh trong thư viện." frame:CGRectMake(5,32,w-10,32) size:10 color:[UIColor colorWithWhite:1 alpha:.65]];
    [self button:@"▦  CHỌN NHIỀU ẢNH ĐỂ QUÉT QR" frame:CGRectMake(5,78,w-10,48) action:@selector(startBatchQR)];
    [self label:@"Hỗ trợ tối đa 30 ảnh mỗi lượt. Kết quả được hiển thị sau khi Vision xử lý xong." frame:CGRectMake(7,139,w-14,48) size:9 color:[UIColor colorWithWhite:1 alpha:.50]];
    [self finishContentAtY:205];
}

- (void)showMediaTab {
    [self updateTabSelection:2];
    [self clearDashboardContent];
    CGFloat w = self.contentView.bounds.size.width;
    [self label:@"MEDIA TOOLS" frame:CGRectMake(5,5,w-10,23) size:16 color:[UIColor colorWithRed:.48 green:.82 blue:1 alpha:1]];
    [self label:@"Chọn ảnh để chuẩn bị thao tác. Hai nút dưới đây chưa tự sửa timeline Video Star." frame:CGRectMake(5,32,w-10,42) size:9 color:[UIColor colorWithWhite:1 alpha:.60]];
    [self button:@"▧  REPLACE MEDIA  /  CHỌN ẢNH" frame:CGRectMake(5,88,w-10,48) action:@selector(startReplaceMedia)];
    [self button:@"✦  ONE-TOUCH MEDIA  /  CHỌN NHANH" frame:CGRectMake(5,148,w-10,48) action:@selector(startOneTouchMedia)];
    [self finishContentAtY:215];
}

- (void)showSettings {
    [self updateTabSelection:3];
    [self clearDashboardContent];
    CGFloat w = self.contentView.bounds.size.width;
    [self label:@"SETTINGS" frame:CGRectMake(5,5,w-10,23) size:16 color:[UIColor colorWithRed:.75 green:.56 blue:1 alpha:1]];
    NSArray *lines = @[
        [NSString stringWithFormat:@"TikTok     %@", DBTikTok],
        [NSString stringWithFormat:@"Zalo        %@", DBZalo],
        [NSString stringWithFormat:@"Expires    %@", self.expiryText ?: @"Không xác định"],
        [NSString stringWithFormat:@"License    %@", [self maskedKey]]
    ];
    CGFloat y=42;
    for (NSString *line in lines) {
        UIView *row = [[UIView alloc] initWithFrame:CGRectMake(5,y,w-10,34)];
        row.backgroundColor = [UIColor colorWithWhite:1 alpha:.055];
        row.layer.cornerRadius = 8;
        [self.contentView addSubview:row];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(9,0,row.bounds.size.width-18,34)];
        label.text = line;
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
        [row addSubview:label];
        y += 41;
    }
    [self button:@"CHECK KEY" frame:CGRectMake(5,y+8,(w-18)/2,40) action:@selector(recheckKey)];
    [self button:@"LOG OUT" frame:CGRectMake(13+(w-18)/2,y+8,(w-18)/2,40) action:@selector(logout)];
    [self finishContentAtY:y+62];
}

- (void)showAboutTab {
    [self updateTabSelection:4];
    [self clearDashboardContent];
    CGFloat w = self.contentView.bounds.size.width;
    [self label:@"DOXBON VDS TOOL" frame:CGRectMake(5,5,w-10,24) size:16 color:[UIColor colorWithRed:.80 green:.60 blue:1 alpha:1]];
    [self label:@"PURPLE NEON EDITION  •  BUILD 1.4" frame:CGRectMake(5,33,w-10,18) size:9 color:[UIColor colorWithWhite:1 alpha:.52]];
    [self label:@"Developer support\nTikTok: @tuatbonxyz\nZalo: 0854582858\n\nTouch passthrough: enabled\nQR engine: Apple Vision\nMedia timeline automation: requires supported Video Star project API." frame:CGRectMake(7,65,w-14,145) size:10 color:[UIColor colorWithWhite:1 alpha:.78]];
    [self finishContentAtY:225];
}

- (void)presentPhotoPickerAllowingMultiple:(BOOL)multiple purpose:(NSString *)purpose {
    if (@available(iOS 14.0, *)) {
        PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
        config.filter = [PHPickerFilter imagesFilter];
        config.selectionLimit = multiple ? 30 : 1;
        PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:config];
        picker.delegate = self;
        objc_setAssociatedObject(picker, @selector(picker:didFinishPicking:), purpose, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
        picker.delegate = self;
        objc_setAssociatedObject(picker, @selector(picker:didFinishPicking:), purpose, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)startBatchQR {
    [self presentPhotoPickerAllowingMultiple:YES purpose:@"qr"];
}

- (void)startReplaceMedia {
    [self presentPhotoPickerAllowingMultiple:NO purpose:@"replace"];
}

- (void)startOneTouchMedia {
    [self presentPhotoPickerAllowingMultiple:NO purpose:@"quick"];
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14.0)) {
    NSString *purpose = objc_getAssociatedObject(picker, @selector(picker:didFinishPicking:));
    [picker dismissViewControllerAnimated:YES completion:^{
        if (results.count == 0) return;
        if ([purpose isEqualToString:@"qr"]) {
            [self scanQRFromPickerResults:results index:0 collected:[NSMutableArray array]];
        } else {
            NSItemProvider *provider = results.firstObject.itemProvider;
            if ([provider canLoadObjectOfClass:UIImage.class]) {
                [provider loadObjectOfClass:UIImage.class completionHandler:^(id<NSItemProviderReading> object, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error || ![object isKindOfClass:UIImage.class]) {
                            [self showMessage:@"Không thể đọc ảnh đã chọn."];
                            return;
                        }
                        UIImage *image = (UIImage *)object;
                        NSString *message = [purpose isEqualToString:@"replace"]
                            ? @"Đã chọn media. Video Star không cung cấp API project/asset trong source hiện tại, nên chưa thể tự thay clip trong timeline."
                            : @"Đã chọn media thành công. Bạn có thể tiếp tục thao tác trong Video Star; source hiện chưa có API để tự chèn asset vào project.";
                        [self showImage:image message:message];
                    });
                }];
            } else {
                [self showMessage:@"Định dạng đã chọn chưa được hỗ trợ trong bản này."];
            }
        }
    }];
}

- (void)scanQRFromPickerResults:(NSArray<PHPickerResult *> *)results index:(NSUInteger)index collected:(NSMutableArray<NSString *> *)codes API_AVAILABLE(ios(14.0)) {
    if (index >= results.count) {
        NSString *message = codes.count ? [codes componentsJoinedByString:@"\n\n"] : @"Không tìm thấy mã QR trong các ảnh đã chọn.";
        NSString *summary = [NSString stringWithFormat:@"Đã quét %lu ảnh.\nTìm thấy %lu mã QR.\n\n%@", (unsigned long)results.count, (unsigned long)codes.count, message];
        dispatch_async(dispatch_get_main_queue(), ^{ [self showMessage:summary]; });
        return;
    }
    NSItemProvider *provider = results[index].itemProvider;
    if (![provider canLoadObjectOfClass:UIImage.class]) {
        [self scanQRFromPickerResults:results index:index+1 collected:codes];
        return;
    }
    [provider loadObjectOfClass:UIImage.class completionHandler:^(id<NSItemProviderReading> object, NSError *error) {
        if (!error && [object isKindOfClass:UIImage.class]) {
            UIImage *image = (UIImage *)object;
            VNDetectBarcodesRequest *request = [VNDetectBarcodesRequest new];
            request.symbologies = @[VNBarcodeSymbologyQR];
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
            [handler performRequests:@[request] error:nil];
            for (VNBarcodeObservation *item in request.results) {
                if (item.payloadStringValue.length && ![codes containsObject:item.payloadStringValue]) [codes addObject:item.payloadStringValue];
            }
        }
        [self scanQRFromPickerResults:results index:index+1 collected:codes];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    NSString *purpose = objc_getAssociatedObject(picker, @selector(picker:didFinishPicking:));
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        if (image && [purpose isEqualToString:@"qr"]) {
            VNDetectBarcodesRequest *request = [VNDetectBarcodesRequest new];
            request.symbologies = @[VNBarcodeSymbologyQR];
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
            [handler performRequests:@[request] error:nil];
            NSMutableArray *values = [NSMutableArray array];
            for (VNBarcodeObservation *item in request.results) if (item.payloadStringValue.length) [values addObject:item.payloadStringValue];
            [self showMessage:values.count ? [values componentsJoinedByString:@"\n\n"] : @"Không tìm thấy mã QR."];
        } else if (image) {
            NSString *message = [purpose isEqualToString:@"replace"]
                ? @"Đã chọn ảnh. Tự động thay asset trong timeline cần API project Video Star."
                : @"Đã chọn ảnh. Tự động chèn vào timeline cần API project Video Star.";
            [self showImage:image message:message];
        } else {
            [self showMessage:@"Không đọc được ảnh đã chọn."];
        }
    }];
}

- (void)showImage:(UIImage *)image message:(NSString *)message {
    CGSize px = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
    [self showMessage:[NSString stringWithFormat:@"%@\n\nImage: %.0f × %.0f px", message, px.width, px.height]];
}

- (void)showMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.viewIfLoaded.window) return;
        UIViewController *presenter = self;
        while (presenter.presentedViewController && !presenter.presentedViewController.isBeingDismissed) {
            presenter = presenter.presentedViewController;
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DOXBON VDS" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [presenter presentViewController:alert animated:YES completion:nil];
    });
}


- (NSString *)maskedKey {
    if (self.activeKey.length < 7) return @"••••••";
    return [NSString stringWithFormat:@"%@••••%@",
            [self.activeKey substringToIndex:3],
            [self.activeKey substringFromIndex:self.activeKey.length-3]];
}

- (void)recheckKey {
    NSString *key = self.activeKey;
    if (key.length == 0) {
        [self showLogin];
        return;
    }

    [self showLogin];
    self.keyField.text = key;
    [self validateKey];
}

- (void)logout {
    self.activeKey = nil;
    self.expiryText = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DBSavedLicenseKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showLogin];
}

- (void)openMenu {
    self.panel.hidden = NO;
    self.floatingButton.hidden = YES;
}

- (void)closeMenu {
    self.panel.hidden = YES;
    self.floatingButton.hidden = NO;
}

@end

static UIWindow *DBWindow;

static void DBPresentMenu(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (DBWindow && DBWindow.rootViewController) return;

        UIWindowScene *scene = nil;
        for (UIScene *s in UIApplication.sharedApplication.connectedScenes) {
            if (s.activationState == UISceneActivationStateForegroundActive &&
                [s isKindOfClass:UIWindowScene.class]) {
                scene = (UIWindowScene *)s;
                break;
            }
        }

        if (!scene) return;

        DBWindow = [[DBPassthroughWindow alloc] initWithWindowScene:scene];
        DBWindow.frame = scene.coordinateSpace.bounds;
        DBWindow.windowLevel = UIWindowLevelNormal + 1;
        DBWindow.backgroundColor = UIColor.clearColor;
        DBWindow.userInteractionEnabled = YES;

        UIViewController *root = [UIViewController new];
        root.view.backgroundColor = UIColor.clearColor;
        DBWindow.rootViewController = root;

        DBMenuController *menu = [DBMenuController new];
        [root addChildViewController:menu];
        menu.view.frame = root.view.bounds;
        menu.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [root.view addSubview:menu.view];
        [menu didMoveToParentViewController:root];

        DBWindow.hidden = NO;
    });
}

__attribute__((constructor))
static void DoxBonLoad(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
            addObserverForName:UIApplicationDidBecomeActiveNotification
            object:nil
            queue:NSOperationQueue.mainQueue
            usingBlock:^(__unused NSNotification *n) {
                DBPresentMenu();
            }];

        DBPresentMenu();
    });
}
