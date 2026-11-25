#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#import <Vision/Vision.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>

static NSString * const DBLicenseActivateEndpoint = @"https://hhabjbw-001-site1.ktempurl.com/api/license/activate";
static NSString * const DBLicenseValidateEndpoint = @"https://hhabjbw-001-site1.ktempurl.com/api/license/validate";
static NSString * const DBTikTok = @"@tuatbonxyz";
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
@end

@interface DBPassthroughView : UIView
@end

@implementation DBPassthroughView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    return hit == self ? nil : hit;
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
}

- (void)buildPanel {
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,360)];
    self.panel.center = self.view.center;
    self.panel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.panel.backgroundColor = [UIColor colorWithRed:0.055 green:0.035 blue:0.105 alpha:0.97];
    self.panel.layer.cornerRadius = 22;
    self.panel.layer.borderWidth = 1.5;
    self.panel.layer.borderColor = [UIColor colorWithRed:0.65 green:0.28 blue:1 alpha:1].CGColor;
    self.panel.layer.shadowColor = [UIColor purpleColor].CGColor;
    self.panel.layer.shadowOpacity = .55;
    self.panel.layer.shadowRadius = 18;
    [self.view addSubview:self.panel];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(18,12,240,34)];
    title.text = @"♛  DOXBON VIP";
    title.font = [UIFont boldSystemFontOfSize:21];
    title.textColor = [UIColor colorWithRed:.82 green:.62 blue:1 alpha:1];
    [self.panel addSubview:title];

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.frame = CGRectMake(278,10,30,30);
    [close setTitle:@"×" forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont boldSystemFontOfSize:25];
    [close setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [close addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:close];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragPanel:)];
    [title addGestureRecognizer:pan];
    title.userInteractionEnabled = YES;

    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(14,55,292,290)];
    [self.panel addSubview:self.contentView];

    // Floating launcher remains available after the panel is closed.
    self.floatingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.floatingButton.frame = CGRectMake(18, 115, 58, 58);
    self.floatingButton.layer.cornerRadius = 29;
    self.floatingButton.backgroundColor = [UIColor colorWithRed:.28 green:.10 blue:.48 alpha:.96];
    self.floatingButton.layer.borderWidth = 1.5;
    self.floatingButton.layer.borderColor = [UIColor colorWithRed:.72 green:.40 blue:1 alpha:1].CGColor;
    self.floatingButton.layer.shadowColor = UIColor.purpleColor.CGColor;
    self.floatingButton.layer.shadowOpacity = .65;
    self.floatingButton.layer.shadowRadius = 10;
    [self.floatingButton setTitle:@"DB" forState:UIControlStateNormal];
    [self.floatingButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.floatingButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.floatingButton addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.floatingButton];
    self.floatingButton.hidden = YES;
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
    b.backgroundColor = [UIColor colorWithRed:.28 green:.10 blue:.48 alpha:1];
    b.layer.cornerRadius = 12;
    b.layer.borderWidth = 1;
    b.layer.borderColor = [UIColor colorWithRed:.68 green:.38 blue:1 alpha:.8].CGColor;
    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [b addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:b];
    return b;
}

- (void)showLogin {
    for (UIView *v in self.contentView.subviews) [v removeFromSuperview];

    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(4,12,284,34)];
    hint.text = @"Nhập VIP Key để tiếp tục";
    hint.textColor = UIColor.whiteColor;
    hint.textAlignment = NSTextAlignmentCenter;
    hint.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [self.contentView addSubview:hint];

    self.keyField = [[UITextField alloc] initWithFrame:CGRectMake(8,66,276,46)];
    self.keyField.placeholder = @"DB-XXXX-XXXX";
    self.keyField.textColor = UIColor.whiteColor;
    self.keyField.tintColor = UIColor.purpleColor;
    self.keyField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.keyField.borderStyle = UITextBorderStyleRoundedRect;
    self.keyField.backgroundColor = [UIColor colorWithWhite:1 alpha:.10];
    self.keyField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"DB-XXXX-XXXX"
        attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:.55]}];
    [self.contentView addSubview:self.keyField];

    [self button:@"XÁC NHẬN KEY" frame:CGRectMake(8,128,276,46) action:@selector(validateKey)];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,184,276,44)];
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

- (void)showDashboardWithExpiry:(NSString *)expiry {
    for (UIView *v in self.contentView.subviews) [v removeFromSuperview];

    [self button:@"CHỨC NĂNG" frame:CGRectMake(0,0,140,38) action:@selector(showFeatures)];
    [self button:@"CÀI ĐẶT" frame:CGRectMake(150,0,140,38) action:@selector(showSettings)];

    UILabel *welcome = [[UILabel alloc] initWithFrame:CGRectMake(0,54,290,42)];
    welcome.text = @"✦  DoxBon VIP đã kích hoạt";
    welcome.textColor = [UIColor colorWithRed:.55 green:1 blue:.72 alpha:1];
    welcome.textAlignment = NSTextAlignmentCenter;
    welcome.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:welcome];

    self.expiryText = expiry ?: @"Không xác định";
    [self showFeatures];
}

- (void)clearDashboardContent {
    for (UIView *v in [self.contentView.subviews copy]) {
        if (v.frame.origin.y >= 48) [v removeFromSuperview];
    }
}

- (void)showFeatures {
    [self clearDashboardContent];

    [self button:@"BATCH QR  ·  Quét QR từ nhiều ảnh" frame:CGRectMake(5,58,280,48) action:@selector(startBatchQR)];
    [self button:@"REPLACE MEDIA  ·  Chọn media thay thế" frame:CGRectMake(5,116,280,48) action:@selector(startReplaceMedia)];
    [self button:@"ONE-TOUCH MEDIA  ·  Chọn media nhanh" frame:CGRectMake(5,174,280,48) action:@selector(startOneTouchMedia)];

    UILabel *note = [[UILabel alloc] initWithFrame:CGRectMake(5,232,280,42)];
    note.text = @"Batch QR quét mã QR trong ảnh đã chọn. Chọn media mở thư viện; việc thay asset trong project cần API nội bộ Video Star.";
    note.textColor = [UIColor colorWithWhite:1 alpha:.62];
    note.font = [UIFont systemFontOfSize:10];
    note.numberOfLines = 3;
    note.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:note];
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
        [self showMessage:[NSString stringWithFormat:@"Đã quét %lu ảnh.\n\n%@", (unsigned long)results.count, message]];
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
                if (item.payloadStringValue.length && ![codes containsObject:item.payloadStringValue]) {
                    [codes addObject:item.payloadStringValue];
                }
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
        if (!image) {
            [self showMessage:@"Không đọc được ảnh đã chọn. Bản hiện tại chỉ xử lý ảnh; chưa tự chèn video vào project Video Star."];
            return;
        }
        if ([purpose isEqualToString:@"qr"]) {
            VNDetectBarcodesRequest *request = [VNDetectBarcodesRequest new];
            request.symbologies = @[VNBarcodeSymbologyQR];
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
            NSError *error = nil;
            [handler performRequests:@[request] error:&error];
            NSMutableArray<NSString *> *codes = [NSMutableArray array];
            for (VNBarcodeObservation *item in request.results) {
                if (item.payloadStringValue.length && ![codes containsObject:item.payloadStringValue]) {
                    [codes addObject:item.payloadStringValue];
                }
            }
            NSString *result = error ? @"Không thể quét QR trong ảnh." :
                (codes.count ? [codes componentsJoinedByString:@"\\n\\n"] : @"Không tìm thấy mã QR.");
            [self showMessage:result];
        } else {
            NSString *message = [purpose isEqualToString:@"replace"]
                ? @"Đã chọn ảnh. Tự động thay asset trong timeline cần API project của Video Star."
                : @"Đã chọn ảnh. Tự động chèn vào project cần API project của Video Star.";
            [self showImage:image message:message];
        }
    }];
}

- (void)showImage:(UIImage *)image message:(NSString *)message {
    CGSize size = image.size;
    NSString *details = [NSString stringWithFormat:@"%@\\n\\nKích thước ảnh: %.0f × %.0f px",
                         message, size.width * image.scale, size.height * image.scale];
    [self showMessage:details];
}

- (void)showMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.viewIfLoaded.window) return;
        UIViewController *presenter = self;
        while (presenter.presentedViewController && !presenter.presentedViewController.isBeingDismissed) {
            presenter = presenter.presentedViewController;
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DoxBon VDS"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [presenter presentViewController:alert animated:YES completion:nil];
    });
}

- (void)showSettings {
    [self clearDashboardContent];

    NSArray *lines = @[
        [NSString stringWithFormat:@"TikTok: %@", DBTikTok],
        [NSString stringWithFormat:@"Zalo: %@", DBZalo],
        [NSString stringWithFormat:@"Hạn sử dụng: %@", self.expiryText ?: @"Không xác định"],
        [NSString stringWithFormat:@"Key: %@", [self maskedKey]]
    ];

    CGFloat y = 58;
    for (NSString *line in lines) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5,y,280,34)];
        label.text = line;
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:label];
        y += 38;
    }

    [self button:@"KIỂM TRA KEY LẠI" frame:CGRectMake(5,218,135,38) action:@selector(recheckKey)];
    [self button:@"ĐĂNG XUẤT" frame:CGRectMake(150,218,135,38) action:@selector(logout)];
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

        DBWindow = [[UIWindow alloc] initWithWindowScene:scene];
        DBWindow.frame = scene.coordinateSpace.bounds;
        DBWindow.windowLevel = UIWindowLevelAlert - 1;

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
