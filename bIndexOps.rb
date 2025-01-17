# This is a collection of operations to be used on the full Baly Index

#load necessary files
require_relative 'kmlParser.rb'
require 'json'

DefaultFields=["Title","Image ID","Written Date","Printed Date","VRC slide number","References",
"Other old identification numbers","Words written on the slide","Words written on the Baly index",
"Image Notes","Creation Year","Subcollection","City","Country","Region","latitude","longitude",
"Direction","Keywords","Re-scan","Frame # do not  record","URL"]

class Slide
  #we add a generic attribute adder that will identify the correct function to use.
  def addAttribute(attr,data)
  end
end

class Hash 
  #Inserts a key-value pair into the hash unless the value passed has length equal to zero.
  def addUnlessEmpty(key,value,removeEmpty=true)
    if value.length > 0 or removeEmpty == false
      self[key]=value
    end
  end
  # Returns a boolean of whether both the keys and values of the hash 
  # are fillable using the `Array#fillable?` command defined below.
  def fillable?
    return (self.values.fillable? and self.keys.fillable?)
  end
end

class Array
  # Boolean function that tests whether the array is entirely composed of strings 
  # (ie. there are no nested objects inside)
  def fillable?
    onlystrings=true
    if self.length > 0
      self.each do |item|
        if item.class != String
          onlystrings=false
        end
      end
    end
    return onlystrings
  end
  def addUnlessEmpty(value,removeEmpty=true)
    if value.length > 0 or removeEmpty == false
      self.push value
    end
  end
  def cleanDash()
    if self[0].class==String
      if self[0].fullstrip == "-"
        self.delete(self[0])
      end
    end
  end
  def cleanWhitespace(removeBlanks=true)
    cleaned=Array.new
    self.each do |raw|
      if raw.class == String
        cleaned.addUnlessEmpty(raw.fullstrip,removeBlanks)
      end
    end
    return cleaned    
  end
end

class String
  def fillable?
    return false
  end

  def hyperlink?
  string=self
  # Regular expression to match a viable hyperlink
  regex = /\A(http|https):\/\/[^\s$.?#].[^\s]*\z/i
  # Check if the string matches the regular expression
  !!(string =~ regex)
  end
end
class InputError < StandardError
end

def formatReferences(xlsfile='input.xls')
  fields=["References","HTML formatted"]
  begin
    data=readIndexData(xlsfile,0,fields,"Array")
  rescue
    data=readIndexData(xlsfile,0,["References"],"Array")
  end

  htmlArray=Array.new
  data.each do |row|
    newrow=[row[0]]
    print row[0]
    print "\n"
    eachref=String.new
    row[0].split(" ; ").each do |firstitem|
      firstitem.split(" , ").each do |item|
        eachitem= "<p>"
        item.split(" ").each do |word|
          thisword=String.new
          if word.hyperlink?
            thisword = "<a href='#{word}'> #{word} </a>"
          else
            thisword = word
          end
          eachitem+= " "+thisword
        end
        eachitem+=" </p>"
        eachref+=eachitem
      end
    end
    newrow.push eachref
    htmlArray.push newrow
  end

  newfilename=generateUniqueFilename("HtmlReferenced","xls")
  writeXLSfromRowArray(newfilename,htmlArray[1..],fields)
end

#First a hash of metadata fields and how to find them in the spreadsheet.
#Dates, old numbers, and keywords are fixed since they require parsing. 
#Fields listed below are pulled from the spreadsheet with no modification.
#It is very important that once objects are "fillable" there is no further nesting.
#Both hashes and forms can be filled, but a hash/array must be fully fillable or fully structure.
#Overlooking this will cause swaths of the structure to drop out. See the testingData file for examples.
#  NOTE: The references to the spreadsheet headers are case sensitive
MetaFields={"locations"=> [{"title"=>"General Location Name",
                            "type"=>"=general",
                            "coordinates"=>"General Coordinates"
                          },
                          {"type" => "=object",
                            "latitude" => "Object Latitude",
                            "longitude" => "Object Longitude"
                          },
                          {"title"=>"Specific Location Name",
                            "type"=>"=specific",
                            "coordinates" => "Specific Coordinates",
                            "precision" => "Precision",
                            "angle" => "Direction"}
                         ],
            "notes" => {"slide_notes" => "written on the slide",
                        "index_notes" => "written on the Baly index"}
}
SampleRowHash={"Image ID"=>"A.002","Written Date"=>"June 1970",
"Printed Date"=>"JUL 70N","old identification numbers"=>"A.19,A.22,A.04",
"Keywords"=>"Dome of the Rock, Temple Mount, Haram al-Sharif, Holy Esplanade, Old City of Jerusalem, Jerusalem",
"General Location Name"=>"Dome of the Rock","General Coordinates"=>"(31.7779279,35.2352684)",
"Specific Location Name"=>"Dome of the Rock Through Western Arch","Specific Coordinates"=>"(31.7778467,35.2346017)",
"Precision"=>"likely","Direction"=>"70 degrees E","Object Latitude"=>"35.2354 E","Object Longitude"=>"31.7780 N",
"written on the slide"=>"Isfahan, Friday Mosque ","written on Baly Index"=>"Friday Mosque "
}                

def writeJSON(rowHash,removeEmpty)
  require 'json'
  required=generateReqHash(rowHash,removeEmpty)
  optional=generateOptHash(rowHash,removeEmpty)
  assembled=required.merge optional
  return JSON.generate assembled
end

#the following function allows filling in an arbitrary structure form up to three levels deep.
#  In the function, value refers to the hash value or array element at a given level (value1,value2)
#  Corresponding to these are val(1..3) and vals(1..3) which refer to the filled object at each level
def generateOptHash(rowHash, removeEmpty=false, structure=MetaFields)
  optHash=Hash.new
  structure.each do |bigkey,value1|
    if value1.fillable?
      xVal1=fillFromRow(value1,rowHash,removeEmpty)
      optHash.addUnlessEmpty(bigkey,xVal1,removeEmpty)
    elsif value1.class == Array
      aVals1=Array.new
      value1.each do |value2|
        if value2.fillable?
          axVal2=fillFromRow(value2,rowHash,removeEmpty)
          aVals1.addUnlessEmpty(axVal2,removeEmpty)
        elsif value2.class == Array
          aaVals2=Array.new
          value2.each do |value3|
            if value3.fillable?
              aaxVal3 = fillHashFromRow(value3,rowHash,removeEmpty)
              aaVals2.addUnlessEmpty(aaxVal3,removeEmpty)
            end
          end
          aVals1.addUnlessEmpty(aaVals2,removeEmpty)
        elsif value2.class == Hash
          ahVals2=Hash.new
          value2.each do |smkey,value3|
            if value3.fillable?
              ahxVal3=fillFromRow(value3,rowHash,removeEmpty)
              ahVals2.addUnlessEmpty(smkey,ahxVal3,removeEmpty)
            end
          end
          aVals1.addUnlessEmpty(ahVals2,removeEmpty)
        end
      end
      optHash.addUnlessEmpty(bigkey,aVals1,removeEmpty)
    elsif value1.class==Hash
      hVals1=Hash.new
      value1.each do |key,value2|
        if value2.fillable?
          hxVal2=fillFromRow(value2,rowHash,removeEmpty)
          hVals1.addUnlessEmpty(key,hxVal2,removeEmpty)
        elsif value2.class == Array
          haVals2=Array.new
          value2.each do |value3|
            if value3.fillable?
              haxVal3=fillFromRow(value3,rowHash,removeEmpty)
              haVals2.addUnlessEmpty(haxVal3,removeEmpty)
            end
          end
          hVals1.addUnlessEmpty(key,haVals2,removeEmpty)
        elsif value2.class == Hash
          hhVals2=Hash.new
          value2.each do |smkey, value3|
            if value3.fillable?
              hhxVal3=fillFromRow(value3,rowHash,removeEmpty)
              hhVals2.addUnlessEmpty(smkey,hhxVal3,removeEmpty)
            end
          end
          hVals1.addUnlessEmpty(key,hhVals2,removeEmpty)
        end
      end
      optHash.addUnlessEmpty(bigkey,hVals1,removeEmpty)
    end
  end
  return optHash
end

def fillFromRow(object,rowHash,removeEmpty=false)
  if object.class == Hash
    return fillHashFromRow(object,rowHash,removeEmpty)
  elsif object.class == Array
    return fillArrayFromRow(object,rowHash,removeEmpty)
  end
end

def fillHashFromRow(structure,rowHash,removeEmpty=false)
  filled=Hash.new
  autofilled=0
  structure.each do |key,value|
    nonempty=(rowHash[value].to_s.length > 0 and rowHash[value].to_s.fullstrip!= "-")
    if value[0]== "="
      autofilled+=1
      filled[key]=value[1..]
    elsif nonempty or removeEmpty==false 
      if rowHash[value].class == String
        filled[key]=rowHash[value]
      else
        filled[key]= "-"
      end
    end
  end
  if filled.length == autofilled and removeEmpty
    return {}
  else 
    return filled
  end
end
def fillArrayFromRow(structure,rowHash,removeEmpty=false)
  filled=Array.new
  autofilled=0
  structure.each do |value|
    nonempty=(rowHash[value].to_s.length > 0 and rowHash[value].to_s.fullstrip!= "-")
    if value[0]== "="
      autofilled+=1
      filled.push value[1..]
    elsif nonempty or removeEmpty==false
        if rowHash[value].class == String
        filled.push rowHash[value]
      else
        filled.push "-"
      end
    end
  end
  if filled.length == autofilled and removeEmpty
    return []
  else
    return filled
  end
end
def generateReqHash(rowHash,removeEmpty=false)
  reqHash=Hash.new
  writtenDate=parseWrittenDates(rowHash["Written Date"].to_s,"Array")
  printedDate=parsePrintedDates(rowHash["Printed Date"].to_s,"Array")
  topkey= "dates"
  if writtenDate==["-","-","-"] and removeEmpty
    writeHash={}
  else
    writeHash = {"type"=>"written",
                "day"=>"#{writtenDate[0]}",
                "month"=>"#{writtenDate[1]}",
                "year"=>"#{writtenDate[2]}"}
  end
  if printedDate == ["-","-"] and removeEmpty
    printHash={}
  else
    printHash={"type"=>"printed",
              "month"=>"#{printedDate[0]}",
              "year"=>"#{printedDate[1]}"}
  end
  [writeHash,printHash].each do |hash|
    hash.each do |key,value|
      if (value.to_s.length < 1 or value== "-") and removeEmpty
        hash.delete(key)
      end
    end
  end
  dateArray=Array.new
  dateArray.addUnlessEmpty(writeHash, removeEmpty)
  dateArray.addUnlessEmpty(printHash, removeEmpty)
  reqHash.addUnlessEmpty(topkey,dateArray,removeEmpty)

  intLinks=rowHash["Internal Links"].split(",").cleanWhitespace
  oldIds=rowHash["old identification numbers"].split(",").cleanWhitespace
  if removeEmpty
    intLinks.cleanDash
    oldIds.cleanDash
  end
  reqHash.addUnlessEmpty("internal_links",intLinks,removeEmpty)
  needsparsing=false
  oldIds.each do |id|
    if id.is_integer?
      needsparsing=true
    end
  end
  if needsparsing
    begin
      oldIds=parseSlideRange(rowHash["old identification numbers"])[0]
    rescue => e
      puts "A #{e.class} has occurred with message '#{e.message}'. Review 'Old IDs' quality for #{rowHash["Image ID"]}."  
    end
  end
  reqHash.addUnlessEmpty("old_ids",oldIds,removeEmpty)

  rawwords=rowHash["Keywords"].split(",")
  keywords=rawwords.cleanWhitespace
# The following line removes general location names from the keyword list
  genLocName=rowHash["General Location Name"]
  revwords=keywords[0..].reverse
  revwords.each do |word|
    if word == genLocName.fullstrip
      keywords.delete word
      break
    end
  end
##
  if removeEmpty
    keywords.cleanDash
  end
  reqHash.addUnlessEmpty("Keywords",keywords,removeEmpty)

  addtlTerms=rowHash["Search Terms"].split(",").cleanWhitespace
  if removeEmpty
    addtlTerms.cleanDash
  end
  reqHash.addUnlessEmpty("search_terms",addtlTerms,removeEmpty)

  return reqHash
end
#THIS NEEDS TO BE WELL TESTED SOON
#a function that will parse a complex (up to three levels) hash of nested data
#and return all the final endpoints
def parseNestedEndpoints(nest, errormsg)
  fieldsarray=Array.new
  nest.each do |bigkey,value|
    if value.class==Array
      value.each do |value2|
        if value2.class==Array
          value2.each do |value3|
            unless value3.class == Hash
              raise errormsg
            else
              value3.each do |lilkey,value4|
                if value4.class == String and value4[0] != "="
                  fieldsarray.push value4
                elsif value4[0] != "="
                  raise errormsg       
                end
              end
            end
          end
        elsif value2.class == Hash
          value2.each do |key,value3|
            if value3.class == Hash
              value3.each do |key,value4|
                if value4.class==String and value4[0] != "="
                  fieldsarray.push value4
                elsif value4[0] != "="
                  raise errormsg
                end
              end
            elsif value3.class == String and value3[0] != "="
              fieldsarray.push value3
            elsif value3[0] != "="
              raise errormsg
            end
          end
        elsif value2.class==String and value2[0] != "="
          fieldsarray.push value2
        end
      end
    elsif value.class == Hash
      value.each do |key,value2|
        if value2.class==Array
          value2.each do |value3|
            unless value3.class == Hash
              raise errormsg
            else
              value3.each do |lilkey,value4|
                if value4.class == String and value4[0] != "="
                  fieldsarray.push value4
                elsif value4[0] != "="
                  raise errormsg
                end
              end
            end
          end
        elsif value2.class == Hash
          value2.each do |key,value3|
            if value3.class == Hash
              value3.each do |key,value4|
                if value4.class==String and value4[0] != "="
                  fieldsarray.push value4
                elsif value4[0] != "="
                  raise errormsg
                end
              end
            elsif value3.class == String and value3[0] != "="
              fieldsarray.push value3
            elsif value3[0] != "="
              raise errormsg
            end
          end
        elsif value2.class==String and value2[0] != "="
          fieldsarray.push value2
        end
      end
    elsif value.class == String and value[0] != "="
      fieldsarray.push value
    end
  end
  return fieldsarray
end                

def assembleKeywords(indexfile, worksheet=0, includeOrigins=true)
  iDSpreadsheetTag= "Image ID"
  keywordSpreadsheetTag= "Keywords"
  data=readIndexData(indexfile, worksheet, [iDSpreadsheetTag,keywordSpreadsheetTag])
  keywords=Hash.new
  keylist=Array.new
  data.each do |row|
    (id,wordblock)=[row[iDSpreadsheetTag],row[keywordSpreadsheetTag]]
    if wordblock.class==String and id.class==String
      if wordblock.include? "."
        wordblock=wordblock.split(".")[0]
      end
      words=wordblock.split ","
      words.each do |newitem|
        item=newitem.lstrip
        if item.length > 1
          word=item.fullstrip
          if keywords.include? word
            keywords[word].push id
          else
            keywords[word]=[id]
            keylist.push word
          end
        end
      end
    end
  end
  if includeOrigins
    return keywords.sort_by{|key,value| -value.length}.to_h
  else
    return keylist.sort
  end   
end

def readIndexData(indexfile,worksheet=0,fields=DefaultFields,rowform= "Hash",mode= "none")
  require 'spreadsheet'
  hashout=rowform.downcase == "hash"
  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet.open indexfile
  sheet=book.worksheet worksheet
  fieldLocs=getFieldLocs(sheet.row(0),fields,mode)
  sheetData=Array.new
  sheet.each do |row|
    rowdataHash=Hash.new
    rowdataList=Array.new
    fieldLocs.each do |key,value|
      data=row[value]
      if data.class == NilClass
        data= ""
      end
      if hashout
        rowdataHash[key]=data.to_s
      else
        rowdataList.push data.to_s
      end
    end
    if hashout
      sheetData.push rowdataHash
    else
      sheetData.push rowdataList
    end
  end
  return sheetData
end

def getFieldLocs(headerRow,fields,mode=nil)
  rtnHash=Hash.new
  fields.each do |f|
    unless mode.downcase== "casesensitive"
      indexes=headerRow.includesAtIndex(f)
    else
      indexes=headerRow.includesCaseAtIndex(f)
    end
    puts indexes
    if indexes.length == 1
      index=indexes[0]
    elsif indexes.length > 1
      print "Warning: field #{f} has been found in multiple places. The first occurrence has been used."
      index=indexes[0]
    else
      raise StandardError.new("The field \'#{f}\' could not be found in the first row of the sheet. Check field names and worksheet number.")
    end
    rtnHash[f]=index
  end
  if fields.length != rtnHash.length
    print "Warning: Not all the fields have been included"
  else 
    return rtnHash
  end     
end



def getLocationAttributes(coordinateArray)
  require 'geocoder'
  stAdd=Geocoder.address(coordinateArray)
  attrs=stAdd.split(',')
  citycountry=[attrs[-5],attrs[-1]]
  return citycountry
end

def writeImageNotes(writtenDate,printedDate,vrcNum,oldNums,slideWords,indexWords)
  if writtenDate.length > 1
    creationDate=parseWrittenDates writtenDate
    creationSentence= "Photograph created #{creationDate}. "
  else
    creationSentence= "Creation date unknown. "
  end
  if printedDate.length > 4
    printingDate=parsePrintedDates printedDate
    printingSentence= "Photograph processed #{printingDate}. "
  else
    printingSentence= "Processing date unknown. "
  end
  if vrcNum.length > 3 or oldNums.length > 2
    if vrcNum.length > 3
      vrcCat=Classification.new(vrcNum)
      vrcstring=vrcCat.to_s
    else
      vrcstring= ""
    end
    cleanNums= ""
    oldNums.split(",").each do |num|
      begin
        oldcat=Classification.new(num.fullstrip)
        cleanNums+= ", "+oldcat.to_s
      rescue
        if num != "-"
          puts "Old Classification #{num} could not be read"
        end
      end
    end
    if vrcstring.length > 3
      assembledNums=vrcstring+cleanNums            
    else
      assembledNums=cleanNums[2..-1]
    end
    if assembledNums[0] == ","
      assembledNums=assembledNums[2..]
    end
    altIdSentence= "Formerly catalogued as #{assembledNums}. "
  else
    altIdSentence= ""
  end
  if slideWords.length > 3 or indexWords.length > 3
    if slideWords.length > 3
      slideWriting=slideWords.fullstrip
    else
      slideWriting= ""
    end
    if indexWords.length > 3
      indexWriting=indexWords.fullstrip
    else
      indexWriting= ""
    end
    if slideWriting.length > 0 and indexWriting.length > 0
      if slideWriting == indexWriting
        writingSentence= "Notes written on the slide or index: "+indexWriting+"."        
      else
        writingSentence= "Notes written on the slide or index: "+slideWriting+", "+indexWriting+"."
      end
    else
      writingSentence= "Notes written on the slide or index: "+slideWriting+indexWriting+"."
    end
  else
    writingSentence= "No notes written on the slide or index."
  end
  return creationSentence+printingSentence+altIdSentence+writingSentence
end

Months=["January","February","March","April","May","June","July","August","September","October","November","December"]
#This function parses the "Written Dates" section of the index, converting an abbreviated or partial date to an acceptable string.
def parseWrittenDates(stringin, mode= "String")
  #we check if the date is just the year, if it is we return it.
  if stringin.is_integer? or stringin.to_f.to_s == stringin
    stringin=stringin.to_f.round.to_s
    if stringin.fullstrip.is_integer?
      if mode == "String"
        return stringin.fullstrip
      elsif mode == "Array"
          return ["-","-",stringin.fullstrip]
      end
    end
  end 
  begin
    date=Date.parse(stringin)
  rescue
    puts "Date #{stringin} could not be parsed. Fix syntax or update parseWrittenDates"
    if mode == "String"
      return "-"
    elsif mode == "Array"
      return ["-","-","-"]
    end
  end
  month=Months[date.month-1]
  daynum=date.day
  if daynum == 1
    if stringin.include?(" 1,") or stringin.include?(" 1 ")
      day= "1st"
    else
      day=0
    end
  elsif daynum == 2
    day= "2nd"
  elsif daynum == 3
    day= "3rd"
  else
    day=daynum.to_s+"th"
  end
  year=date.year
  if year > 2000
    year=year-100
  end
  if mode== "String"
    if day == 0
      return month+" "+year.to_s
    else
      return month+" "+day+", "+year.to_s
    end
  elsif mode== "Array"
    if day == 0
      return ["-",month,year]
    else
      return [day,month,year]
    end
  end
end

def parsePrintedDates(stringin,mode= "String")
  input=stringin.fullstrip
  if input== "-" or input == ""
    if mode== "String"
      return "-"
    elsif mode == "Array"
      return ["-","-"]
    end
  end
  begin
    date=Date.parse(stringin)
  rescue
    halves=input.split " "
    if halves[0].fullstrip == "ENE"
      monthin= "JAN"
    else
      monthin=halves[0]
    end
    yearin=halves[1][..1]
    date=Date.parse(monthin+" \'"+yearin)
  end
  year=date.year
  if year > 2000
    year=year-100
  end
  if mode== "String"
    return Months[date.month-1]+" "+year.to_s
  elsif mode == "Array"
    return [Months[date.month-1],year]
  end
end

def writeXLSfromRowArray(newfile,data,headers=[])
  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet::Workbook.new
  sheet = book.create_worksheet
  if headers != []
    sheet[0,0..headers.length]=headers
    rowtostart=1
  else
    rowtostart=0
  end
  currentrow=rowtostart
  data.each do |rowArray|
    sheet[currentrow,..-1]=rowArray
    currentrow+=1
  end
  if newfile[-3..] != "xls"
    newfile=generateUniqueFilename("NewSpreadsheet","xls")
  end
  book.write newfile
end
