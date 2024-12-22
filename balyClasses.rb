#Before making classes, we initialize constants that we will use throughout the program
# since each other file will load this one, all the files will have access to these 
# These constants may need to be updated, and should periodically be checked for accuracy
# These constants currently are, in order:
#   AcceptableAlphanumerics
#   Alphabet
#   BalyMaxNum

# This is the root file of the Baly Project Code, and is loaded into every more complex file. 
# Thus any functions or methods added should be fully included here and not loaded into more complex files.
# The full file dependency is as follows:
# balyClasses => prettyCommonFunctions => indexConverter => kmlParser => indexOps => autoMethods
#
# It should be noted that classificationData.rb is only a data store that is automatically loaded by indexConverter



#This is an array of all the alphanumerics that make up the Baly classification system
AcceptableAlphanumerics=[
    #Authentic (created by Baly):
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","R","S","T","U","V","W","X","Y","Z",
    "AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ","AK","AL","AM","AN","AO","AP","AQ","AR","AS","AT","AU","AV","AW","AX","AY","AZ",
    "BA","BB","BC","BD","BE","BF","BG","BH","BI","BJ","BK","BL","BM","BN","BQ","BR","BS","BT","BU","BV","BW","BX","BY","BZ",
    "CA","CB","CC","CD","CE","CF","CG","CH","CI","CJ","CK","CL","CM","CN","CO","CP","CQ","CR","CS","CT","CU","CV","CW","CX","CY","CZ",
    "DA","DB","DC","DD","DE","DF","DG","DH","DI","DJ","DK","DL","DM","DN","DO","DQ","DR","DS","DT","DU","DV","DW","DX","DY","DZ",
    "EA","EB","EC","ED","EE","EF","EH","EJ","EK","EM","EN","EJB",
    #Artificial (created for unnumbered slides):
    "FL", #created to categorize the 88 slides at the end of B47 (stands for Fill)
    "XE", #created to allow production of trivial results for numbers VRC index skips. (stands for Non-Existent)
   "GB", # an unnumbered collection starting at B46.561
   "LK",
   "UC", # a collection for slides that were never assigned Baly numbers
   #tests
   "ZZ",
   "AAA"
]
#the next one is an array of all possible alphanumerics up to QZ. This is used for sorting but includes lots of collections Baly didn't use

Alphabet=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
#The next constant records the highest number assigned across all the Baly collections.
# the current highest is in DN at 137. If a higher one is found, change this.
BalyMaxNum=137


#We start with our Error classes, which will allow us to identify
# specific issues and direct how to best resolve them
class ClassificationError < StandardError
end

class PrefixError < ClassificationError
end

class SuffixError < ClassificationError
end

class SortError < StandardError
end

class String
    def is_integer?
        self.to_i.to_s == self
    end

    def is_float?
        self.to_f.to_s == self
    end
    
    def lfullstrip
        temp=self.cleanSpaces
        if temp.length > 0
            while temp[0].codepoints[0]==32 or temp[0].codepoints[0]==160
                temp=temp[1..-1]
                if temp.length < 1
                    return temp  
                end
            end
        end
        return temp
    end
    def rfullstrip
        temp=self.cleanSpaces
        if temp.length > 0
            while temp[-1].codepoints[0]==32 or temp[-1].codepoints[0]==160
                temp=temp[...-1]
                if temp.length < 1
                    return temp  
                end
            end
        end
        return temp
    end
    def fullstrip
        temp=self
        temp=temp.lfullstrip
        temp=temp.rfullstrip
        return temp
    end
    def alphValue
        temp=self
        length=temp.length
        sum=0
        length.times {|i| 
            exp=length-(i+1)
            place=temp[i]
            val=Alphabet.index(place)+1
            sum=sum+val*(26**exp)
        }
        return sum
    end

    def cleanSpaces
        # Define a regex pattern to match non-standard space characters
        non_standard_spaces = /[\u00A0\u2000-\u200B\u202F\u205F\u3000]/
        # Use gsub to replace non-standard spaces with standard spaces
        self.gsub(non_standard_spaces, ' ')
    end
end

class Array
    def includesAtIndex(string)
        string=string.downcase
        indexes=Array.new
        current=0
        self.each do |el|
            el=el.to_s
            if el.downcase.include? string
                indexes.push current
            end
            current+=1
        end
        return indexes
    end
    def includesCaseAtIndex(string)
        indexes=Array.new
        current=0
        self.each do |el|
            if el.include? string
                indexes.push current
            end
            current+=1
        end
        return indexes
    end
end

class Hash
    def invertible?
        return self.invert.size==self.size
    end
end

#The slide class is our main class, representing the info for a single slide. The goal is to have automated processes 
#read some data format, sort the data into the class variables, where it can be easily retrieved by some other form.
#we begin with methods specific to the slide class, and then we create subclasses for some of the more intricate data,
#such as classifications and locations.
class Slide
    #slides are created with indexings, either from the VRC or Baly Systems. 
    #There are some checks, but indexings should be verified before being passed to this.
    def initialize(indexing)
        #the first thing we do with our indexing string is create a classification object for it
        @input=indexing
        id=Classification.new(indexing)
        #we then determine which system it uses, and log it under that class variable.
        if id.classSystem == "Baly"
            @Balyid=id
            @VRCid=0
        elsif id.classSystem== "VRC"
            @Balyid=0
            @VRCid=id
        end
        #finally we create the rest of our class variables and leave them blank.
        #they will need to be added separately
        @title=0
        @indexwriting=String.new
        @generalLocation=0
        @specificLocation=0
        @descriptionNotes=0
        @city=0
        @region=0
        @country=0
    end
    #accessor methods
    def balyGroup()
        return @Balyid.group()
    end
    def VRCGroup()
        return @VRCid.group()
    end
    #For this accessor, we accept the choice of which indexing is returned.
    #if a choice is not made, we default to the non-zero one or Baly ID 
    def getindex(system="none")
        if system == "Baly"
            return @Balyid
        elsif system == "VRC"
            return @VRCid
        else
            [@Balyid,@VRCid].each do |id|
                if id != 0
                    return id
                end
            end
        end
    end

    def getSortNum()
        return @Balyid.sortingNumber
    end

    def getCoordinates()
        if @specificLocation == 0
            if @generalLocation == 0
                return "None"
            else
                return @generalLocation.coords
            end
        else
            return @specificLocation.coords
        end
    end
    
    def getGeodata
        return [@city,@region,@country]
    end
    def title()
        return @title
    end
    def indexwriting()
        return @indexwriting
    end
    def generalLocation()
        return @generalLocation
    end
    def specificLocation()
        return @specificLocation
    end
    def descriptionNotes()
        return @descriptionNotes
    end

    #with all our accessor methods created, we move to mutator methods

    #the first one adds the ID that was not used to create the slide. IDs cannot be changed once they are given.
    def addAltID(input)
        if input.class != Classification
            id=Classification.new(input)
        else
            id=input
        end
        if id.classSystem == "Baly"
            if @Balyid==0
                @Balyid=id
            else
                raise StandardError.new "This slide has already been given a Baly ID. Once identification numbers are given, they cannot be changed."
            end
        elsif id.classSystem== "VRC"
            if @VRCid==0
                @VRCid=id
            else
                raise StandardError.new "This slide has already been given a VRC ID. Once identification numbers are given, they cannot be changed."
            end
        end
    end

    #the next mutator adds a location. Locations need to be carefully formatted, parsed into an array containing the coordinate tuple
    #and whatever words accompany it. If it is specific, the array can be followed by a 'true', and if you would like to override an
    #existing location another 'true' must follow. If you are overriding a general location, use (array,false,true).
    def addLocation(locationArray,specific=false,replace=false)
        #we begin by checking if there is already a location assigned to this slide, and whether we are authorized to replace it
        prevLocations=[@generalLocation,@specificLocation]
        if replace == false and prevLocations != [0,0]
            #if not, we check specific cases to identify if there is actually a problem. If there is, we throw an error
            if specific == false and prevLocations[0] != 0
                raise StandardError.new "This slide, classified #{@input} already has a general location, if you would like to override it, change the \'replace\' variable in the function call"
            elsif specific == true and prevLocations[1] != 0
                raise StandardError.new "This slide, classified #{@input} already has a specific location, if you would like to override it, change the \'replace\' variable in the function call"
            end
        end
        #now that we are definitely authorized to change our class variables, we do exactly that. 
        #The locationArray is passed straight through to the appropriate location constructor
        if specific == false
            @generalLocation=GeneralLocation.new(locationArray)
        elsif specific == true
            @specificLocation=SpecificLocation.new(locationArray)
        end
    end
    def addTitle(title)
        @title=title
    end
end

#the following class parses and stores a classification number.
# The current class variables are:
#       input: Whatever input was used in the init function
#       group: The subcollection the number is a part of (B## or Alphanumeric)
#       number: The number in that collection, stored as an integer
#       stringform: The    
class Classification
    #we create a classification using either a string ("B43.001") or an array(["B43",1])
    def initialize(classnumber)
        #First we check that the input actually contains the proper syntax for a classification.
        #As you might expect, we check separate conditions for strings and arrays.
        #If the input is readable, we parse it into class variables.
        if classnumber.class == String and classnumber.include?(".")
            @input=classnumber
            (@group,rightside)=classnumber.split(".")
            @number=rightside.to_i
        elsif classnumber.class == Array and classnumber.length == 2
            @input=classnumber
            (@group,@number) = classnumber
        else #if the input is not readable, we print a warning, and raise an error
            raise ClassificationError.new "'#{classnumber}' is not a valid Classification object"
        end
        stringnum=@number.to_s
        while stringnum.length < 3
            stringnum = '0'+stringnum
        end
        @stringform=@group+'.'+stringnum
        #the next part will make an attempt to identify the classification system. 
        # we already have a function that will do this, getCatType, but this is too bulky to be 
        # automatically called each time. This version is weaker, but quicker.
        if @group[0] == "B" and @group[-1].is_integer?
            @classSystem= 'VRC'
        elsif AcceptableAlphanumerics.include? @group
            @classSystem= "Baly"
        else
            raise PrefixError.new "The Prefix #{@group} does not match any recorded collection. 
            Check for typos in your entry or amend AcceptableAlphanumerics"
        end
        if @classSystem == "Baly" and @number > BalyMaxNum
            raise SuffixError.new "The number #{@number} is higher than any recorded element in the Baly indexing system.
            Check for typos in your entry or change the constant BalyMaxNum"
        end 
    end
    #accessor methods
    def group()
        return @group
    end
    def number()
        return @number
    end
    def sortingNumber()
        if self.classSystem != "Baly"
            return 0
        end
        decimalgroup=self.group.alphValue
        groupvalue=decimalgroup*1000
        numvalue=self.number
        if numvalue > 1000
            raise StandardError "Baly Classification dont have #{numvalue} slides. If there's one that does, overhaul the whole system ig :/"
        end
        sortingnum=groupvalue+numvalue
        return sortingnum
    end

    def stringNum()
        num=@number.to_s
        while num.length < 3
            num= "0"+num
        end
        return num
    end
    def to_s()
        return @stringform
    end
    def classSystem()
        return @classSystem
    end
    #other methods
    #this method is a quick way to check whether something is in a range. 
    #It specifically uses the format of ranges found in B47hash, in classificationData.rb
    def inRange?(range)
        #if the range is more than one slide, it will have a dash
        if range.include? "-"
            #rather than generate the whole range as a list, we see if it is between the range limits
            (leftside,rightside)=range.split("-")
            (rgroup,lownum)=leftside.split(".")
            if lownum.length<3
                hundreds= '0'
            else
                hundreds=lownum[0]
            end
            start=lownum.to_i
            if rightside.length < 3
                rightside=hundreds+rightside
            end
            last=rightside.to_i
            if @number >= start and @number <= last and @group == rgroup
                return true
            else
                return false
            end
        else #if it is a single slide, we check if it is the right slide
            return self.to_s == Classification.new(range).to_s
        end
    end
end
#This class stores general locations, either for a range or for a single slide. 
#The input variable must be of the form [[latitude,longitude],name], where name is the object of the photo (title of the map entry)
class Location
    #accessor methods
    def coords()
        return [@latitude,@longitude]
    end
    def notes()
        return @notes
    end
    #other methods
    def parseLocationArray(input)
        tuple=input[0]
        data=input[1]
        arrlength=input.length
        #these class variables are optional, so we set them inside condition
        if arrlength > 2
            notes=input[2]
            if arrlength > 3
                title=input[3]
            else
                title= ""
            end
        else
            notes= ""
        end
        (latitude,longitude)=tuple
        return [latitude,longitude,data,notes,title]
    end
end
class GeneralLocation < Location
    def initialize(input,range=0)
        #first we parse the location input into class variables.
        (@latitude,@longitude,@name,@notes,extra)=parseLocationArray(input)
        range=Array.new
    end
    #accessor methods
    def name()
        return @name
    end
    def range()
        if @range!=0
            return @range
        end
    end
    #mutator methods
    def applyToRange(range)
        @range.push range
    end
end
#This class stores a specific location. These must always have an angle, and should also include a precision qualifier.
# if there is no precision qualifier, "exact" is presumed. input must be of the form [[latitude,longitude],data],
# where data is a string like "approximate location at 15 degrees N"
class SpecificLocation < Location
    #we use a similar array to general locations, except we have angle and precision data in place of the name
    def initialize(input)
        (@latitude,@longitude,data,@notes,@title)=parseLocationArray(input)
        if data.class==String
            attributes=getAttributesFromString(data)
        elsif data.class==Array
            attributes=data[0..-1]
        end
        @angle=Angle.new(attributes[0],self)
        @precision=attributes[1]
    end
    def precision()
        return @precision
    end
    def angle()
        return @angle
    end
    def title()
        return @title
    end
    def getAttributesFromString(stringin)
        stringin=stringin.downcase
        if stringin.include?(" at ")
            (precisiondata,angledata)=stringin.split(" at ")
            #print precisiondata,angledata
        elsif stringin.include?(" facing ")
            (precisiondata,angledata)=stringin.split(" facing ")
        else
            precisiondata= ""
            angledata=stringin
        end
        if precisiondata.include? "location"
            precision=precisiondata.split(" ")[0]
        else
            precision= "exact"
        end
        if angledata.class == NilClass
            raise StandardError.new "input #{stringin} could not be parsed"
        end
        if angledata.include? "degrees"
            angle=angledata
        elsif angledata.include? "up"
            angle= "up"
        elsif angledata.include? "down"
            angle= "down"
        else
            raise StandardError.new "No angle information was given, so this location cannot be specific."
        end
        return [angle,precision]
    end
    
    class Angle
        def initialize(stringin,parent)
            #@parent=parent
            if ["up","down"].include? stringin
                (@degrees,@direction)=[-1,stringin]
            else
                elements=stringin.split(" ")
                if elements.length < 3 
                    raise StandardError.new "Attribute missing for location titled: '#{parent.title}'"
                end
                (degrees,middle,@direction)=elements
                @degrees=degrees.to_i
                if middle != "degrees"
                    raise StandardError.new "word 'degrees' not found/misplaced in angle data for location titled: '#{parent.title}'"
                end
            end
        end
        def degrees()
            return @degrees
        end
        def direction()
            return @direction.upcase
        end
        def to_s()
            return @degrees.to_s+" degrees "+@direction.upcase
        end
    end
end

sampleLocation=[[-2.27677,51.2792093],'estimated location at 70 degrees E']
#specificLocation=SpecificLocation.new(sampleLocation)

class Subcollection
    def initialize(collection)
        if meetsformat?(collection)
            (@group,@subgroup)=collection.split(".")
        end
    end 
    def meetsformat?(input)
        returnbool = false
        if input.class != String
            raise StandardError.new "Input: #{input} is not a string. A string is required to initialize the Subcollection class"
        end
        if input.include? "."
            parts=input.split "."
            if parts[0].length < 4 
                if parts[0][0].is_integer?
                    raise StandardError.new "The collection #{parts[0]} is unable to be parsed. If there is ever a collection beginning with an integer, remove this condition"  
                else
                    if parts[1].length != 1 or parts[1].is_integer? == false
                        raise StandardError.new "The subcollection input value (after the point) for input #{input} can only be one integer"
                    else
                        returnbool = true
                    end
                end
            else
                raise StandardError.new "Collection #{parts[0]} could not be read. There is no known collection with more than 3 characters. If this is no longer the case, remove this condition."
            end
        else
            raise StandardError.new "Subcollection input #{input} does not include a period, and cannot be parsed"
        end
        return returnbool
    end
    def to_s()
        return @group+"."+@subgroup
    end
    def group()
        return @group
    end
    def hundreds()
        return @subgroup
    end
    def addone() 
        if isVRC?
            subgroup=@subgroup.to_i
            unless subgroup == 9
                newsubgroup = subgroup+1
                @subgroup=newsubgroup.to_s
            else
                group = @group
                groupnumber=group[1..].to_i
                groupnumber+=1
                @group= "B"+groupnumber.to_s
                @subgroup= "0"
            end
        else
            value = @group.alphValue
            startindex = AcceptableAlphanumerics.index @group
            @group = AcceptableAlphanumerics[startindex+1]
        end
    end
    def isVRC?()
        if @group[0]== "B" and @group[-1].is_integer?
            return true
        else
            return false
        end
    end
end

