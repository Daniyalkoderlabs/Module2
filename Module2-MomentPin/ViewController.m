//
//  ViewController.m
//  Module2-MomentPin
//
//  Created by Daniyal Yousuf on 7/23/18.
//  Copyright © 2018 Daniyal Yousuf. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import "ImagesCollectionCell.h"
#import "ImagesHeader.h"
#import <UIKit/UICollectionViewFlowLayout.h>

@interface ViewController ()  {
    
    __weak IBOutlet UICollectionView *baseCollectionView;
    NSMutableArray *imagesArray;
    id photosArray;
    int myIndex;
    PHFetchResult* yearList;
    NSMutableArray *momentData;
    NSMutableArray *momentsInfo;
    
}
@property(nonatomic , strong) PHCachingImageManager *imageManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    myIndex = 0;
    momentsInfo = [NSMutableArray new];
    momentData = [NSMutableArray new];
    baseCollectionView.delegate = self;
    baseCollectionView.dataSource = self;
    imagesArray = [NSMutableArray new];
    _imageManager = [PHCachingImageManager new];
    [baseCollectionView registerNib:[UINib nibWithNibName:@"ImagesHeader" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"imagesheader"];
    [baseCollectionView registerNib:[UINib nibWithNibName:@"ImagesCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"imagescell"];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                [self usingFetchList];// [self fetchPhotos];
                break;
            default:
                break;
        }
        
    }];

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    /*let layout = UICollectionViewFlowLayout()
     layout.sectionHeadersPinToVisibleBounds = true
     layout.minimumInteritemSpacing = 1
     layout.minimumLineSpacing = 1
     super.init(collectionViewLayout: layout)
     */
    
    UICollectionViewFlowLayout *currentLayout = (UICollectionViewFlowLayout *)baseCollectionView.collectionViewLayout;
    currentLayout.sectionHeadersPinToVisibleBounds = YES;
}

-(NSDictionary*)metadataFromImageData:(NSData*)imageData{
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(imageData), NULL);
    if (imageSource) {
        NSDictionary *options = @{(NSString *)kCGImageSourceShouldCache : [NSNumber numberWithBool:NO]};
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
        if (imageProperties) {
            NSDictionary *metadata = (__bridge NSDictionary *)imageProperties;
            CFRelease(imageProperties);
            CFRelease(imageSource);
            return metadata;
        }
        CFRelease(imageSource);
    }
    
    NSLog(@"Can't read metadata");
    return nil;
}

-(void)metadataReader{
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)photosArray options:nil];
    [result enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndex:myIndex] options:NSEnumerationConcurrent usingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        [self.imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            NSDictionary *metadata = [self metadataFromImageData:imageData];
            NSLog(@"Metadata: %@", metadata.description);
            NSDictionary *gpsDictionary = metadata[(NSString*)kCGImagePropertyGPSDictionary];
            if(gpsDictionary){
                NSLog(@"GPS: %@", gpsDictionary.description);
            }
            NSDictionary *exifDictionary = metadata[(NSString*)kCGImagePropertyExifDictionary];
            if(exifDictionary){
                NSLog(@"EXIF: %@", exifDictionary.description);
            }
            
            UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
            // assign image where ever you need...
        }];
        
    }];
}

-(void)fetchUsingCollectionList{
    /*
     let momentOptions = PHFetchOptions()
     momentOptions.predicate = NSPredicate(format:"localizedTitle != nil")
     momentList = PHAssetCollection.fetchMoments(with: nil)
     let momentListFiltered = PHAssetCollection.fetchMoments(with: momentOptions)
     let assetCount = momentList.count
     
     for index in 0...assetCount-1 {
     let a = momentList[index]
     let sta = a.localizedTitle
     let stb = a.localizedLocationNames
     print(index, sta ?? "--", stb)
     }
     */
    
    
   // PHFetchOptions *momentOptions = [PHFetchOptions new];
   // momentOptions.predicate = [NSPredicate predicateWithFormat:@"localizedTitle != nil"];
    //id momentList =  [PHAssetCollection fetchMomentsWithOptions:nil];
    //id momentFilteredList = [PHAssetCollection fetchMomentsWithOptions:momentOptions];
  
    
}

#pragma mark:- TODO
-(void)usingFetchList{
    yearList = [PHCollectionList fetchMomentListsWithSubtype:PHCollectionListSubtypeMomentListYear options:nil];
    for(id foobar in yearList) { // each year
        if([foobar isKindOfClass:[PHCollectionList class]]) {
            PHCollectionList* yearCollectionList = (PHCollectionList*) foobar;
            NSDateComponents* dateComps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:yearCollectionList.startDate];
            PHFetchResult* momentCollectionList = [PHCollectionList fetchCollectionsInCollectionList:yearCollectionList options:nil];
            for(int i = 0; i < momentCollectionList.count; i++) { // moments
                NSMutableArray *photosArray1 = [NSMutableArray new];
                PHAssetCollection* momentCollection = [momentCollectionList objectAtIndex:i];
                NSLocale *currentLocale = [NSLocale currentLocale];
                NSDateFormatter *currentFormat =  [NSDateFormatter new];
                currentFormat.locale = currentLocale;
                currentFormat.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"eeeMMMdyyyy" options:0 locale:currentLocale];
                NSString *data = [currentFormat stringFromDate:momentCollection.startDate];
                [momentsInfo addObject:data];
                PHFetchResult* phassetList = [PHAsset fetchAssetsInAssetCollection:momentCollection options:nil];
                NSLog(@"photo count:%lu", (unsigned long)phassetList.count);
                for(int j = 0; j < phassetList.count; j++) { // photos of moment
                    PHAsset* eachAsset = [phassetList objectAtIndex:j];
                    if(eachAsset.mediaType == PHAssetMediaTypeImage) {
                        [_imageManager requestImageForAsset:eachAsset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info){
                            [photosArray1 addObject:result];
                            
                        }];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [momentData addObject:[photosArray1 copy]];
                    [photosArray1 removeAllObjects];
                });
                
                
            }//Momentcollection
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [baseCollectionView reloadData];
    });

}



-(void)usingFetchList1{
   // PHFetchResult* yearList = [PHCollectionList fetchMomentListsWithSubtype:PHCollectionListSubtypeMomentListYear options:nil];
  //  for(id foobar in yearList) { // each year
 //       if([foobar isKindOfClass:[PHCollectionList class]]) {
 //           PHCollectionList* yearCollectionList = (PHCollectionList*) foobar;
            
//            NSDateComponents* dateComps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:yearCollectionList.startDate];
            // [years addObject: [NSNumber numberWithInt: (int) dateComps.year]];
          //  NSLog(@"year %d", dateComps.year);
            
            //PHFetchResult* momentCollectionList = [PHCollectionList fetchCollectionsInCollectionList:yearCollectionList options:nil];
    
            PHFetchResult* momentCollectionList = [PHCollectionList fetchMomentListsWithSubtype:PHCollectionListSubtypeMomentListCluster  options:nil];
    
            for(int i = 0; i < momentCollectionList.count; i++) { // moments
                PHAssetCollection* momentCollection = [momentCollectionList objectAtIndex:i];
                PHFetchResult* phassetList = [PHAsset fetchAssetsInAssetCollection:momentCollection options:nil];
                NSLog(@"photo count:%d", phassetList.count);
                for(int j = 0; j < phassetList.count; j++) { // photos of moment
                    PHAsset* eachAsset = [phassetList objectAtIndex:j];
                    if(eachAsset.mediaType == PHAssetMediaTypeImage) {
                        [_imageManager requestImageForAsset:eachAsset targetSize:CGSizeMake(80, 80) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info){
                            NSLog(@"%@",result);
                            [imagesArray addObject:result];
                        }];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [baseCollectionView reloadData];
            });

    
}



-(void)fetchPhotos{
    PHFetchOptions *photoOption = [PHFetchOptions new];
    photoOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    photosArray = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:photoOption];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    for (PHAsset *eachAsset in photosArray) {
        NSLog(@"%@",eachAsset);
       /* [[PHImageManager defaultManager] requestImageDataForAsset:eachAsset
                                                          options:options
                                                    resultHandler:
         ^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
             CIImage* ciImage = [CIImage imageWithData:imageData];
             NSLog(@"Metadata : %@", ciImage.properties);
             NSDictionary *metadata = [self metadataFromImageData:imageData];
             NSDictionary *gpsDictionary = metadata[(NSString*)kCGImagePropertyGPSDictionary];
             if(gpsDictionary){
                 NSLog(@"GPS: %@", gpsDictionary.description);
             }
            UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
            [imagesArray addObject:image];
         }]; */
        [_imageManager requestImageForAsset:eachAsset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info){
            NSLog(@"%@",result);
            [imagesArray addObject:result];
         }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      [baseCollectionView reloadData];
    });
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImagesCollectionCell *currentCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imagescell" forIndexPath:indexPath];
    NSMutableArray *currentArray = momentData[indexPath.section];
    [currentCell bindData:currentArray[indexPath.row]];
    //[currentCell bindData:imagesArray[indexPath.row]];
    return currentCell;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return momentData.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSMutableArray *sectionArry = momentData[section];
    
    return sectionArry.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ImagesHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"imagesheader" forIndexPath:indexPath];
    [view bindData:momentsInfo[indexPath.section]];
    return view;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(baseCollectionView.frame.size.width, 60);
}





@end
