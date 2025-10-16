# Day 7: Type Constraints in Terraform

## Topics Covered
- String, number, bool types
- Map, set, list, tuple, object types
- Type validation and constraints
- Complex type definitions

## Key Learning Points

### Basic Types
1. **string** - Text values
2. **number** - Numeric values (integers and floats)
3. **bool** - Boolean values (true/false)

### Collection Types
1. **list(type)** - Ordered collection of values
2. **set(type)** - Unordered collection of unique values
3. **map(type)** - Key-value pairs with string keys
4. **tuple([type1, type2, ...])** - Ordered collection with specific types for each element
5. **object({key1=type1, key2=type2, ...})** - Structured data with named attributes


### Common Type Patterns

1. **Environment-specific configurations**
2. **Resource sizing based on type**
3. **Tag standardization**
4. **Network configuration validation**
5. **Security policy enforcement**

## Best Practices

1. **Always specify types** for variables
2. **Use validation blocks** for business rules
3. **Provide meaningful error messages**
4. **Use appropriate collection types** (list vs set vs map)
5. **Validate complex objects** thoroughly
6. **Use type conversion functions** when needed
7. **Document type requirements** in descriptions

## Next Steps
Proceed to Day 8 to learn about Terraform meta-arguments including count, for_each, and for loops for dynamic resource creation.
