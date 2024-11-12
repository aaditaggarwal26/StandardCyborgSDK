//
// SCFootTrackingModel.m
//
// This file was automatically generated and should not be edited.
//

#if !__has_feature(objc_arc)
#error This file must be compiled with automatic reference counting enabled (-fobjc-arc)
#endif

#import "SCFootTrackingModel.h"

@implementation SCFootTrackingModelInput

- (instancetype)initWithImage:(CVPixelBufferRef)image iouThreshold:(double)iouThreshold confidenceThreshold:(double)confidenceThreshold {
    self = [super init];
    if (self) {
        _image = image;
        CVPixelBufferRetain(_image);
        _iouThreshold = iouThreshold;
        _confidenceThreshold = confidenceThreshold;
    }
    return self;
}

- (void)dealloc {
    CVPixelBufferRelease(_image);
}

- (nullable instancetype)initWithImageFromCGImage:(CGImageRef)image iouThreshold:(double)iouThreshold confidenceThreshold:(double)confidenceThreshold error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self) {
        NSError *localError;
        BOOL result = YES;
        id retVal = nil;
        @autoreleasepool {
            do {
                MLFeatureValue * __image = [MLFeatureValue featureValueWithCGImage:image pixelsWide:300 pixelsHigh:300 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
                if (__image == nil) {
                    result = NO;
                    break;
                }
                retVal = [self initWithImage:(CVPixelBufferRef)__image.imageBufferValue iouThreshold:iouThreshold confidenceThreshold:confidenceThreshold];
            }
            while(0);
        }
        if (error != NULL) {
            *error = localError;
        }
        return result ? retVal : nil;
    }
    return self;
}

- (nullable instancetype)initWithImageAtURL:(NSURL *)imageURL iouThreshold:(double)iouThreshold confidenceThreshold:(double)confidenceThreshold error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self) {
        NSError *localError;
        BOOL result = YES;
        id retVal = nil;
        @autoreleasepool {
            do {
                MLFeatureValue * __image = [MLFeatureValue featureValueWithImageAtURL:imageURL pixelsWide:300 pixelsHigh:300 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
                if (__image == nil) {
                    result = NO;
                    break;
                }
                retVal = [self initWithImage:(CVPixelBufferRef)__image.imageBufferValue iouThreshold:iouThreshold confidenceThreshold:confidenceThreshold];
            }
            while(0);
        }
        if (error != NULL) {
            *error = localError;
        }
        return result ? retVal : nil;
    }
    return self;
}

-(BOOL)setImageWithCGImage:(CGImageRef)image error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    NSError *localError;
    BOOL result = NO;
    @autoreleasepool {
        MLFeatureValue * __image = [MLFeatureValue featureValueWithCGImage:image pixelsWide:300 pixelsHigh:300 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
        if (__image != nil) {
            CVPixelBufferRelease(self.image);
            self.image =  (CVPixelBufferRef)__image.imageBufferValue;
            CVPixelBufferRetain(self.image);
            result = YES;
        }
    }
    if (error != NULL) {
        *error = localError;
    }
    return result;
}

-(BOOL)setImageWithURL:(NSURL *)imageURL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    NSError *localError;
    BOOL result = NO;
    @autoreleasepool {
        MLFeatureValue * __image = [MLFeatureValue featureValueWithImageAtURL:imageURL pixelsWide:300 pixelsHigh:300 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
        if (__image != nil) {
            CVPixelBufferRelease(self.image);
            self.image =  (CVPixelBufferRef)__image.imageBufferValue;
            CVPixelBufferRetain(self.image);
            result = YES;
        }
    }
    if (error != NULL) {
        *error = localError;
    }
    return result;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"image", @"iouThreshold", @"confidenceThreshold"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"image"]) {
        return [MLFeatureValue featureValueWithPixelBuffer:self.image];
    }
    if ([featureName isEqualToString:@"iouThreshold"]) {
        return [MLFeatureValue featureValueWithDouble:self.iouThreshold];
    }
    if ([featureName isEqualToString:@"confidenceThreshold"]) {
        return [MLFeatureValue featureValueWithDouble:self.confidenceThreshold];
    }
    return nil;
}

@end

@implementation SCFootTrackingModelOutput

- (instancetype)initWithConfidence:(MLMultiArray *)confidence coordinates:(MLMultiArray *)coordinates {
    self = [super init];
    if (self) {
        _confidence = confidence;
        _coordinates = coordinates;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"confidence", @"coordinates"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"confidence"]) {
        return [MLFeatureValue featureValueWithMultiArray:self.confidence];
    }
    if ([featureName isEqualToString:@"coordinates"]) {
        return [MLFeatureValue featureValueWithMultiArray:self.coordinates];
    }
    return nil;
}

@end

@implementation SCFootTrackingModel


/**
    URL of the underlying .mlmodelc directory.
*/
+ (nullable NSURL *)URLOfModelInThisBundle {
    NSString *assetPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SCFootTrackingModel" ofType:@"mlmodelc"];
    if (nil == assetPath) { os_log_error(OS_LOG_DEFAULT, "Could not load SCFootTrackingModel.mlmodelc in the bundle resource"); return nil; }
    return [NSURL fileURLWithPath:assetPath];
}


/**
    Initialize SCFootTrackingModel instance from an existing MLModel object.

    Usually the application does not use this initializer unless it makes a subclass of SCFootTrackingModel.
    Such application may want to use `-[MLModel initWithContentsOfURL:configuration:error:]` and `+URLOfModelInThisBundle` to create a MLModel object to pass-in.
*/
- (instancetype)initWithMLModel:(MLModel *)model {
    if (model == nil) {
        return nil;
    }
    self = [super init];
    if (self != nil) {
        _model = model;
    }
    return self;
}


/**
    Initialize SCFootTrackingModel instance with the model in this bundle.
*/
- (nullable instancetype)init {
    return [self initWithContentsOfURL:(NSURL * _Nonnull)self.class.URLOfModelInThisBundle error:nil];
}


/**
    Initialize SCFootTrackingModel instance with the model in this bundle.

    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self initWithContentsOfURL:(NSURL * _Nonnull)self.class.URLOfModelInThisBundle configuration:configuration error:error];
}


/**
    Initialize SCFootTrackingModel instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for SCFootTrackingModel.
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL error:error];
    if (model == nil) { return nil; }
    return [self initWithMLModel:model];
}


/**
    Initialize SCFootTrackingModel instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for SCFootTrackingModel.
    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL configuration:configuration error:error];
    if (model == nil) { return nil; }
    return [self initWithMLModel:model];
}


/**
    Construct SCFootTrackingModel instance asynchronously with configuration.
    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid SCFootTrackingModel instance or NSError object.
*/
+ (void)loadWithConfiguration:(MLModelConfiguration *)configuration completionHandler:(void (^)(SCFootTrackingModel * _Nullable model, NSError * _Nullable error))handler {
    [self loadContentsOfURL:(NSURL * _Nonnull)[self URLOfModelInThisBundle]
              configuration:configuration
          completionHandler:handler];
}


/**
    Construct SCFootTrackingModel instance asynchronously with URL of .mlmodelc directory and optional configuration.

    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param modelURL The model URL.
    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid SCFootTrackingModel instance or NSError object.
*/
+ (void)loadContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration completionHandler:(void (^)(SCFootTrackingModel * _Nullable model, NSError * _Nullable error))handler {
    [MLModel loadContentsOfURL:modelURL
                 configuration:configuration
             completionHandler:^(MLModel *model, NSError *error) {
        if (model != nil) {
            SCFootTrackingModel *typedModel = [[SCFootTrackingModel alloc] initWithMLModel:model];
            handler(typedModel, nil);
        } else {
            handler(nil, error);
        }
    }];
}

- (nullable SCFootTrackingModelOutput *)predictionFromFeatures:(SCFootTrackingModelInput *)input error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self predictionFromFeatures:input options:[[MLPredictionOptions alloc] init] error:error];
}

- (nullable SCFootTrackingModelOutput *)predictionFromFeatures:(SCFootTrackingModelInput *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    id<MLFeatureProvider> outFeatures = [self.model predictionFromFeatures:input options:options error:error];
    if (!outFeatures) { return nil; }
    return [[SCFootTrackingModelOutput alloc] initWithConfidence:(MLMultiArray *)[outFeatures featureValueForName:@"confidence"].multiArrayValue coordinates:(MLMultiArray *)[outFeatures featureValueForName:@"coordinates"].multiArrayValue];
}

- (void)predictionFromFeatures:(SCFootTrackingModelInput *)input completionHandler:(void (^)(SCFootTrackingModelOutput * _Nullable output, NSError * _Nullable error))completionHandler {
    [self.model predictionFromFeatures:input completionHandler:^(id<MLFeatureProvider> prediction, NSError *predictionError) {
        if (prediction != nil) {
            SCFootTrackingModelOutput *output = [[SCFootTrackingModelOutput alloc] initWithConfidence:(MLMultiArray *)[prediction featureValueForName:@"confidence"].multiArrayValue coordinates:(MLMultiArray *)[prediction featureValueForName:@"coordinates"].multiArrayValue];
            completionHandler(output, predictionError);
        } else {
            completionHandler(nil, predictionError);
        }
    }];
}

- (void)predictionFromFeatures:(SCFootTrackingModelInput *)input options:(MLPredictionOptions *)options completionHandler:(void (^)(SCFootTrackingModelOutput * _Nullable output, NSError * _Nullable error))completionHandler {
    [self.model predictionFromFeatures:input options:options completionHandler:^(id<MLFeatureProvider> prediction, NSError *predictionError) {
        if (prediction != nil) {
            SCFootTrackingModelOutput *output = [[SCFootTrackingModelOutput alloc] initWithConfidence:(MLMultiArray *)[prediction featureValueForName:@"confidence"].multiArrayValue coordinates:(MLMultiArray *)[prediction featureValueForName:@"coordinates"].multiArrayValue];
            completionHandler(output, predictionError);
        } else {
            completionHandler(nil, predictionError);
        }
    }];
}

- (nullable SCFootTrackingModelOutput *)predictionFromImage:(CVPixelBufferRef)image iouThreshold:(double)iouThreshold confidenceThreshold:(double)confidenceThreshold error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    SCFootTrackingModelInput *input_ = [[SCFootTrackingModelInput alloc] initWithImage:image iouThreshold:iouThreshold confidenceThreshold:confidenceThreshold];
    return [self predictionFromFeatures:input_ error:error];
}

- (nullable NSArray<SCFootTrackingModelOutput *> *)predictionsFromInputs:(NSArray<SCFootTrackingModelInput*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    id<MLBatchProvider> inBatch = [[MLArrayBatchProvider alloc] initWithFeatureProviderArray:inputArray];
    id<MLBatchProvider> outBatch = [self.model predictionsFromBatch:inBatch options:options error:error];
    if (!outBatch) { return nil; }
    NSMutableArray<SCFootTrackingModelOutput*> *results = [NSMutableArray arrayWithCapacity:(NSUInteger)outBatch.count];
    for (NSInteger i = 0; i < outBatch.count; i++) {
        id<MLFeatureProvider> resultProvider = [outBatch featuresAtIndex:i];
        SCFootTrackingModelOutput * result = [[SCFootTrackingModelOutput alloc] initWithConfidence:(MLMultiArray *)[resultProvider featureValueForName:@"confidence"].multiArrayValue coordinates:(MLMultiArray *)[resultProvider featureValueForName:@"coordinates"].multiArrayValue];
        [results addObject:result];
    }
    return results;
}

@end
