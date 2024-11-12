//
// SCEarLandmarking.m
//
// This file was automatically generated and should not be edited.
//

#if !__has_feature(objc_arc)
#error This file must be compiled with automatic reference counting enabled (-fobjc-arc)
#endif

#import "SCEarLandmarking.h"

@implementation SCEarLandmarkingInput

- (instancetype)initWithInputs__image_tensor__0:(CVPixelBufferRef)inputs__image_tensor__0 {
    self = [super init];
    if (self) {
        _inputs__image_tensor__0 = inputs__image_tensor__0;
        CVPixelBufferRetain(_inputs__image_tensor__0);
    }
    return self;
}

- (void)dealloc {
    CVPixelBufferRelease(_inputs__image_tensor__0);
}

- (nullable instancetype)initWithInputs__image_tensor__0FromCGImage:(CGImageRef)inputs__image_tensor__0 error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self) {
        NSError *localError;
        BOOL result = YES;
        id retVal = nil;
        @autoreleasepool {
            do {
                MLFeatureValue * __inputs__image_tensor__0 = [MLFeatureValue featureValueWithCGImage:inputs__image_tensor__0 pixelsWide:300 pixelsHigh:300 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
                if (__inputs__image_tensor__0 == nil) {
                    result = NO;
                    break;
                }
                retVal = [self initWithInputs__image_tensor__0:(CVPixelBufferRef)__inputs__image_tensor__0.imageBufferValue];
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

- (nullable instancetype)initWithInputs__image_tensor__0AtURL:(NSURL *)inputs__image_tensor__0URL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    if (self) {
        NSError *localError;
        BOOL result = YES;
        id retVal = nil;
        @autoreleasepool {
            do {
                MLFeatureValue * __inputs__image_tensor__0 = [MLFeatureValue featureValueWithImageAtURL:inputs__image_tensor__0URL pixelsWide:300 pixelsHigh:300 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
                if (__inputs__image_tensor__0 == nil) {
                    result = NO;
                    break;
                }
                retVal = [self initWithInputs__image_tensor__0:(CVPixelBufferRef)__inputs__image_tensor__0.imageBufferValue];
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

-(BOOL)setInputs__image_tensor__0WithCGImage:(CGImageRef)inputs__image_tensor__0 error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    NSError *localError;
    BOOL result = NO;
    @autoreleasepool {
        MLFeatureValue * __inputs__image_tensor__0 = [MLFeatureValue featureValueWithCGImage:inputs__image_tensor__0 pixelsWide:300 pixelsHigh:300 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
        if (__inputs__image_tensor__0 != nil) {
            CVPixelBufferRelease(self.inputs__image_tensor__0);
            self.inputs__image_tensor__0 =  (CVPixelBufferRef)__inputs__image_tensor__0.imageBufferValue;
            CVPixelBufferRetain(self.inputs__image_tensor__0);
            result = YES;
        }
    }
    if (error != NULL) {
        *error = localError;
    }
    return result;
}

-(BOOL)setInputs__image_tensor__0WithURL:(NSURL *)inputs__image_tensor__0URL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    NSError *localError;
    BOOL result = NO;
    @autoreleasepool {
        MLFeatureValue * __inputs__image_tensor__0 = [MLFeatureValue featureValueWithImageAtURL:inputs__image_tensor__0URL pixelsWide:300 pixelsHigh:300 pixelFormatType:kCVPixelFormatType_32ARGB options:nil error:&localError];
        if (__inputs__image_tensor__0 != nil) {
            CVPixelBufferRelease(self.inputs__image_tensor__0);
            self.inputs__image_tensor__0 =  (CVPixelBufferRef)__inputs__image_tensor__0.imageBufferValue;
            CVPixelBufferRetain(self.inputs__image_tensor__0);
            result = YES;
        }
    }
    if (error != NULL) {
        *error = localError;
    }
    return result;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"inputs__image_tensor__0"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"inputs__image_tensor__0"]) {
        return [MLFeatureValue featureValueWithPixelBuffer:self.inputs__image_tensor__0];
    }
    return nil;
}

@end

@implementation SCEarLandmarkingOutput

- (instancetype)initWithNormed_coordinates_yx:(MLMultiArray *)normed_coordinates_yx {
    self = [super init];
    if (self) {
        _normed_coordinates_yx = normed_coordinates_yx;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"normed_coordinates_yx"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"normed_coordinates_yx"]) {
        return [MLFeatureValue featureValueWithMultiArray:self.normed_coordinates_yx];
    }
    return nil;
}

@end

@implementation SCEarLandmarking


/**
    URL of the underlying .mlmodelc directory.
*/
+ (nullable NSURL *)URLOfModelInThisBundle {
    NSString *assetPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SCEarLandmarking" ofType:@"mlmodelc"];
    if (nil == assetPath) { os_log_error(OS_LOG_DEFAULT, "Could not load SCEarLandmarking.mlmodelc in the bundle resource"); return nil; }
    return [NSURL fileURLWithPath:assetPath];
}


/**
    Initialize SCEarLandmarking instance from an existing MLModel object.

    Usually the application does not use this initializer unless it makes a subclass of SCEarLandmarking.
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
    Initialize SCEarLandmarking instance with the model in this bundle.
*/
- (nullable instancetype)init {
    return [self initWithContentsOfURL:(NSURL * _Nonnull)self.class.URLOfModelInThisBundle error:nil];
}


/**
    Initialize SCEarLandmarking instance with the model in this bundle.

    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithConfiguration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self initWithContentsOfURL:(NSURL * _Nonnull)self.class.URLOfModelInThisBundle configuration:configuration error:error];
}


/**
    Initialize SCEarLandmarking instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for SCEarLandmarking.
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL error:error];
    if (model == nil) { return nil; }
    return [self initWithMLModel:model];
}


/**
    Initialize SCEarLandmarking instance from the model URL.

    @param modelURL URL to the .mlmodelc directory for SCEarLandmarking.
    @param configuration The model configuration object
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
*/
- (nullable instancetype)initWithContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL configuration:configuration error:error];
    if (model == nil) { return nil; }
    return [self initWithMLModel:model];
}


/**
    Construct SCEarLandmarking instance asynchronously with configuration.
    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid SCEarLandmarking instance or NSError object.
*/
+ (void)loadWithConfiguration:(MLModelConfiguration *)configuration completionHandler:(void (^)(SCEarLandmarking * _Nullable model, NSError * _Nullable error))handler {
    [self loadContentsOfURL:(NSURL * _Nonnull)[self URLOfModelInThisBundle]
              configuration:configuration
          completionHandler:handler];
}


/**
    Construct SCEarLandmarking instance asynchronously with URL of .mlmodelc directory and optional configuration.

    Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

    @param modelURL The model URL.
    @param configuration The model configuration
    @param handler When the model load completes successfully or unsuccessfully, the completion handler is invoked with a valid SCEarLandmarking instance or NSError object.
*/
+ (void)loadContentsOfURL:(NSURL *)modelURL configuration:(MLModelConfiguration *)configuration completionHandler:(void (^)(SCEarLandmarking * _Nullable model, NSError * _Nullable error))handler {
    [MLModel loadContentsOfURL:modelURL
                 configuration:configuration
             completionHandler:^(MLModel *model, NSError *error) {
        if (model != nil) {
            SCEarLandmarking *typedModel = [[SCEarLandmarking alloc] initWithMLModel:model];
            handler(typedModel, nil);
        } else {
            handler(nil, error);
        }
    }];
}

- (nullable SCEarLandmarkingOutput *)predictionFromFeatures:(SCEarLandmarkingInput *)input error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self predictionFromFeatures:input options:[[MLPredictionOptions alloc] init] error:error];
}

- (nullable SCEarLandmarkingOutput *)predictionFromFeatures:(SCEarLandmarkingInput *)input options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    id<MLFeatureProvider> outFeatures = [self.model predictionFromFeatures:input options:options error:error];
    if (!outFeatures) { return nil; }
    return [[SCEarLandmarkingOutput alloc] initWithNormed_coordinates_yx:(MLMultiArray *)[outFeatures featureValueForName:@"normed_coordinates_yx"].multiArrayValue];
}

- (void)predictionFromFeatures:(SCEarLandmarkingInput *)input completionHandler:(void (^)(SCEarLandmarkingOutput * _Nullable output, NSError * _Nullable error))completionHandler {
    [self.model predictionFromFeatures:input completionHandler:^(id<MLFeatureProvider> prediction, NSError *predictionError) {
        if (prediction != nil) {
            SCEarLandmarkingOutput *output = [[SCEarLandmarkingOutput alloc] initWithNormed_coordinates_yx:(MLMultiArray *)[prediction featureValueForName:@"normed_coordinates_yx"].multiArrayValue];
            completionHandler(output, predictionError);
        } else {
            completionHandler(nil, predictionError);
        }
    }];
}

- (void)predictionFromFeatures:(SCEarLandmarkingInput *)input options:(MLPredictionOptions *)options completionHandler:(void (^)(SCEarLandmarkingOutput * _Nullable output, NSError * _Nullable error))completionHandler {
    [self.model predictionFromFeatures:input options:options completionHandler:^(id<MLFeatureProvider> prediction, NSError *predictionError) {
        if (prediction != nil) {
            SCEarLandmarkingOutput *output = [[SCEarLandmarkingOutput alloc] initWithNormed_coordinates_yx:(MLMultiArray *)[prediction featureValueForName:@"normed_coordinates_yx"].multiArrayValue];
            completionHandler(output, predictionError);
        } else {
            completionHandler(nil, predictionError);
        }
    }];
}

- (nullable SCEarLandmarkingOutput *)predictionFromInputs__image_tensor__0:(CVPixelBufferRef)inputs__image_tensor__0 error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    SCEarLandmarkingInput *input_ = [[SCEarLandmarkingInput alloc] initWithInputs__image_tensor__0:inputs__image_tensor__0];
    return [self predictionFromFeatures:input_ error:error];
}

- (nullable NSArray<SCEarLandmarkingOutput *> *)predictionsFromInputs:(NSArray<SCEarLandmarkingInput*> *)inputArray options:(MLPredictionOptions *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    id<MLBatchProvider> inBatch = [[MLArrayBatchProvider alloc] initWithFeatureProviderArray:inputArray];
    id<MLBatchProvider> outBatch = [self.model predictionsFromBatch:inBatch options:options error:error];
    if (!outBatch) { return nil; }
    NSMutableArray<SCEarLandmarkingOutput*> *results = [NSMutableArray arrayWithCapacity:(NSUInteger)outBatch.count];
    for (NSInteger i = 0; i < outBatch.count; i++) {
        id<MLFeatureProvider> resultProvider = [outBatch featuresAtIndex:i];
        SCEarLandmarkingOutput * result = [[SCEarLandmarkingOutput alloc] initWithNormed_coordinates_yx:(MLMultiArray *)[resultProvider featureValueForName:@"normed_coordinates_yx"].multiArrayValue];
        [results addObject:result];
    }
    return results;
}

@end
