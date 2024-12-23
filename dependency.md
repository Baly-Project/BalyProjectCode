# Project Dependencies

This document outlines the dependencies between Ruby files and functions within the project. Understanding these dependencies is crucial for maintaining and updating the codebase, especially when migrating to a new Ruby version or making changes to the base files. Full usage documentation is contained in [README.md](README.md)

## External Dependencies
- `'json'` gem
- `'spreadsheet'` gem


## File: `autoMethods.rb`

- **Description** Contains the top-level functions regularly accessed by the user.

#### Functions
- #### `mapKMLtoXLS`
  - **Dependencies**: 
    - Calls `stripInfo` from `kmlParser.rb` to process the input KML file.
    - Calls `writeToXlsWithClass` from `kmlParser.rb` to write the processed data to an XLS file.
  - **Description**: Converts a KML file into an XLS file. The function can operate in different modes, such as "CatNum" for categorized numbers or "straight" for direct transcription.

- #### `addSortingNumbers`
  - **Dependencies**: 
    - Calls `readXLScolumn` from `bIndexOps.rb` to read data from an Excel file.
    - Calls `generateSortingNumbers` from `autoMethods.rb` to create sorting numbers based on the input data.
    - Calls `writeXLSfromArray` from `bIndexOps.rb` to write the sorting numbers and indexes to an Excel file.
  - **Description**: Reads data from an Excel file, generates sorting numbers, and writes the results to another Excel file.

- #### `fillJSON`
  - **Dependencies**: 
    - Calls `parseNestedEndpoints` from `autoMethods.rb` to parse nested endpoints from MetaFields.
    - Calls `readIndexData` from `bIndexOps.rb` to read data from an index file.
    - Calls `writeJSON` from `bIndexOps.rb` to write JSON data.
    - Calls `generateUniqueFilename` from `prettyCommonFunctions.rb` to create a unique filename.
    - Calls `writeXLSfromRowArray` from `bIndexOps.rb` to write data to an Excel file.
  - **Description**: Processes index data, adds JSON information, and writes the updated data to an Excel file.

  
- #### `fillImageNotes`
  - **Dependencies**: 
    - Calls `readIndexData` from `bIndexOps.rb` to read data from an index file.
    - Calls `writeImageNotes` from `bIndexOps.rb` to generate image notes based on input data.
    - Calls `generateUniqueFilename` from `autoMethods.rb` to create a unique filename.
    - Calls `writeXLSfromRowArray` from `bIndexOps.rb` to write data to an Excel file.
  - **Description**: Processes index data to add image notes and writes the updated data to an Excel file.

## File: `json_sample.rb`
- **Description** Defines a class that generates JSON files that mirror the output of the Digital Kenyon api. This can be used to generate mock json directly from the spreadsheet data, which can then be moved to balyInterface/methodTesting and simulate updates.

### Gems
- `'json'`

### Constants
- `RequiredJSON` This hash contains all the JSON data that is provided by Digital Kenyon that is not supplied from the spreadsheet. This includes mostly fixed info, but some variables that are not predictable. Everything in the hash is passed as fixed data to all JSON output.
- `OptAPIfields` This hash connects the fields on Digital Kenyon to the column header identifiers. In other words, it defines the structure of the variable JSON data and tells the program where to find each field in the spreadsheet.

### Functions
All of the following functions are methods for the JsonSample class.
- #### `generateAPIoutput`
  - **Dependencies**
    - Calls `parseNestedEndpoints` ([link](#parsenestedendpoints)) to generate a list of the fields in `OptAPIfields` that need to be accessed from the spreadsheet.
    - Calls `readIndexData` ([link](#readindexdata)) to generate an array of row hashes containing the spreadsheet data.
    - Calls `generateOptHash` ([link](#generateopthash)) to insert the rowhash data into the structure defined in `OptAPIfields`. 
    - Calls `fixApiDiscrepancies` ([link](#fixapidiscrepancies)) to adjust the JSON to match specific formats produced by Digital Kenyon
  - **Description** 
    This function is the main one for creating the JSON data, and from an input xls file creates a JSON object that mirrors a query result from the Digital Kenyon api.
- #### `fixApiDiscrepancies`
  - **Dependencies**
    - Calls the string methods `fullstrip` ([link](#fullstrip)) and `is_integer?` ([link](#isinteger)) defined in `balyClasses.rb` to format data into the unique Digital Kenyon date format.
  - **Description**
  Modifies the JSON representation of a single record to match specific formatting produced by Digital Kenyon.
- #### `saveAPIsample`
  - **Dependencies**
    - Calls `generateUniqueFilename` ([link](#generateuniquefilename)) from `bIndexOps.rb` 
## File: `bIndexOps.rb`

- **Description** Contains operations to be used on the Baly Index. An input file for these functions must be an Excel 97-2003 Worksheet (.xls) and must include the header row of the Baly Slide Index Google Sheet. Then the full rows of the Index to be processed can be pasted below. 
### Gems
- `'json'`

### Constants
- **`DefaultFields`** An array containing unique identifiers of each of the header rows in the Baly Slide Index Google Sheet. It need only include the ones used by functions in this file, but we must ensure that these strings are not found in any other header cells.

- **MetaFields** A nested hash showing the desired structure of generated JSON data. The bottom level contains a hash showing the header row identifiers from DefaultFields where specific data can be found.

- **SampleRowHash** A sample of the hashes produced for each row of the input spreadsheet. These are typically created by the readIndexData function, but a sample allows us to test methods reliably.

- **RequiredJSON** A hash containing all the JSON data from digital kenyon that cannot be 

### Class Extensions
- #### Polymorphic
    The following methods are defined for multiple classes, allowing them to be used at all levels of nested Arrays and Hashes containing strings.
  - #### `fillable?` 
    Method for Hashes, Arrays, and Strings. Tests whether the object is the last level of nesting, ie. when it contains only strings. For strings it always returns false.
  - #### `addUnlessEmpty`
    Method for Arrays and Hashes to add a value/key-value to the object provided that the value has length greater than 0.
- #### Hash
  - #### `addUnlessEmpty` 
    Inserts a key-value pair into the hash unless the value passed has length equal to zero.

  - #### `fillable?` 
    Returns a boolean of whether both the keys and values of the hash are fillable using the `Array#fillable?` command defined below.
- #### Array
  - #### `fillable?` 
    Tests whether the array is entirely composed of strings (ie. there are no nested objects inside)
  - #### `addUnlessEmpty`
    Pushes an element to the array if the elements length is greater than 0.
  - #### `cleanDash` 
    Removes a `'-'` element from the start of the array. Used to empty arrays that come from dashed cells in the Baly Slide Index Google Sheet.
  - #### `cleanWhitespace` 
    Uses the `String#fullstrip` method defined in `balyClasses.rb` to clean leading and trailing whitespace from each element of the array. Includes an option to remove elements that are empty after whitespace removal (default removes them).
- #### String
  - #### `fillable?`
    Always returns false. It is defined for the String class to keep polymorphism when iterating through nested objects.
  - #### `hyperlink?`
    Tests whether the string matches the format for a viable hyperlink.

### Functions
- #### `formatReferences`
  - **Dependencies**
    - Calls `readIndexData` to read the "References" column of the input spreadsheet.
    - Calls `hyperlink?` string method on each word of the reference to identify links.
    - Calls `generateUniqueFilename` from `prettyCommonFunctions.rb` to make the output file name.
    - Calls `writeXLSfromRowArray`[jump to](#writexlsfromrowarray) to create a new spreadsheet with the generated data
  - **Description**
  Reads an input spreadsheet and formats the references into html. This includes placing each reference in a <p> element and formatting links appropriately.

- #### `writeJSON`
  - **Dependencies**
    - Calls `generateReqHash` ([link](#generatereqhash)) and `generateOptHash` ([link](#generateopthash)) to make a nested data object made of arrays, hashes, and strings.
    - Calls `'json'` gem to transform this nested object into JSON
  - **Description**
  Writes JSON for a single row of the spreadsheet. Uses a rowhash object produced by `readIndexData`.
- #### `generateOptHash`
  - **Dependencies**
    - Calls `fillable?` ([link](#fillable)) at each level of the MetaFields hash to find the last level.
    - Calls `fillFromRow` ([link](#fillfromrow)) to complete last-level hashes using the rowhash.
    - Calls `addUnlessEmpty` ([link](#addunlessempty)) to add the filled row into the nested structure.
  - **Description**
    Iterates through the MetaFields hash to fill it with data from the rowhash object produced by `readIndexData`. Returns a nested object that matches the structure of MetaFields.
- #### `fillHashFromRow`
  - **Dependencies**
    - Calls `fullstrip?` method on strings from `balyClasses.rb` to detect dashed data inside the rowhash object
  - **Description**
    Uses conventions to read a bottom-level hash inside MetaFields and supply the necessary fixed and variable data. Variable data comes from the rowhash object produced by ReadIndexData
- #### `fillArrayFromRow`
    Mirrors the `fillHashFromRow` function to fill an end level array in the MetaFields hash.
- #### `generateReqHash`
  - **Dependencies**
    - Calls `parseWrittenDates` ([link](#parsewrittendates))to format a string date into an array of day, month, and year.
    - Calls `parsePrintedDates` ([link](#parseprinteddates)) to format a stamped date into an array containing the month and year.
    - Calls `addUnlessEmpty` ([link](#addunlessempty)) to assemble data into a larger structure. 
    - Calls the `cleanWhitespace` ([link](#cleanwhitespace)) array method to remove extra whitespace from arrays derived from rowhash items.
    - Calls the `cleanDash` ([link](#cleandash)) array method to remove dashes marking missing data from the arrays derived from rowhash objects.
    - Calls `parseSlideRange` ([link](#parsesliderange)) from `prettyCommonFunctions.rb` to properly format a comma separated list of old IDs
    - Calls `is_integer?` ([link](#isinteger)) and `fullstrip` string methods from `balyClasses.rb` to process strings from the rowhash object.
  - **Description**
    Generates a nested hash containing data that cannot be pulled straight from the rowhash object (dates, links, keywords, etc.).
- #### `parseNestedEndpoints`
  - **Description** 
  This standalone function reads the nested hash MetaFields and locates the items that need to be collected by the readIndexData function. It returns a custom error function (passed as a parameter) when it detects that the given nested hash is improper. This raises an error early before other functions like `generateReqHash` process it.
- #### `assembleKeywords
  - **Dependencies**
    - Calls `readIndexData`([link](#readindexdata)) to pull data from an input spreadsheet.
    - Calls the `fullstrip`([link](#fullstrip)) string method to clean each keyword item
  - **Description**
    This currently unused function compiles a list/hash of the keywords passed, depending on the `includeOrigins` boolean parameter. If `includeOrigins = true`, it returns a hash pointing each keyword to the ids containing it, if not, it returns a simple array of keywords.
- #### readIndexData
  - **Dependencies**
    - Calls `'spreadsheet'` gem to open and read the input spreadsheet.
    - Calls `getFieldLocs` ([link](#getfieldlocs)) to know which spreadsheet columns contain which data
  - **Description**
    Simplifies the process of reading input spreadsheets by taking an input file, worksheet number and a string array of the column header identifiers (aka, fields) and outputting an array of rows, where each row is either a hash connecting the fields to the data, or an array just containing the data in the same order as the fields were passed.
- #### getFieldLocs
  - **Dependencies**
    - Calls the `includesAtIndex` ([link](#includesatindex)) array method from `balyClasses.rb` to identify locations of each field in the header row.
    - Calls the `includesCaseAtIndex` ([link](#includescaseatindex)) method for case-sensitive compatibility.
  - **Description**
    Takes the header row of an input spreadsheet and an array of field identifiers to look for and produces a hash connecting each field to the column that contains that data.
- #### getLocationAttributes
  - **Dependencies**
    - Calls the `geocoder` gem to automatically get city, region, and country info from geocoordinates.
  - **Description**
    This function automatically generates geographic data from geocoordinates. However, the geocoder gem has been plagued with errors and has not worked for a while. As such it has been removed from other functions. Note that even when working properly, the data it produces still needs to be checked, and regions probably will not correspond to the custom regions we have defined for the project.
- #### writeImageNotes
  - **Dependencies**
    - Calls `parseWrittenDates` and `parsePrintedDates` to format date information into arrays.
    - Calls the `Classification` class from `balyClasses.rb` for formatting the old ids.
    - Calls the `fullstrip` string method from `balyClasses.rb` to clean string data.
  - **Description**
    This function takes slide data and combines them into a formulaic paragraph, the slide's Image Notes field.
- #### parseWrittenDates
  - **Dependencies**
    - Calls the string methods `fullstrip` ([link](#fullstrip)), `is_integer?` ([link](#isinteger)), and `is_float?` from `balyClasses.rb` to separate plain year dates from month-year or day-month-year.
  - **Description**
    Parses formulaic written dates into presentable strings or arrays that make data easier to read. The formula necessary is: "January 1, 1970, January 1970, 1970" to accomodate various levels of precision. For an input of "January 1, 1970" it can return either a string: "January 1st, 1970", an array: [1,"January",1970].
- #### parsePrintedDates
  - **Dependencies**
    - Calls the `fullstrip` ([link](#fullstrip)) string method from `balyClasses.rb`
  - **Description**
    Reads a stamped date of the format that appears on the physical slides and formats it into a presentable date string or array of date info. The stamp dates have three letter month shorthands (JAN, JUL, etc) and two digit years. 
- #### writeXLSfromRowArray
  - **Dependencies**
    - Calls the `'spreadsheet'` gem to open a blank spreadsheet
    - Calls `generateUniqueFilename` from `prettyCommonFunctions.rb` to generate a filename based of the given title of the new spreadsheet.
  - **Description**
    This function simplifies the process of writing new spreadsheets by acting as a sort of inverse to `readIndexData`. It takes an array of row arrays and writes them into a new spreadsheet, with options to supply custom headers.

## File: `kmlParser.rb`
### Class Extensions
#### Slide Extensions
- ##### `addGeodata`
  - **Dependencies**
  Uses the `geocoder` gem for geographic data
  - **Description**
  Adds basic city,region, and country info from the geocoder gem. 
#### String Extensions
- ##### `hasDirection?`
  - **Description** 
  Detects whether a string has directional information keywords.
### Classes
- #### KML Class
  - **Description**
    Takes a KML file and represents the data as a series of placemarks, where each placemark is either a point or a directional line. No dependencies.
  - #### `points, lines, title`
    Accessor functions for basic data
  - #### `assembleAnglesHash`
    Makes a hash of string classifications to angle measurements from lines
  - #### Subclasses
    - ##### Placemark
      Generic class for map items, stores universal data like title, description, and coordinates, all available via accessor functions
    - ##### Point
      Specific class for point objects, which inherit all their qualities from Placemark.
    - ##### Line
      Specific class for line objects, which inherit all the qualities from Placemark, and add a function to compute the angle between its coordinates.
### Functions
- #### `writeToXlsWithClass`
  - **Dependencies**
    Uses the `spreadsheet` gem, and the [KML](#kml-class), [Slide](#slide), and [Classification](#classification-class) classes. Uses functions [`swapSlideIdentifier`](#swapslideidentifier), [`addLocationToSlide`](#addlocationtoslide), [`formatspreadsheet`](#formatspreadsheet), [`formatSlideData`](#formatslidedata),[`formatCoords`](#formatcoords) from kmlParser.rb, `parseSlideRange` and `generateUniqueFilename` from `prettyCommonFunctions.rb`, and `indexConverter` from `indexConverter.rb`.
  - **Description** 
    Large function that converts geospatial data from the KML class object to the spreadsheet object.
  - **Settings**
    - `mode`: string option either "straight" (default) or "catnum". "Straight gives a simple placemark-by placemark representation, while catnum groups by slide and groups the data of multiple placemarks.
    - `filename`: string option for custom named files. Default setting is "blank" for a randomized filename.
    - `fillBlanks`: boolean option to include all slides between the ones mentioned in the KML file. True includes blank spaces for slides that had no info added.
- #### `swapSlideIdentifier`
  - **Dependecies**
    Depends only on the [`fullstrip`](#fullstrip) string method from `balyClasses.rb`
  - **Description**
    To allow for slide identifiers to be in descriptions and titles, this function removes an identifier from the title and adds it to the description so that it can be read.
- #### `addLocationToSlide`
  - **Dependencies**
    The [Slide](#slide) class, and [`stripData`](#stripdata).
  - **Description**
    A single function to handle all location inputs to slides, it decides whether the input is a specific or general location and adds it appropriately.
- #### `stripData`
  - **Dependencies**
    [`hasDirection?`](#hasdirection) and [`is_integer?`](#is_integer) string methods
  - **Description**
    Parses angle data or notes from a point's description.
- #### `formatspreadsheet`
  - **Dependencies**
    `spreadsheet` gem.
  - **Description**
    Adds proper headings to the first row of a spreadsheet object.
- #### `formatSlideData`
  - **Dependencies**
    [Slide](#slide) class
  - **Description**
    Reads a slide and produces an array of all the relevant info in spreadsheet order.
- #### `formatCoords`
  - **Description**
    Reads an array of coordinates and returns the proper string representation
- #### `readXLScolumn`
  - **Dependencies**
    `spreadsheet` gem.
  - **Description**
    Takes a spreadsheet, worksheet number, and column number, and collects the information in that column into an array.
- #### `writeXLSfromColArray`
  - **Dependencies**
    `spreadsheet` gem, and `generateUniqueFilename`.
  - **Description**
    Takes a nested array of columns and writes the data to a spreadsheet file.

## File: `balyClasses.rb`

## Class Extensions
### String Extensions
- #### `is_integer?`
  - **Description**
    Tests whether a string is convertible to a valid integer.
- #### `is_float?`
  - **Description**
    Tests whether a string is convertible to a valid floating point number.
- #### `lfullstrip`
  - **Dependencies**
    - Calls `cleanSpaces` ([link](#cleanspaces)) to remove any nonstandard characters
  - **Description**
  Removes whitespace and non-standard space characters from left side of string
- #### `rfullstrip`
  - **Dependencies**
    - Calls `cleanSpaces` ([link](#cleanspaces)) to remove any nonstandard characters
  - **Description**
  Removes whitespace and non-standard space characters from right side of string
- #### `fullstrip`
  - **Dependencies**
    - Calls `lfullstrip` ([link](#lfullstrip)) to strip left side.
    - Calls `rfullstrip` ([link](#rfullstrip)) to strip right side.
  - **Description** 
    Strips all whitespace, including non-standard space characters from a string
- #### `alphValue`
  - **Description**
    Converts alphabetic string to numeric value based on position in alphabet

- #### `cleanSpaces`
  - **Description**
    A regex method to substitute all non-standard spaces with regular ones.
### Array Extensions
- #### `includesAtIndex`
  - **Description**
    A method to find all the indices of a given string inside an array. Returns an array of integers of each index place.
- #### `includesCaseAtIndex
  - **Description**
    A mirror of the `includesAtIndex` method, but case-sensitive.
## Classes

### Slide
- #### `initialize`
  - **Description**
    Creates new slide object from a given classification number.

- #### `balyGroup`
  - **Dependencies**
    Calls the `group` method on the slide's Classification object.

**Description**
Returns Baly group identifier

#### `VRCGroup`
**Dependencies**
- Calls the `group` method on the slide's Classification object.

**Description**
Returns VRC group identifier

#### `getindex(system=0)`
**Description**
Returns requested indexing system identifier

#### `getSortNum()`
**Dependencies**
- Calls `sortingNumber` 

**Description**
Returns sorting number for Baly system

#### `getCoordinates()`
**Description**
Returns slide coordinates from either general or specific location

#### `addAltID(input)`
**Description**
Adds alternative identification to slide

#### `addLocation(locationArray, specific=false, replace=false)`
**Description**
Adds location data to slide with validation checks

## Classification Class

#### `initialize(classnumber)`
**Description**
Creates new classification from string or array input with validation

#### `sortingNumber()`
**Dependencies**
- Calls `alphValue`

**Description**
Calculates sorting number for Baly system

#### `inRange?(range)`
**Description**
Checks if classification is within given range

## Location Class

#### `parseLocationArray(input)`
**Description**
Parses location array input into components

## GeneralLocation Class

#### `initialize(input,range=0)`
**Dependencies**
- Calls `parseLocationArray`

**Description**
Creates new general location with optional range

#### `applyToRange(range)`
**Description**
Applies location to specified range

## SpecificLocation Class

#### `initialize(input)`
**Dependencies**
- Calls `parseLocationArray`
- Calls `getAttributesFromString`

**Description**
Creates new specific location with parsed attributes

#### `getAttributesFromString(stringin)`
**Description**
Parses location attributes from string input

### Angle Class (nested in SpecificLocation)

#### `initialize(stringin,parent)`
**Description**
Creates new angle object with validation

## Subcollection Class

#### `initialize(collection)`
**Dependencies**
- Calls `meetsformat?`

**Description**
Creates new subcollection with validation

#### `meetsformat?(input)`
**Description**
Validates input format for subcollection

#### `addone()`
**Dependencies**
- Calls `isVRC?`

**Description**
Increments subcollection number with system-specific logic

#### `isVRC?()`
**Description**
Checks if collection is VRC type based on identifier format