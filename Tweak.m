#import <substrate.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#define LOG
#import "JGMethodSwizzler.h"
#import <CommonCrypto/CommonCrypto.h>
#import "OCZip/Objective-Zip+NSError.h"

@class NSArray, NSMutableArray;

@interface BFCodec : NSObject
{

}

- (void)dealloc;
- (BOOL)decipher:(id)arg1;
- (unsigned int)encipher:(id)arg1;
- (void)cipherInit:(id)arg1;
- (void)cipherInit:(const char *)arg1 keyLength:(int)arg2;
- (id)init;
@end
@interface RBMusicManager : NSObject
{
    BOOL _musicDataArrayDirtyFlag;
    int _clientMusicPageNum;
    NSMutableArray *_clientMusics;
    NSArray *_preinstallMusicIDs;
    NSMutableArray *_purchasedMusicDictionaries;
    NSMutableArray *_musicDataArray;
}

+ (id)getPathFromPurchesedOldDirectory:(int)arg1;
+ (id)getPathFromPurchesed:(int)arg1;
+ (id)getPathFromBundle:(int)arg1;
+ (id)getMusicDataFilename:(int)arg1;
+ (id)getInstance;
@property(nonatomic) BOOL musicDataArrayDirtyFlag; // @synthesize musicDataArrayDirtyFlag=_musicDataArrayDirtyFlag;
@property(retain, nonatomic) NSMutableArray *musicDataArray; // @synthesize musicDataArray=_musicDataArray;
@property(retain, nonatomic) NSMutableArray *purchasedMusicDictionaries; // @synthesize purchasedMusicDictionaries=_purchasedMusicDictionaries;
@property(retain, nonatomic) NSArray *preinstallMusicIDs; // @synthesize preinstallMusicIDs=_preinstallMusicIDs;
@property(retain, nonatomic) NSMutableArray *clientMusics; // @synthesize clientMusics=_clientMusics;
@property(nonatomic) int clientMusicPageNum; // @synthesize clientMusicPageNum=_clientMusicPageNum;
- (id)getClientCompareMusics;
- (int)setClientMusic:(id)arg1;
- (void)releaseClientMusic;
- (id)getMusicIDs;
- (void)releaseChacheMusicData;
- (id)getMusicData:(int)arg1;
- (id)getMusicDataArray;
- (void)setMusicDataArrayDirty;
- (void)createMusicDataArray;
- (BOOL)addPurchasedMusic:(id)arg1;
- (id)getPurchasedMusicDictionaris;
- (id)getPurchasedMusicDictionary:(int)arg1;
- (void)savePurchasedMusics;
- (void)loadPurchasedMusics;
- (void)createPreInMusics;
- (void)dealloc;
- (id)init;
- (_Bool)deleteMusic:(int)arg1;

@end




NSString * DocumentsDirectory ()
{    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    [paths release];
    return [basePath stringByAppendingString:@"/"];
}
NSString * LibraryDirectory ()
{    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    [paths release];
    return [basePath stringByAppendingString:@"/"];
}

static void SaveMulist(NSString* OutFileName,NSString* InputFileName){
    NSString* SavePath=[DocumentsDirectory() stringByAppendingString:OutFileName];
    NSString* musicListKey=[objc_getClass("AppDelegate") performSelector:@selector(musicListKey)];
    NSMutableData* data=[NSMutableData dataWithBytes:"\x41\x53\x48\x55" length:4];
    BFCodec* BFC=[[objc_getClass("BFCodec") alloc] init];

    InputFileName=[DocumentsDirectory() stringByAppendingString:InputFileName];
    NSLog(@"InputFileName:%@",InputFileName);
    NSData* YoSwag=[NSData dataWithContentsOfFile:InputFileName];
    [data appendData:YoSwag];
    NSLog(@"Prefixed Data Size:%lu",(unsigned long)data.length);
    [YoSwag release];
    const char* MK=[musicListKey UTF8String];
    int r5 = strlen(MK);
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    CC_MD5_Update(&md5,MK,r5);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSData* s=[NSData dataWithBytes:digest length:0x10];
    NSLog(@"Actual BFCodec Key:%@",s);

    [BFC cipherInit:s];
    [BFC encipher:data];
    [data writeToFile:SavePath atomically:YES];
    [data release];
    [SavePath release];
    [s release];
    [BFC release];


}
static void DecryptMulist(NSString* InputFileName){
     NSString* SavePath=[DocumentsDirectory() stringByAppendingString:InputFileName];
    NSString* musicListKey=[objc_getClass("AppDelegate") performSelector:@selector(musicListKey)];
    NSMutableData* olddata=[NSMutableData dataWithContentsOfFile:SavePath];
    BFCodec* BFC=[[objc_getClass("BFCodec") alloc] init];
    const char* MK=[musicListKey UTF8String];
    int r5 = strlen(MK);
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    CC_MD5_Update(&md5,MK,r5);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSData* s=[NSData dataWithBytes:digest length:0x10];

    [BFC cipherInit:s];
    [BFC decipher:olddata];
    NSMutableData* data=[NSMutableData dataWithData:[olddata subdataWithRange:NSMakeRange(4,olddata.length-4)]];
    NSLog(@"Decrypted:\n%@",data);
    [data release];
    [s release];
    [olddata release];
    [BFC release];

}


static  __attribute__((constructor)) void CTOR()
 {
	NSLog(@"---Moving Songs---");
NSString *oldDirectory = [NSString stringWithFormat:@"%@/",DocumentsDirectory()];
NSString *newDirectory = [NSString stringWithFormat:@"%@/Private Documents/",LibraryDirectory()];
NSFileManager *fm = [NSFileManager defaultManager];
NSArray *files = [fm contentsOfDirectoryAtPath:oldDirectory error:nil];

for (NSString *file in files) {
    if ([file hasSuffix:@".rb"]){
    [fm removeItemAtPath:[newDirectory stringByAppendingPathComponent:file] error:nil];
    [fm moveItemAtPath:[oldDirectory stringByAppendingPathComponent:file]
                toPath:[newDirectory stringByAppendingPathComponent:file]
                 error:nil];
               

                }


}	



	NSLog(@"-------RBAC+-----");
	[objc_getClass("RBPurchaseManager") swizzleInstanceMethod:@selector(isPurchased:) withReplacement:JGMethodReplacementProviderBlock {
    return JGMethodReplacement(BOOL, const Class *,id arg1) {
    	return YES;
    };
	}];
	[objc_getClass("RBExperienceData") swizzleInstanceMethod:@selector(unlockWithMusicID:) withReplacement:JGMethodReplacementProviderBlock {
    return JGMethodReplacement(BOOL, const Class *,int arg1) {
    	return YES;
    };
	}];
	[objc_getClass("RBExperienceData") swizzleInstanceMethod:@selector(unlockWithBackgroundType:) withReplacement:JGMethodReplacementProviderBlock {
    return JGMethodReplacement(BOOL, const Class *,int arg1) {
    	return YES;
    };
	}];
	[objc_getClass("RBExperienceData") swizzleInstanceMethod:@selector(unlockWithFrameType:) withReplacement:JGMethodReplacementProviderBlock {
    return JGMethodReplacement(BOOL, const Class *,int arg1) {
    	return YES;
    };
	}];
	[objc_getClass("RBExperienceData") swizzleInstanceMethod:@selector(unlockWithExprosionType:) withReplacement:JGMethodReplacementProviderBlock {
    return JGMethodReplacement(BOOL, const Class *,int arg1) {
    	return YES;
    };
	}];
	[objc_getClass("RBExperienceData") swizzleInstanceMethod:@selector(unlockWithShotType:) withReplacement:JGMethodReplacementProviderBlock {
    return JGMethodReplacement(BOOL, const Class *,int arg1) {
    	return YES;
    };
	}];
	[objc_getClass("RBExperienceData") swizzleInstanceMethod:@selector(unlockWithBGMtype:) withReplacement:JGMethodReplacementProviderBlock {
    return JGMethodReplacement(BOOL, const Class *,int arg1) {
    	return YES;
    };
	}];
	NSLog(@"Hook musicListKey");
	[objc_getClass("AppDelegate") swizzleClassMethod:@selector(musicListKey) withReplacement:JGMethodReplacementProviderBlock {
    return JGMethodReplacement(NSString*, const Class *) {
    	return @"FUCKYOUKONAMI";
    };
	}];
NSLog(@"Save mulist");
SaveMulist(@"MulistEncrypted",@"Input.plist");
NSLog(@"Decrypted mulist");
DecryptMulist(@"MulistEncrypted");











//Repack Songs


/*
 for(NSString* FolderName in [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/RbArcade",DocumentsDirectory()] error:nil]){
    NSString* ZipName=[NSString stringWithFormat:@"%@.zip",FolderName];
        OZZipFile *zipFile= [[OZZipFile alloc] initWithFileName:ZipName mode:OZZipFileModeCreate];
    for(NSString* FileName in [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/RbArcade/%@",DocumentsDirectory(),FolderName] error:nil]){


    }
    [zipFile release];
    [ZipName release];

 }//End loop*/


}