//
//  MNPDFUtil.h
//  
//
//  Created by zhy on 2017/6/14.
//  Copyright © 2017年 zhy All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNPDFUtil : NSObject

+ (NSData*)createPDFFileWithImage:(NSArray*)imagePathArr PDFSize:(CGSize)size toDestFile:(NSString *)destFileName;

@end
