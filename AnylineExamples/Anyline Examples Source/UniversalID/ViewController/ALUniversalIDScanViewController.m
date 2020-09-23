//
//  ALUniversalIDViewController.m
//  AnylineExamples
//
//  Created by Angela Brett on 25.06.20.
//

#import "ALUniversalIDScanViewController.h"
#import "ALAppDemoLicenses.h"
#import "ALResultEntry.h"
#import "ALResultViewController.h"

// This is the license key for the examples project used to set up Anyline below
NSString * const kUniversalIDLicenseKey = kDemoAppLicenseKey;
@interface ALUniversalIDScanViewController ()<ALIDPluginDelegate, ALInfoDelegate, ALScanViewPluginDelegate>

@property (nonatomic, strong) ALIDScanViewPlugin *scanViewPlugin;
@property (nonatomic, strong) ALIDScanPlugin *scanPlugin;
@property (nullable, nonatomic, strong) ALScanView *scanView;

@end

@implementation ALUniversalIDScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set the background color to black to have a nicer transition
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"Universal ID";
    
    // Initializing the scan view. It's a UIView subclass. We set the frame to fill the whole screen
    CGRect frame = [self scanViewFrame];
    
    NSError *error = nil;
    NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:@"universal_id_config" ofType:@"json"];
     NSData *jsonFile = [NSData dataWithContentsOfFile:jsonFilePath];
     NSDictionary *configDict = [NSJSONSerialization JSONObjectWithData: jsonFile options: NSJSONReadingMutableContainers error: &error];
    self.scanViewPlugin = (ALIDScanViewPlugin *)[ALAbstractScanViewPlugin scanViewPluginForConfigDict:configDict licenseKey:kUniversalIDLicenseKey delegate:self error:&error];

    [self.scanViewPlugin addScanViewPluginDelegate:self];
    
    NSAssert(self.scanViewPlugin, @"Setup Error: %@", error.debugDescription);
    self.scanPlugin = self.scanViewPlugin.idScanPlugin;
    
    [self.scanPlugin addInfoDelegate:self];
    
    self.scanView = [[ALScanView alloc] initWithFrame:frame scanViewPlugin:self.scanViewPlugin];
    
    self.scanView.flashButtonConfig.flashAlignment = ALFlashAlignmentTopLeft;
    
    self.controllerType = ALScanHistoryUniversalID;
    
    // After setup is complete we add the scanView to the view of this view controller
    [self.view addSubview:self.scanView];
    [self.view sendSubviewToBack:self.scanView];
    
    //Start Camera:
    [self.scanView startCamera];
    [self startListeningForMotion];
}

/*
 This method will be called once the view controller and its subviews have appeared on screen
 */
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // We use this subroutine to start Anyline. The reason it has its own subroutine is
    // so that we can later use it to restart the scanning process.
    [self startAnyline];
}

/*
 Cancel scanning to allow the module to clean up
 */
- (void)viewWillDisappear:(BOOL)animated {
    [self.scanViewPlugin stopAndReturnError:nil];
}

/*
 This method is used to tell Anyline to start scanning. It gets called in
 viewDidAppear to start scanning the moment the view appears. Once a result
 is found scanning will stop automatically (you can change this behaviour
 with cancelOnResult:). When the user dismisses self.identificationView this
 method will get called again.
 */
- (void)startAnyline {
    [self startPlugin:self.scanViewPlugin];
}


#pragma mark -- AnylineOCRModuleDelegate

/*
 This is the main delegate method Anyline uses to report its results
 */
- (void)anylineIDScanPlugin:(ALIDScanPlugin *)anylineIDScanPlugin
              didFindResult:(ALIDResult *)scanResult {
    [self.scanViewPlugin stopAndReturnError:nil];
    
    ALUniversalIDIdentification *identification = (ALUniversalIDIdentification *)scanResult.result;
    
    NSMutableArray<ALResultEntry *> *resultData = [[NSMutableArray alloc] init];
    
    [[identification fieldNames] enumerateObjectsUsingBlock:^(NSString *fieldName, NSUInteger idx, BOOL *stop) {
        [resultData addObject:[[ALResultEntry alloc] initWithTitle:fieldName value:[identification valueForField:fieldName]]];
    }];
        //Display the result
        ALResultViewController *vc = [[ALResultViewController alloc] initWithResultData:resultData image:scanResult.image];
        
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)anylineScanPlugin:(ALAbstractScanPlugin *)anylineScanPlugin reportInfo:(ALScanInfo *)info{
    if ([info.variableName isEqualToString:@"$brightness"]) {
        [self updateBrightness:[info.value floatValue] forModule:self.scanPlugin];
    }
    
}

- (void)anylineScanPlugin:(ALAbstractScanPlugin * _Nonnull)anylineScanPlugin
               runSkipped:(ALRunSkippedReason * _Nonnull)runSkippedReason {
    if (runSkippedReason.reason == ALRunFailureIDTypeNotSupported) {
        [self updateScanWarnings:ALWarningStateIDNotSupported];
    }
}

- (void)anylineScanViewPlugin:(ALAbstractScanViewPlugin *)anylineScanViewPlugin updatedCutout:(CGRect)cutoutRect {
    //Update Position of Warning Indicator
    [self updateWarningPosition:
     cutoutRect.origin.y +
     cutoutRect.size.height +
     self.scanView.frame.origin.y +
     80];
}

@end
