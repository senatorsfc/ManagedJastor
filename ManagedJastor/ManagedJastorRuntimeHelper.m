#import <objc/runtime.h>
#import "ManagedJastorRuntimeHelper.h"

static const char *property_getTypeName(objc_property_t property) {
	const char *attributes = property_getAttributes(property);
	char buffer[1 + strlen(attributes)];
	strcpy(buffer, attributes);
	char *state = buffer, *attribute;
	while ((attribute = strsep(&state, ",")) != NULL) {
		if (attribute[0] == 'T') {
			size_t len = strlen(attribute);
			attribute[len - 1] = '\0';
			return (const char *)[[NSData dataWithBytes:(attribute + 3) length:len - 2] bytes];
		}
	}
	return "@";
}

@implementation ManagedJastorRuntimeHelper


static NSMutableDictionary *listByClass;
+(NSMutableDictionary*)propertyListByClass{
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        listByClass = [[NSMutableDictionary alloc] init];
    });
    return listByClass;
}

static NSMutableDictionary *classByClassAndProperty;
+(NSMutableDictionary*)propertyClassByClassAndPropertyName{
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classByClassAndProperty = [[NSMutableDictionary alloc] init];
    });
    return classByClassAndProperty;
}

+ (NSArray *)propertyNames:(Class)klass {
	if(!klass) return @[];

	NSString *className = NSStringFromClass(klass);
	if(!className) return @[];

	NSArray *value = [[ManagedJastorRuntimeHelper propertyListByClass] objectForKey:className];
	if (value) {
		return value; 
	}
	
	NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
	unsigned int propertyCount = 0;
	objc_property_t *properties = class_copyPropertyList(klass, &propertyCount);
	
	for (unsigned int i = 0; i < propertyCount; ++i) {
		objc_property_t property = properties[i];
		const char * name = property_getName(property);
		
		[propertyNames addObject:[NSString stringWithUTF8String:name]];
	}
	free(properties);
	
	[[ManagedJastorRuntimeHelper propertyListByClass] setObject:propertyNames forKey:className];
	
	return propertyNames;
}

+ (Class)propertyClassForPropertyName:(NSString *)propertyName ofClass:(Class)klass {
	NSString *key = [NSString stringWithFormat:@"%@:%@", NSStringFromClass(klass), propertyName];
	if(!propertyName || !key) return nil;

	NSString *value = [[ManagedJastorRuntimeHelper propertyClassByClassAndPropertyName] objectForKey:key];	
	if (value) {
		return NSClassFromString(value);
	}
	
	unsigned int propertyCount = 0;
	objc_property_t *properties = class_copyPropertyList(klass, &propertyCount);
	
	const char * cPropertyName = [propertyName UTF8String];
	
	for (unsigned int i = 0; i < propertyCount; ++i) {
		objc_property_t property = properties[i];
		const char * name = property_getName(property);
		if (strcmp(cPropertyName, name) == 0) {
			NSString *className = [NSString stringWithUTF8String:property_getTypeName(property)];
			if(className){
				free(properties);
				[[ManagedJastorRuntimeHelper propertyClassByClassAndPropertyName] setObject:className forKey:key];
				return NSClassFromString(className);
			}
		}
	}
	free(properties);
	return nil;
}

@end
