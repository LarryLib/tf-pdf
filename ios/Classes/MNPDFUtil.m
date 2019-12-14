//
//  MNPDFUtil.m
//  
//
//  Created by zhy on 2017/6/14.
//  Copyright © 2017年 zhy All rights reserved.
//

#import "MNPDFUtil.h"

@implementation MNPDFUtil


void drawContentForPage(CGContextRef myContext,
                        CFDataRef data,
                        CGRect rect)
{
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(data);
    CGImageRef image = CGImageCreateWithJPEGDataProvider(dataProvider,
                                                         NULL,
                                                         NO,
                                                         kCGRenderingIntentDefault);

    CGContextDrawImage(myContext, rect, image);
    
    CGDataProviderRelease(dataProvider);
    CGImageRelease(image);
}

+ (NSData*)createPDFFileWithImage:(NSArray*)imagePathArr PDFSize:(CGSize)size toDestFile:(NSString *)destFileName {
    const char *fileName = [destFileName UTF8String];
    CFStringRef path = CFStringCreateWithCString (NULL, fileName, kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, 0);
    CFRelease (path);

    CFMutableDictionaryRef myDictionary = CFDictionaryCreateMutable(NULL,
                                             0,
                                             &kCFTypeDictionaryKeyCallBacks,
                                             &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(myDictionary,
                         kCGPDFContextTitle,
                         CFSTR("moxiang notebook"));
    CFDictionarySetValue(myDictionary,
                         kCGPDFContextCreator,
                         CFSTR("wuhantianyu"));
    
    //开始生成pdf文件
    CGContextRef pdfContext = NULL;
    CFDataRef boxData = NULL;
    CFMutableDictionaryRef pageDictionary = NULL;
    
    //正常情况下每一页的尺寸都是一样的
    CGRect pageRect = CGRectMake(0, 0, size.width, size.height);
    pdfContext = CGPDFContextCreateWithURL (url, &pageRect, myDictionary);

    for (int pageIndex = 0; pageIndex < imagePathArr.count; pageIndex++) {
        NSData * imgData = [NSData dataWithContentsOfFile:imagePathArr[pageIndex]];
        UIImage * image = [UIImage imageWithData:imgData];
        image = [self compressOriginalImage:image toSize:size];
        imgData = UIImageJPEGRepresentation(image, 1.0);
        CFDataRef data = (__bridge CFDataRef)imgData;
        pageDictionary = CFDictionaryCreateMutable(NULL,
                                                   0,
                                                   &kCFTypeDictionaryKeyCallBacks,
                                                   &kCFTypeDictionaryValueCallBacks);
        
        boxData = CFDataCreate(NULL,(const UInt8 *)&pageRect, sizeof (CGRect));
        CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
        
        //生成一个新的页面
        CGPDFContextBeginPage (pdfContext, pageDictionary);
        drawContentForPage(pdfContext,data,pageRect);
        CGPDFContextEndPage (pdfContext);
    }
    
    CFRelease(myDictionary);
    CFRelease(url);
    CGContextRelease (pdfContext);
    CFRelease(pageDictionary);
    CFRelease(boxData);
    
    return [NSData dataWithContentsOfFile:destFileName];
}



+(UIImage *)compressOriginalImage:(UIImage *)image toSize:(CGSize)size{
    UIImage * resultImage = image;
    UIGraphicsBeginImageContext(size);
    [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end
