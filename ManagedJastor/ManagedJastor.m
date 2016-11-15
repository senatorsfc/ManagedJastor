#import "ManagedJastor.h"
#import "ManagedJastorRuntimeHelper.h"

@implementation ManagedJastor

@synthesize objectId;
static NSString *idPropertyName = @"id";
static NSString *idPropertyNameOnObject = @"objectId";

Class mnsDictionaryClass;
Class mnsArrayClass;

- (void)initializeFieldsWithDictionary:(NSDictionary *)dictionary {
    if (!mnsDictionaryClass) mnsDictionaryClass = [NSDictionary class];
    if (!mnsArrayClass) mnsArrayClass = [NSArray class];
    
    NSDictionary *map = [self  map];
    
    for (NSString *key in [ManagedJastorRuntimeHelper propertyNames:[self class]]) {
        id value = [dictionary valueForKey:[map valueForKey:key]];
        Class propertyClass = [ManagedJastorRuntimeHelper propertyClassForPropertyName:key ofClass:[self class]];
        
        if (value == [NSNull null] || value == nil) continue;
        
        // handle dictionary
        if ([value isKindOfClass:mnsDictionaryClass]) {
            Class klass = [ManagedJastorRuntimeHelper propertyClassForPropertyName:key ofClass:[self class]];
            NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(klass) inManagedObjectContext:self.managedObjectContext];
            ManagedJastor *managedObject = (ManagedJastor*) [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
            [managedObject initializeFieldsWithDictionary:value];
            value = managedObject;
        }
        // handle array
        else if ([value isKindOfClass:mnsArrayClass]) {
            Class arrayItemType = [[self class] performSelector:NSSelectorFromString([NSString stringWithFormat:@"%@_class", key])];
            
            NSMutableArray* childObjects = [[NSMutableArray alloc] initWithCapacity:[value count]];
            for (id child in value) {
                if ([[child class] isSubclassOfClass:mnsDictionaryClass]) {
                    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(arrayItemType) inManagedObjectContext:self.managedObjectContext];
                    ManagedJastor *managedObject = (ManagedJastor*) [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
                    [managedObject initializeFieldsWithDictionary:child];
                    [childObjects addObject:managedObject];
                } else {
                    [childObjects addObject:child];
                }
            }
            
            [self setValue:[NSArray arrayWithArray:childObjects] forKey:key];
        }else if(propertyClass == [NSDate class] && [value isKindOfClass:[NSNumber class]]){
            //Timestamp conversion
            [self setValue:[NSDate dateWithTimeIntervalSince1970:[value longLongValue]/1000] forKey:key];
        }else{
            // handle all others
            [self setValue:value forKey:key];
        }
    }
    
    id objectIdValue;
    if ((objectIdValue = [dictionary objectForKey:idPropertyName]) && objectIdValue != [NSNull null]) {
        if (![objectIdValue isKindOfClass:[NSString class]]) {
            objectIdValue = [NSString stringWithFormat:@"%@", objectIdValue];
        }
        [self setValue:objectIdValue forKey:idPropertyNameOnObject];
    }

    return; 
}

- (void)dealloc {
    self.objectId = nil;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.objectId forKey:idPropertyNameOnObject];
    for (NSString *key in [ManagedJastorRuntimeHelper propertyNames:[self class]]) {
        [encoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        [self setValue:[decoder decodeObjectForKey:idPropertyNameOnObject] forKey:idPropertyNameOnObject];
        
        for (NSString *key in [ManagedJastorRuntimeHelper propertyNames:[self class]]) {
            id value = [decoder decodeObjectForKey:key];
            if (value != [NSNull null] && value != nil) {
                [self setValue:value forKey:key];
            }
        }
    }
    return self;
}

- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.objectId) {
        [dic setObject:self.objectId forKey:idPropertyName];
    }
    NSDictionary *map = [self map];
    
    for (NSString *key in [ManagedJastorRuntimeHelper propertyNames:[self class]]) {
        id value = [self valueForKey:key];
        if (value && [value isKindOfClass:[Jastor class]]) {
            [dic setObject:[value toDictionary] forKey:[map valueForKey:key]];
        } else if (value && [value isKindOfClass:[NSArray class]] && ((NSArray*)value).count > 0) {
            id internalValue = [value objectAtIndex:0];
            if (internalValue && [internalValue isKindOfClass:[Jastor class]]) {
                NSMutableArray *internalItems = [NSMutableArray array];
                for (id item in value) {
                    [internalItems addObject:[item toDictionary]];
                }
                [dic setObject:internalItems forKey:[map valueForKey:key]];
            } else {
                [dic setObject:value forKey:[map valueForKey:key]];
            }
        } else if (value != nil) {
            [dic setObject:value forKey:[map valueForKey:key]];
        }
    }
    return dic;
}

- (NSDictionary *)map {
    NSArray *properties = [ManagedJastorRuntimeHelper propertyNames:[self class]];
    NSMutableDictionary *mapDictionary = [[NSMutableDictionary alloc] initWithCapacity:properties.count];
    for (NSString *property in properties) {
        [mapDictionary setObject:property forKey:property];
    }
    return [NSDictionary dictionaryWithDictionary:mapDictionary];
}

- (NSString *)description {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (self.objectId) [dic setObject:self.objectId forKey:idPropertyNameOnObject];
    
    for (NSString *key in [ManagedJastorRuntimeHelper propertyNames:[self class]]) {
        id value = [self valueForKey:key];
        if (value != nil) [dic setObject:value forKey:key];
    }
    
    return [NSString stringWithFormat:@"#<%@: id = %@ %@>", [self class], self.objectId, [dic description]];
}

@end
