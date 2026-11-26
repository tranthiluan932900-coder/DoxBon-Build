// DoxBon VDS Tool — source replacement
// Target: iOS 14+ / Objective-C / arm64
// IMPORTANT: QR pairing and export queue are implemented locally.
// Automatic insertion/export inside Video Star is NOT enabled until its private
// method signatures and owning classes are verified against the target build.

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#import <Vision/Vision.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import <math.h>

static NSString * const DBLicenseActivateEndpoint = @"https://hhabjbw-001-site1.ktempurl.com/api/license/activate";
static NSString * const DBLicenseValidateEndpoint = @"https://hhabjbw-001-site1.ktempurl.com/api/license/validate";
static NSString * const DBTikTok = @"@tuatbonxyz";
static NSString * const DBZalo = @"0854582858";
static NSString * const DBSavedLicenseKey = @"com.doxbon.vds.savedLicenseKey";
static NSString * const DBFloatingButtonPositionKey = @"com.doxbon.vds.floatingButtonPosition";
static NSString * const DBQRJobsKey = @"com.doxbon.vds.qrJobs.v1";

@interface DBPassthroughView : UIView @end
@implementation DBPassthroughView
- (UIView *)hitTest:(CGPoint)p withEvent:(UIEvent *)e {
    UIView *v = [super hitTest:p withEvent:e];
    return v == self ? nil : v;
}
@end

@interface DBPassthroughWindow : UIWindow @end
@implementation DBPassthroughWindow
- (UIView *)hitTest:(CGPoint)p withEvent:(UIEvent *)e {
    UIView *v = [super hitTest:p withEvent:e];
    if (v == self.rootViewController.view) return nil;
    return v;
}
@end

@interface DBMenuController : UIViewController <PHPickerViewControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic,strong) UIView *panel;
@property(nonatomic,strong) UIScrollView *content;
@property(nonatomic,strong) UIButton *floating;
@property(nonatomic,strong) UILabel *status;
@property(nonatomic,strong) UITextField *keyField;
@property(nonatomic,strong) NSString *activeKey;
@property(nonatomic,strong) NSString *expiryText;
@property(nonatomic,strong) NSArray<UIButton *> *tabs;
@property(nonatomic,strong) NSMutableArray<NSMutableDictionary *> *jobs;
@property(nonatomic) NSInteger exportIndex;
@property(nonatomic,strong) NSString *pickerPurpose;
@end

@implementation DBMenuController

- (void)loadView {
    self.view = [[DBPassthroughView alloc] initWithFrame:UIScreen.mainScreen.bounds];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    self.jobs = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:DBQRJobsKey] ?: @[]];
    [self buildUI];
    [self showLogin];
    [self restoreKey];
}
- (UIColor *)purple { return [UIColor colorWithRed:.43 green:.12 blue:.82 alpha:1]; }
- (void)buildUI {
    CGFloat sw = CGRectGetWidth(UIScreen.mainScreen.bounds), sh = CGRectGetHeight(UIScreen.mainScreen.bounds);
    CGFloat w = MIN(354, sw-24), h = MIN(470, sh-90);
    self.panel = [[UIView alloc] initWithFrame:CGRectMake((sw-w)/2, (sh-h)/2, w, h)];
    self.panel.backgroundColor = [UIColor colorWithRed:.025 green:.02 blue:.09 alpha:.985];
    self.panel.layer.cornerRadius = 24; self.panel.layer.borderWidth = 1.5;
    self.panel.layer.borderColor = [self purple].CGColor; self.panel.clipsToBounds = YES;
    CAGradientLayer *g = [CAGradientLayer layer]; g.frame = self.panel.bounds;
    g.colors = @[(id)[UIColor colorWithRed:.13 green:.025 blue:.25 alpha:1].CGColor,
                 (id)[UIColor colorWithRed:.018 green:.025 blue:.10 alpha:1].CGColor];
    g.cornerRadius = 24; [self.panel.layer insertSublayer:g atIndex:0];
    [self.view addSubview:self.panel];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16,12,w-70,25)];
    title.text = @"★  DOXBON / VDS TOOL"; title.textColor = [UIColor colorWithRed:.82 green:.62 blue:1 alpha:1];
    title.font = [UIFont boldSystemFontOfSize:15]; [self.panel addSubview:title];
    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem]; close.frame = CGRectMake(w-43,10,32,32);
    [close setTitle:@"×" forState:UIControlStateNormal]; close.titleLabel.font = [UIFont systemFontOfSize:25];
    [close setTitleColor:UIColor.whiteColor forState:UIControlStateNormal]; [close addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:close];
    UIPanGestureRecognizer *movePanel = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    [title addGestureRecognizer:movePanel]; title.userInteractionEnabled = YES;

    UIScrollView *bar = [[UIScrollView alloc] initWithFrame:CGRectMake(10,50,w-20,42)];
    bar.scrollEnabled = NO; bar.backgroundColor = [UIColor colorWithWhite:1 alpha:.05]; bar.layer.cornerRadius = 13;
    [self.panel addSubview:bar];
    NSArray *names = @[@"HOME",@"QR LAB",@"MEDIA",@"SETTINGS",@"INFO"];
    NSMutableArray *bs = [NSMutableArray array];
    CGFloat bw = (w-26)/5.0;
    for (NSInteger i=0;i<5;i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem]; b.frame = CGRectMake(3+i*bw,3,bw-2,36);
        b.tag=i; b.layer.cornerRadius=10; b.titleLabel.font=[UIFont boldSystemFontOfSize:9];
        [b setTitle:names[i] forState:UIControlStateNormal]; [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [b addTarget:self action:@selector(tab:) forControlEvents:UIControlEventTouchUpInside]; [bar addSubview:b]; [bs addObject:b];
    }
    self.tabs=bs;
    self.content=[[UIScrollView alloc] initWithFrame:CGRectMake(12,101,w-24,h-112)];
    self.content.showsVerticalScrollIndicator=NO; self.content.alwaysBounceVertical=YES;
    [self.panel addSubview:self.content];

    self.floating=[UIButton buttonWithType:UIButtonTypeSystem]; self.floating.frame=CGRectMake(16,sh*.35,52,52);
    self.floating.layer.cornerRadius=26; self.floating.backgroundColor=[self purple];
    self.floating.layer.borderWidth=1.5; self.floating.layer.borderColor=[UIColor colorWithRed:.8 green:.4 blue:1 alpha:1].CGColor;
    [self.floating setTitle:@"♛\nDB" forState:UIControlStateNormal]; [self.floating setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.floating.titleLabel.font=[UIFont boldSystemFontOfSize:13]; self.floating.titleLabel.numberOfLines=2;
    [self.floating addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.floating];
    UIPanGestureRecognizer *drag=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragFloating:)];
    [self.floating addGestureRecognizer:drag];
    NSString *saved=[[NSUserDefaults standardUserDefaults] stringForKey:DBFloatingButtonPositionKey];
    if(saved.length){ CGPoint p=CGPointFromString(saved); if(isfinite(p.x)&&isfinite(p.y)&&!CGPointEqualToPoint(p,CGPointZero)) self.floating.center=p; }
    self.floating.hidden=YES;
}
- (void)viewDidLayoutSubviews { [super viewDidLayoutSubviews]; }
- (void)movePanel:(UIPanGestureRecognizer *)g {
    CGPoint d=[g translationInView:self.view]; self.panel.center=CGPointMake(self.panel.center.x+d.x,self.panel.center.y+d.y);
    [g setTranslation:CGPointZero inView:self.view];
}
- (void)dragFloating:(UIPanGestureRecognizer *)g {
    CGPoint d=[g translationInView:self.view], c=self.floating.center; c.x+=d.x; c.y+=d.y;
    CGFloat x=self.floating.bounds.size.width/2, y=self.floating.bounds.size.height/2;
    c.x=MIN(MAX(x,c.x),self.view.bounds.size.width-x); c.y=MIN(MAX(y,c.y),self.view.bounds.size.height-y);
    self.floating.center=c; [g setTranslation:CGPointZero inView:self.view];
    if(g.state==UIGestureRecognizerStateEnded || g.state==UIGestureRecognizerStateCancelled)
        [[NSUserDefaults standardUserDefaults] setObject:NSStringFromCGPoint(c) forKey:DBFloatingButtonPositionKey];
}
- (void)openMenu { self.panel.hidden=NO; self.floating.hidden=YES; }
- (void)closeMenu { self.panel.hidden=YES; self.floating.hidden=NO; }
- (void)clear { for(UIView *v in [self.content.subviews copy]) [v removeFromSuperview]; self.content.contentOffset=CGPointZero; }
- (UILabel *)label:(NSString *)s y:(CGFloat)y height:(CGFloat)h {
    UILabel *l=[[UILabel alloc] initWithFrame:CGRectMake(6,y,self.content.bounds.size.width-12,h)];
    l.text=s; l.textColor=UIColor.whiteColor; l.font=[UIFont systemFontOfSize:11 weight:UIFontWeightMedium]; l.numberOfLines=0;
    [self.content addSubview:l]; return l;
}
- (UIButton *)button:(NSString *)s y:(CGFloat)y action:(SEL)a {
    UIButton *b=[UIButton buttonWithType:UIButtonTypeSystem]; b.frame=CGRectMake(5,y,self.content.bounds.size.width-10,42);
    b.backgroundColor=[self purple]; b.layer.cornerRadius=13; b.layer.borderWidth=1;
    b.layer.borderColor=[UIColor colorWithRed:.75 green:.42 blue:1 alpha:1].CGColor;
    [b setTitle:s forState:UIControlStateNormal]; [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    b.titleLabel.font=[UIFont boldSystemFontOfSize:11]; [b addTarget:self action:a forControlEvents:UIControlEventTouchUpInside];
    [self.content addSubview:b]; return b;
}
- (void)finish:(CGFloat)y { self.content.contentSize=CGSizeMake(self.content.bounds.size.width,MAX(y+12,self.content.bounds.size.height+1)); }
- (void)tab:(UIButton *)b {
    switch(b.tag){case 0:[self home];break;case 1:[self qrPage];break;case 2:[self mediaPage];break;case 3:[self settings];break;case 4:[self info];break;}
}
- (void)home {
    [self clear]; CGFloat w=self.content.bounds.size.width;
    [self label:@"DOXBON VIP CONTROL CENTER" y:5 height:25];
    [self label:[NSString stringWithFormat:@"License: %@  •  %@",self.activeKey?@"ACTIVE":@"NOT ACTIVE",self.expiryText?:@"—"] y:32 height:25];
    [self button:@"QR LAB — QUÉT VÀ GHÉP QR / CLIP" y:68 action:@selector(qrPage)];
    [self button:@"ONE TOUCH — CHỌN ẢNH" y:118 action:@selector(oneTouch)];
    [self button:@"REPLACE MEDIA — CHỌN VIDEO / ẢNH" y:168 action:@selector(replaceMedia)];
    [self button:@"SEQUENTIAL EXPORT QUEUE" y:218 action:@selector(exportPage)];
    [self label:@"Lưu ý: thao tác chèn/thay clip và lệnh export bên trong Video Star chưa được gọi vì cần xác minh API private của đúng phiên bản app." y:270 height:65];
    [self finish:345];
}
- (void)qrPage {
    [self clear]; [self label:@"QR LAB" y:4 height:24];
    [self label:@"Bước 1: chọn ảnh chứa QR. Bước 2: chọn video gán cho từng QR trong danh sách." y:30 height:45];
    [self button:@"1. QUÉT ẢNH QR (TỐI ĐA 30)" y:82 action:@selector(scanQR)];
    [self button:@"2. GÁN VIDEO CHO QR" y:132 action:@selector(assignVideos)];
    [self button:@"3. XEM HÀNG ĐỢI XUẤT" y:182 action:@selector(exportPage)];
    CGFloat y=238;
    for(NSDictionary *j in self.jobs){
        NSString *qr=j[@"qr"]?:@"(QR)";
        NSString *clip=j[@"clipName"]?:@"Chưa gán clip";
        [self label:[NSString stringWithFormat:@"QR: %@\nClip: %@\n%@",qr,clip,[j[@"done"] boolValue]?@"ĐÃ ĐÁNH DẤU XUẤT":@"CHỜ XUẤT"] y:y height:54]; y+=58;
    }
    [self finish:y];
}
- (void)mediaPage {
    [self clear]; [self label:@"MEDIA TOOLS" y:5 height:24];
    [self label:@"Chọn asset để chuẩn bị. Bản này chưa tự thay asset trong project Video Star." y:32 height:45];
    [self button:@"ONE TOUCH — CHỌN ẢNH" y:88 action:@selector(oneTouch)];
    [self button:@"REPLACE MEDIA — CHỌN VIDEO / ẢNH" y:138 action:@selector(replaceMedia)];
    [self finish:200];
}
- (void)settings {
    [self clear]; [self label:@"SETTINGS" y:5 height:24];
    [self label:[NSString stringWithFormat:@"TikTok: %@\nZalo: %@\nKey: %@\nExpiry: %@",DBTikTok,DBZalo,self.activeKey?:@"—",self.expiryText?:@"—"] y:35 height:85];
    [self button:@"CHECK / RE-AUTHENTICATE KEY" y:128 action:@selector(recheck)];
    [self button:@"LOG OUT" y:178 action:@selector(logout)];
    [self finish:235];
}
- (void)info {
    [self clear]; [self label:@"DOXBON VDS TOOL\nPURPLE NEON EDITION\n\nQR scan: Apple Vision\nQR ↔ clip mapping: local persistent queue\nExport queue: sequential manual confirmation\nTimeline hooks: disabled pending runtime signature verification." y:5 height:180]; [self finish:200];
}
- (void)showAlert:(NSString *)s {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *p=self; while(p.presentedViewController) p=p.presentedViewController;
        UIAlertController *a=[UIAlertController alertControllerWithTitle:@"DOXBON VDS" message:s preferredStyle:UIAlertControllerStyleAlert];
        [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [p presentViewController:a animated:YES completion:nil];
    });
}
- (void)saveJobs {
    [[NSUserDefaults standardUserDefaults] setObject:self.jobs forKey:DBQRJobsKey];
}
- (void)presentPicker:(NSString *)purpose filter:(PHPickerFilter *)filter limit:(NSInteger)limit {
    PHPickerConfiguration *c=[[PHPickerConfiguration alloc] init]; c.filter=filter; c.selectionLimit=limit;
    PHPickerViewController *p=[[PHPickerViewController alloc] initWithConfiguration:c]; p.delegate=self;
    self.pickerPurpose=purpose; [self presentViewController:p animated:YES completion:nil];
}
- (void)scanQR { [self presentPicker:@"qr" filter:PHPickerFilter.imagesFilter limit:30]; }
- (void)assignVideos {
    if(!self.jobs.count){[self showAlert:@"Hãy quét QR trước."];return;}
    [self presentPicker:@"videos" filter:PHPickerFilter.videosFilter limit:30];
}
- (void)oneTouch { [self presentPicker:@"image" filter:PHPickerFilter.imagesFilter limit:1]; }
- (void)replaceMedia { [self presentPicker:@"replace" filter:[PHPickerFilter anyFilterMatchingSubfilters:@[PHPickerFilter.imagesFilter,PHPickerFilter.videosFilter]] limit:1]; }
- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14.0)) {
    NSString *purpose=self.pickerPurpose; [picker dismissViewControllerAnimated:YES completion:^{
        if(!results.count)return;
        if([purpose isEqual:@"qr"]){ [self scanResults:results index:0]; return; }
        if([purpose isEqual:@"videos"]){ [self loadVideoResults:results index:0]; return; }
        NSItemProvider *p=results.firstObject.itemProvider;
        if([p canLoadObjectOfClass:UIImage.class]){
            [p loadObjectOfClass:UIImage.class completionHandler:^(id obj,NSError *e){
                dispatch_async(dispatch_get_main_queue(),^{ [self showAlert:e?@"Không đọc được asset.":([purpose isEqual:@"image"]?@"Đã chọn ảnh. Chưa chèn tự động vào timeline.":@"Đã chọn media. Chưa thay tự động trong timeline.")]; });
            }];
        } else [self showAlert:@"Định dạng chưa hỗ trợ."];
    }];
}
- (void)scanResults:(NSArray<PHPickerResult *> *)r index:(NSUInteger)i {
    if(i>=r.count){[self saveJobs];[self qrPage];[self showAlert:[NSString stringWithFormat:@"Đã quét xong. Tìm thấy %lu QR.",(unsigned long)self.jobs.count]];return;}
    NSItemProvider *p=r[i].itemProvider;
    if(![p canLoadObjectOfClass:UIImage.class]){[self scanResults:r index:i+1];return;}
    [p loadObjectOfClass:UIImage.class completionHandler:^(id obj,NSError *e){
        if(!e && [obj isKindOfClass:UIImage.class]){
            UIImage *im=obj;
            VNDetectBarcodesRequest *req=[VNDetectBarcodesRequest new]; req.symbologies=@[VNBarcodeSymbologyQR];
            VNImageRequestHandler *h=[[VNImageRequestHandler alloc] initWithCGImage:im.CGImage options:@{}];
            [h performRequests:@[req] error:nil];
            for(VNBarcodeObservation *o in req.results){
                NSString *code=o.payloadStringValue;
                if(code.length){
                    BOOL exists=NO; for(NSDictionary *j in self.jobs) if([j[@"qr"] isEqual:code]){exists=YES;break;}
                    if(!exists)[self.jobs addObject:[@{@"qr":code,@"clipName":@"",@"clipID":@"",@"done":@NO} mutableCopy]];
                }
            }
        }
        [self scanResults:r index:i+1];
    }];
}
- (void)loadVideoResults:(NSArray<PHPickerResult *> *)r index:(NSUInteger)i {
    if(i>=r.count){[self saveJobs];[self qrPage];[self showAlert:@"Đã lưu các clip đã chọn vào danh sách. Hãy kiểm tra thứ tự ghép QR–clip."];return;}
    if(i>=self.jobs.count){[self showAlert:@"Số video nhiều hơn số QR. Những video dư chưa được gán."];return;}
    NSItemProvider *p=r[i].itemProvider;
    if([p hasItemConformingToTypeIdentifier:@"public.movie"]){
        [p loadFileRepresentationForTypeIdentifier:@"public.movie" completionHandler:^(NSURL *url,NSError *e){
            NSString *name=url.lastPathComponent?:[NSString stringWithFormat:@"Video %lu",(unsigned long)i+1];
            NSString *identifier=r[i].assetIdentifier?:[[NSUUID UUID] UUIDString];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableDictionary *j=self.jobs[i];
                j[@"clipName"]=name; j[@"clipID"]=identifier; j[@"done"]=@NO;
                [self loadVideoResults:r index:i+1];
            });
        }];
    } else [self loadVideoResults:r index:i+1];
}
- (void)exportPage {
    [self clear]; [self label:@"SEQUENTIAL EXPORT" y:5 height:24];
    [self label:@"Xuất từng clip trong Video Star theo thứ tự QR. Sau khi tự xuất xong một clip, bấm nút bên dưới để chuyển sang clip tiếp theo. Nút này không giả lập lệnh export của Video Star." y:32 height:70];
    NSInteger next=-1; for(NSInteger i=0;i<(NSInteger)self.jobs.count;i++) if(![self.jobs[i][@"done"] boolValue]){next=i;break;}
    if(next<0){[self label:@"Không còn clip chờ xuất. Hãy quét QR và gán video mới." y:112 height:40];[self finish:165];return;}
    self.exportIndex=next;
    NSDictionary *j=self.jobs[next];
    [self label:[NSString stringWithFormat:@"CLIP %ld / %lu\nQR: %@\nVideo: %@",(long)next+1,(unsigned long)self.jobs.count,j[@"qr"],[j[@"clipName"] length]?j[@"clipName"]:@"Chưa gán video"] y:112 height:75];
    [self button:@"ĐÁNH DẤU ĐÃ XUẤT — CLIP TIẾP THEO" y:198 action:@selector(markExported)];
    [self button:@"LÀM LẠI HÀNG ĐỢI (RESET)" y:248 action:@selector(resetExport)];
    [self finish:310];
}
- (void)markExported {
    if(self.exportIndex<0 || self.exportIndex>=self.jobs.count)return;
    self.jobs[self.exportIndex][@"done"]=@YES; [self saveJobs]; [self exportPage];
}
- (void)resetExport { for(NSMutableDictionary *j in self.jobs) j[@"done"]=@NO; [self saveJobs]; [self exportPage]; }

#pragma mark - VIP license
- (void)request:(NSString *)url key:(NSString *)key completion:(void (^)(NSDictionary *,NSError *))done {
    NSMutableURLRequest *r=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    r.HTTPMethod=@"POST"; r.timeoutInterval=20; [r setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    r.HTTPBody=[NSJSONSerialization dataWithJSONObject:@{@"key":key,@"device_id":UIDevice.currentDevice.identifierForVendor.UUIDString?:@"unknown-device"} options:0 error:nil];
    [[[NSURLSession sharedSession] dataTaskWithRequest:r completionHandler:^(NSData *d,NSURLResponse *resp,NSError *e){
        id o=d.length?[NSJSONSerialization JSONObjectWithData:d options:0 error:nil]:nil;
        done([o isKindOfClass:NSDictionary.class]?o:nil,e);
    }] resume];
}
- (void)showLogin {
    [self clear]; self.panel.hidden=NO; self.floating.hidden=YES;
    [self label:@"Nhập VIP Key để tiếp tục" y:20 height:28];
    self.keyField=[[UITextField alloc] initWithFrame:CGRectMake(7,57,self.content.bounds.size.width-14,42)];
    self.keyField.placeholder=@"DB-XXXX-XXXX"; self.keyField.textColor=UIColor.whiteColor;
    self.keyField.backgroundColor=[UIColor colorWithWhite:1 alpha:.12]; self.keyField.borderStyle=UITextBorderStyleRoundedRect;
    self.keyField.autocapitalizationType=UITextAutocapitalizationTypeAllCharacters; [self.content addSubview:self.keyField];
    [self button:@"XÁC NHẬN KEY" y:111 action:@selector(validateKey)];
    self.status=[[UILabel alloc] initWithFrame:CGRectMake(8,164,self.content.bounds.size.width-16,55)];
    self.status.textColor=UIColor.whiteColor; self.status.font=[UIFont systemFontOfSize:11]; self.status.numberOfLines=0;
    [self.content addSubview:self.status]; [self finish:235];
}
- (void)validateKey {
    NSString *key=[[self.keyField.text?:@"" stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] uppercaseString];
    if(key.length<8){self.status.text=@"Vui lòng nhập VIP Key hợp lệ.";return;}
    self.status.text=@"Đang xác thực...";
    [self request:DBLicenseActivateEndpoint key:key completion:^(NSDictionary *a,NSError *e){
        if(e || ![a[@"ok"] boolValue]){dispatch_async(dispatch_get_main_queue(),^{self.status.text=e?@"Không kết nối được máy chủ.":(a[@"error"]?:@"Kích hoạt thất bại.");});return;}
        [self request:DBLicenseValidateEndpoint key:key completion:^(NSDictionary *v,NSError *ve){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!ve && [v[@"ok"] boolValue] && [v[@"status"] isEqual:@"active"]){
                    self.activeKey=key; [[NSUserDefaults standardUserDefaults] setObject:key forKey:DBSavedLicenseKey];
                    id exp=v[@"expires_at"]; self.expiryText=([exp respondsToSelector:@selector(longLongValue)] && [exp longLongValue]>0)?[NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:[exp longLongValue]] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]:@"Vĩnh viễn";
                    [self home];
                } else self.status.text=ve?@"Không kết nối được máy chủ.":(v[@"error"]?:@"Key không hợp lệ hoặc hết hạn.");
            });
        }];
    }];
}
- (void)restoreKey {
    NSString *k=[[NSUserDefaults standardUserDefaults] stringForKey:DBSavedLicenseKey]; if(k.length<8)return;
    self.keyField.text=k; self.status.text=@"Đang kiểm tra key đã lưu...";
    [self request:DBLicenseValidateEndpoint key:k completion:^(NSDictionary *v,NSError *e){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!e && [v[@"ok"] boolValue] && [v[@"status"] isEqual:@"active"]){
                self.activeKey=k; id exp=v[@"expires_at"];
                self.expiryText=([exp respondsToSelector:@selector(longLongValue)] && [exp longLongValue]>0)?[NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:[exp longLongValue]] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]:@"Vĩnh viễn";
                [self home];
            } else if(!e){[[NSUserDefaults standardUserDefaults] removeObjectForKey:DBSavedLicenseKey];self.status.text=@"Key đã hết hạn hoặc không hợp lệ.";}
            else self.status.text=@"Mất kết nối. Key vẫn được giữ để thử lại.";
        });
    }];
}
- (void)recheck { if(!self.activeKey.length){[self showLogin];return;} self.keyField.text=self.activeKey; [self validateKey]; }
- (void)logout { self.activeKey=nil; self.expiryText=nil; [[NSUserDefaults standardUserDefaults] removeObjectForKey:DBSavedLicenseKey]; [self showLogin]; }
@end

static DBPassthroughWindow *DBWindow;
static void DBPresentMenu(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(DBWindow && DBWindow.rootViewController)return;
        UIWindowScene *scene=nil;
        for(UIScene *s in UIApplication.sharedApplication.connectedScenes)
            if(s.activationState==UISceneActivationStateForegroundActive && [s isKindOfClass:UIWindowScene.class]){scene=(UIWindowScene *)s;break;}
        if(!scene)return;
        DBWindow=[[DBPassthroughWindow alloc] initWithWindowScene:scene];
        DBWindow.frame=scene.coordinateSpace.bounds; DBWindow.windowLevel=UIWindowLevelNormal+1;
        DBWindow.backgroundColor=UIColor.clearColor;
        UIViewController *root=[UIViewController new]; root.view.backgroundColor=UIColor.clearColor; DBWindow.rootViewController=root;
        DBMenuController *menu=[DBMenuController new]; [root addChildViewController:menu];
        menu.view.frame=root.view.bounds; menu.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [root.view addSubview:menu.view]; [menu didMoveToParentViewController:root]; DBWindow.hidden=NO;
    });
}
__attribute__((constructor)) static void DoxBonLoad(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(__unused NSNotification *n){DBPresentMenu();}];
        DBPresentMenu();
    });
}
