#import "TfPdfPlugin.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "MNPDFUtil.h"

@implementation TfPdfPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"tf_pdf_channel" binaryMessenger:[registrar messenger]];
    TfPdfPlugin* instance = [[TfPdfPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"createPDFByImage" isEqualToString:call.method]) {
      NSString *savePath = call.arguments[@"savePath"];
      NSArray <NSString *>*imagePaths = call.arguments[@"imagePaths"];
      NSNumber *width = call.arguments[@"width"];
      NSNumber *height = call.arguments[@"height"];
      if ((NSNull *)savePath == [NSNull null]) {
          NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
          NSString *docDir = [paths objectAtIndex:0];
          savePath = [[NSString alloc] initWithFormat:@"%@/new.pdf", docDir];
      }
      [MNPDFUtil createPDFFileWithImage:imagePaths PDFSize:CGSizeMake(width.floatValue, height.floatValue) toDestFile:savePath];
      result(savePath);
  } else {
      result(FlutterMethodNotImplemented);
  }
}
@end

