// UIButton+PDKAFNetworking.m
// Copyright (c) 2011–2016 Alamofire Software Foundation ( http://alamofire.org/ )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIButton+PDKAFNetworking.h"

#import <objc/runtime.h>

#if TARGET_OS_IOS || TARGET_OS_TV

#import "UIImageView+PDKAFNetworking.h"
#import "PDKAFImageDownloader.h"

@interface UIButton (_PDKAFNetworking)
@end

@implementation UIButton (_PDKAFNetworking)

#pragma mark -

static char PDKAFImageDownloadReceiptNormal;
static char PDKAFImageDownloadReceiptHighlighted;
static char PDKAFImageDownloadReceiptSelected;
static char PDKAFImageDownloadReceiptDisabled;

static const char * af_imageDownloadReceiptKeyForState(UIControlState state) {
    switch (state) {
        case UIControlStateHighlighted:
            return &PDKAFImageDownloadReceiptHighlighted;
        case UIControlStateSelected:
            return &PDKAFImageDownloadReceiptSelected;
        case UIControlStateDisabled:
            return &PDKAFImageDownloadReceiptDisabled;
        case UIControlStateNormal:
        default:
            return &PDKAFImageDownloadReceiptNormal;
    }
}

- (PDKAFImageDownloadReceipt *)af_imageDownloadReceiptForState:(UIControlState)state {
    return (PDKAFImageDownloadReceipt *)objc_getAssociatedObject(self, af_imageDownloadReceiptKeyForState(state));
}

- (void)af_setImageDownloadReceipt:(PDKAFImageDownloadReceipt *)imageDownloadReceipt
                           forState:(UIControlState)state
{
    objc_setAssociatedObject(self, af_imageDownloadReceiptKeyForState(state), imageDownloadReceipt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

static char PDKAFBackgroundImageDownloadReceiptNormal;
static char PDKAFBackgroundImageDownloadReceiptHighlighted;
static char PDKAFBackgroundImageDownloadReceiptSelected;
static char PDKAFBackgroundImageDownloadReceiptDisabled;

static const char * af_backgroundImageDownloadReceiptKeyForState(UIControlState state) {
    switch (state) {
        case UIControlStateHighlighted:
            return &PDKAFBackgroundImageDownloadReceiptHighlighted;
        case UIControlStateSelected:
            return &PDKAFBackgroundImageDownloadReceiptSelected;
        case UIControlStateDisabled:
            return &PDKAFBackgroundImageDownloadReceiptDisabled;
        case UIControlStateNormal:
        default:
            return &PDKAFBackgroundImageDownloadReceiptNormal;
    }
}

- (PDKAFImageDownloadReceipt *)af_backgroundImageDownloadReceiptForState:(UIControlState)state {
    return (PDKAFImageDownloadReceipt *)objc_getAssociatedObject(self, af_backgroundImageDownloadReceiptKeyForState(state));
}

- (void)af_setBackgroundImageDownloadReceipt:(PDKAFImageDownloadReceipt *)imageDownloadReceipt
                                     forState:(UIControlState)state
{
    objc_setAssociatedObject(self, af_backgroundImageDownloadReceiptKeyForState(state), imageDownloadReceipt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -

@implementation UIButton (PDKAFNetworking)

+ (PDKAFImageDownloader *)sharedImageDownloader {

    return objc_getAssociatedObject(self, @selector(sharedImageDownloader)) ?: [PDKAFImageDownloader defaultInstance];
}

+ (void)setSharedImageDownloader:(PDKAFImageDownloader *)imageDownloader {
    objc_setAssociatedObject(self, @selector(sharedImageDownloader), imageDownloader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)setImageForState:(UIControlState)state
                 withURL:(NSURL *)url
{
    [self setImageForState:state withURL:url placeholderImage:nil];
}

- (void)setImageForState:(UIControlState)state
                 withURL:(NSURL *)url
        placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    [self setImageForState:state withURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setImageForState:(UIControlState)state
          withURLRequest:(NSURLRequest *)urlRequest
        placeholderImage:(nullable UIImage *)placeholderImage
                 success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                 failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure
{
    if ([self isActiveTaskURLEqualToURLRequest:urlRequest forState:state]) {
        return;
    }

    [self cancelImageDownloadTaskForState:state];

    PDKAFImageDownloader *downloader = [[self class] sharedImageDownloader];
    id <PDKAFImageRequestCache> imageCache = downloader.imageCache;

    //Use the image from the image cache if it exists
    UIImage *cachedImage = [imageCache imageforRequest:urlRequest withAdditionalIdentifier:nil];
    if (cachedImage) {
        if (success) {
            success(urlRequest, nil, cachedImage);
        } else {
            [self setImage:cachedImage forState:state];
        }
        [self af_setImageDownloadReceipt:nil forState:state];
    } else {
        if (placeholderImage) {
            [self setImage:placeholderImage forState:state];
        }

        __weak __typeof(self)weakSelf = self;
        NSUUID *downloadID = [NSUUID UUID];
        PDKAFImageDownloadReceipt *receipt;
        receipt = [downloader
                   downloadImageForURLRequest:urlRequest
                   withReceiptID:downloadID
                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
                       __strong __typeof(weakSelf)strongSelf = weakSelf;
                       if ([[strongSelf af_imageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                           if (success) {
                               success(request, response, responseObject);
                           } else if(responseObject) {
                               [strongSelf setImage:responseObject forState:state];
                           }
                           [strongSelf af_setImageDownloadReceipt:nil forState:state];
                       }

                   }
                   failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                       __strong __typeof(weakSelf)strongSelf = weakSelf;
                       if ([[strongSelf af_imageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                           if (failure) {
                               failure(request, response, error);
                           }
                           [strongSelf  af_setImageDownloadReceipt:nil forState:state];
                       }
                   }];

        [self af_setImageDownloadReceipt:receipt forState:state];
    }
}

#pragma mark -

- (void)setBackgroundImageForState:(UIControlState)state
                           withURL:(NSURL *)url
{
    [self setBackgroundImageForState:state withURL:url placeholderImage:nil];
}

- (void)setBackgroundImageForState:(UIControlState)state
                           withURL:(NSURL *)url
                  placeholderImage:(nullable UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    [self setBackgroundImageForState:state withURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setBackgroundImageForState:(UIControlState)state
                    withURLRequest:(NSURLRequest *)urlRequest
                  placeholderImage:(nullable UIImage *)placeholderImage
                           success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                           failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure
{
    if ([self isActiveBackgroundTaskURLEqualToURLRequest:urlRequest forState:state]) {
        return;
    }

    [self cancelBackgroundImageDownloadTaskForState:state];

    PDKAFImageDownloader *downloader = [[self class] sharedImageDownloader];
    id <PDKAFImageRequestCache> imageCache = downloader.imageCache;

    //Use the image from the image cache if it exists
    UIImage *cachedImage = [imageCache imageforRequest:urlRequest withAdditionalIdentifier:nil];
    if (cachedImage) {
        if (success) {
            success(urlRequest, nil, cachedImage);
        } else {
            [self setBackgroundImage:cachedImage forState:state];
        }
        [self af_setBackgroundImageDownloadReceipt:nil forState:state];
    } else {
        if (placeholderImage) {
            [self setBackgroundImage:placeholderImage forState:state];
        }

        __weak __typeof(self)weakSelf = self;
        NSUUID *downloadID = [NSUUID UUID];
        PDKAFImageDownloadReceipt *receipt;
        receipt = [downloader
                   downloadImageForURLRequest:urlRequest
                   withReceiptID:downloadID
                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
                       __strong __typeof(weakSelf)strongSelf = weakSelf;
                       if ([[strongSelf af_backgroundImageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                           if (success) {
                               success(request, response, responseObject);
                           } else if(responseObject) {
                               [strongSelf setBackgroundImage:responseObject forState:state];
                           }
                           [strongSelf af_setBackgroundImageDownloadReceipt:nil forState:state];
                       }

                   }
                   failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                       __strong __typeof(weakSelf)strongSelf = weakSelf;
                       if ([[strongSelf af_backgroundImageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                           if (failure) {
                               failure(request, response, error);
                           }
                           [strongSelf  af_setBackgroundImageDownloadReceipt:nil forState:state];
                       }
                   }];

        [self af_setBackgroundImageDownloadReceipt:receipt forState:state];
    }
}

#pragma mark -

- (void)cancelImageDownloadTaskForState:(UIControlState)state {
    PDKAFImageDownloadReceipt *receipt = [self af_imageDownloadReceiptForState:state];
    if (receipt != nil) {
        [[self.class sharedImageDownloader] cancelTaskForImageDownloadReceipt:receipt];
        [self af_setImageDownloadReceipt:nil forState:state];
    }
}

- (void)cancelBackgroundImageDownloadTaskForState:(UIControlState)state {
    PDKAFImageDownloadReceipt *receipt = [self af_backgroundImageDownloadReceiptForState:state];
    if (receipt != nil) {
        [[self.class sharedImageDownloader] cancelTaskForImageDownloadReceipt:receipt];
        [self af_setBackgroundImageDownloadReceipt:nil forState:state];
    }
}

- (BOOL)isActiveTaskURLEqualToURLRequest:(NSURLRequest *)urlRequest forState:(UIControlState)state {
    PDKAFImageDownloadReceipt *receipt = [self af_imageDownloadReceiptForState:state];
    return [receipt.task.originalRequest.URL.absoluteString isEqualToString:urlRequest.URL.absoluteString];
}

- (BOOL)isActiveBackgroundTaskURLEqualToURLRequest:(NSURLRequest *)urlRequest forState:(UIControlState)state {
    PDKAFImageDownloadReceipt *receipt = [self af_backgroundImageDownloadReceiptForState:state];
    return [receipt.task.originalRequest.URL.absoluteString isEqualToString:urlRequest.URL.absoluteString];
}


@end

#endif
