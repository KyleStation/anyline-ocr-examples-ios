//
//  ALTemplateIdentification.h
//  Anyline
//
//  Created by Angela Brett on 23.06.20.
//  Copyright © 2020 Anyline GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALTemplateConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALLayoutDefinition : NSObject

@property NSString *country;
@property NSString *layout;
@property NSString *type;

- (instancetype)initWithDictionary:(NSDictionary<NSString *,NSString *> *)dictionary;

@end


@interface ALTemplateIdentification : NSObject

@property (nullable, nonatomic, strong) ALTemplateFieldConfidences *fieldConfidences;
@property (nullable, nonatomic, strong) ALLayoutDefinition *layoutDefinition;

- (void)addField:(NSString *)fieldName value:(NSString *)value;
- (NSArray<NSString *> *)fieldNames;
- (NSString *)valueForField:(NSString *)fieldName;
- (BOOL)hasField:(NSString *)fieldName;
- (void)removeField:(NSString *)fieldName;

@end
NS_ASSUME_NONNULL_END
