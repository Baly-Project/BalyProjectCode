#load accessory files
#make sure you're in the right directory when you run this 
# or it won't be able to find the file
require_relative 'indexConverter.rb'

class Slide
  def addGeodata()
    require 'geocoder'
    coords=getCoordinates
    puts coords
    geodata=Geocoder.address(coords).split(",")
    if [@city,@region,@country]!=[0,0,0]
      puts "WARNING: Existing Geodata is being overwritten on slide #{getIndex}"
    end
    (@city,@region,@country)=[geodata[-5],geodata[-3],geodata[-1]]
  end
end
class String
  def hasDirection?()
    return (self.include?(" degrees") or self.include?(" facing up") or self.include?(" facing down"))
  end
end

class KML
  # A class to read KML files and make the data accessible to the later functions
  def initialize(filename)
    @title= ""
    @points=[]
    @lines=[]
    if filename[-4..-1] == ".kml"
      instring = File.read(filename)
    else 
      instring=filename
    end
    parseKML(instring)
  end

  def points
    return @points
  end

  def lines
    return @lines
  end

  def title
    return @title
  end

  def assembleAnglesHash
    linehash = Hash.new
    @lines.each do |line|
      (slide,required)=line.title.split(" ")
      if required.downcase == "angle"
          cat=Classification.new(parseSlideRange(slide)[0][0]).to_s
        if cat.class == NilClass
          print "The angle line for slide #{cat} could not be parsed, and has been skipped"
        elsif cat.include? "ERROR"
          print "The angle line for slide #{cat} could not be parsed, and has been skipped"
        else
          linehash[cat]=line.angle
        end
      end
    end
    return linehash
  end
  class Placemark #Consisting of Point and Line subclasses, Placemarks are the basic unit of KML files
    def initialize(instring)
      @title = ""
      @description = ""
      @coords=[]
      @coordsNext=false  
      lines=instring.split("\n")
      lines.each do |line|
        parseAttrs line
      end
    end

    def parseAttrs(line)
      if line.include? "<name>"
        @title = cleanline line
      elsif line.include? "<description>"
        @description = cleanline line
      elsif line.include? "<coordinates>"
        @coordsNext = true
      elsif line.include? "</coordinates>"
        @coordsNext = false
      elsif @coordsNext
        bigcords=line.split ","
        latitude=bigcords[1].to_f
        longitude=bigcords[0].lfullstrip.to_f
        if @coords.to_s.length > 3
          (prevLat,prevLong)=@coords
          @coords=[[prevLat,prevLong],[latitude,longitude]]
        else
          @coords=[latitude,longitude]
        end
      end
    end

    def cleanline(line)
      start=line.index ">"
      start+=1
      last=line.rindex "<"
      return line[start...last].fullstrip
    end

    def title
      return @title
    end

    def description
      return @description
    end

    def coords
      return @coords
    end
  end
  class Point < Placemark
  # This is basically the 'plainest' version of a placemark, and only has common attributes
  # but is a subclass in order to preserve the natural hierarchy that KML uses
  end
  class Line < Placemark
    Pi = 3.141592653
    def angle
      if @coords[0][0]==@coords[1][0]
        return "0 degrees N"
      end
      dy = @coords[1][0]-@coords[0][0]
      dx = @coords[1][1]-@coords[0][1]
      radangle=Math.atan(dx/dy)
      degangle= radangle * (180/Pi)
      remainder=degangle % 5
      if degangle < 0
        degangle=degangle+360
      end
      if remainder > 2
        rounded = degangle-remainder+5
      else
        rounded =  degangle - remainder
      end
      if dy < 0
        rounded= (rounded+180) % 360
      end
      return rounded.to_i.to_s + " degrees " + get_angle_direction(rounded.to_i)
    end
    private
    def get_angle_direction(degrees)
      remainder=(degrees+23) % 45
      sum=(degrees-remainder + 68)
      case sum
        when (0..45)
          dir = "N"
        when (46..90)
          dir = "NE"
        when (91..135)
          dir = "E"
        when (136..180)
          dir = "SE"
        when (180..225)
          dir = "S"
        when (226..270)
          dir = "SW"
        when (271..315)
          dir = "W"
        when (316..360)
          dir = "NW"
        else dir = ""   
      end
      return dir
    end
  end

  private
  def parseKML(instring)
    tempstring= ""
    reading = false
    lines=instring.split "\n"
    lines.each do |line|
      if line.include? "</Placemark>"
        reading = false
        if tempstring.include? "<LineString>"
          newline=Line.new tempstring
          @lines.push newline
        elsif tempstring.include? "<Point>"
          newpoint=Point.new tempstring
          @points.push newpoint
        end
        tempstring=String.new
      elsif reading
        tempstring+=line+"\n"
      elsif line.include? "<name>" and @title.to_s.length == 0
        @title=line[line.index(">")+1...line.rindex("<")]
      elsif line.include? "<Placemark>"
        reading = true
      end
    end
  end
end
 
def splitLocations (stringLocation)
  if stringLocation.class != String
    return ["there has been an error","like actually"]
  elsif (stringLocation.include? ",")==false
    return ["there has been an error","like actually"]
  else
    commaSpot=stringLocation.index ","
    latitude=stringLocation[...commaSpot]
    longitude=stringLocation[(commaSpot+1)..]
    return [longitude,latitude]
  end
end 


def writeToXlsWithClass(kmlObject, mode="straight", filename="blank",fillBlanks=true)
  #this function makes heavy use of the spreadsheet package. To install, type "gem install spreadsheet" into your terminal (windows)
  # or visit the source at https://rubygems.org/gems/spreadsheet/versions/1.3.0?locale=en
  require "spreadsheet" 
  #Next we set the encoding. This is the default setting but can be changed here
  Spreadsheet.client_encoding='UTF-8'
  
  #Now we define a mode. Each mode will direct the function to a different loop to produce different types of data.
  #"straight" mode keeps data organized by location, ex. Baly Cottage => B43.32-53,location
  #"CatNum" mode interprets each range and re-organizes it to read B43.32 => Baly Cottage, location
  
  #we now create our spreadsheet file
  book=Spreadsheet::Workbook.new
  mainsheet=book.create_worksheet
  
  #we then collect the title of the group and name our sheet after it
  collectionTitle=kmlObject.title
  mainsheet.name = collectionTitle

  #we define a disclaimer to populate the top left cell, identifying that it was produced by code
  disclaimer= "This is an automatically generated spreadsheet titled '#{collectionTitle}' Please review the information before copying into permanent data storage."
  mainsheet[0,0] = disclaimer
  
  if mode == "straight"

    #then we make titles for each column
    mainsheet[1,0]="Title"
    mainsheet[1,1]="Description"
    mainsheet[1,2]="Longitude"
    mainsheet[1,3]="Latitude"

    #with our title and disclaimer made, we move into our main loop
    #the writing will take place one row at a time, and will be based on the list of keys (bigarray[1])
    points=kmlObject.points
    finalindex=0
    points.length.times do |i|
      #gather info
      point=kmlObject.points[i]
      title = point.title
      description = point.description
      location = point.coords
      #populate info
      mainsheet[i+2,0] = title
      mainsheet[i+2,1] = description
      mainsheet[i+2,2] = location[0]
      mainsheet[i+2,3] = location[1]
      finalindex=i
    end
    
    
    lines=kmlObject.lines
    finalindex+=4
    mainsheet[finalindex] = ["Line Title","Line Description","Latitude 1","Longitude 1","Latitude 2","Longitude 2", "Angle Generated"] 
    finalindex+=1
    lines.length.times do |i|
      #define object
      line = lines[i]
      #gather info
      title = line.title
      description = line.description
      startLocation = line.coords[0]
      endlocation = line.coords[1]
      angle=line.angle.to_s+" degrees"
      #populate info
      mainsheet[finalindex+i][0] = title
      mainsheet[finalindex+i][1] = description
      mainsheet[finalindex+i][2] = startLocation[0]
      mainsheet[finalindex+i][3] = startLocation[1]
      mainsheet[finalindex+i][4] = endlocation[0]
      mainsheet[finalindex+i][5] = endlocation[1]
      mainsheet[finalindex+i][6] = angle
    end
  end

  if mode == "CatNum"
    seenSlides=Hash.new
    points=kmlObject.points
    linedirectory=kmlObject.assembleAnglesHash
    #Loop through the points 
    points.length.times do |index|
      point = points[index]
      title = point.title
      desc = point.description
      if desc.length == 0
        raise StandardError.new "Kml entry at index #{index} with title #{title} does not have a description"
      elsif title.include? "."
        if title.index(".") < 4
          (title,desc)=swapSlideIdentifier(title,desc)
          puts "swapped"
        end
      end
      #puts title,desc

      locationTuple=point.coords 
      slidesarray = parseSlideRange(desc)[0]
      slidesarray.each do |cat|
        if cat.class == NilClass
          print "The slide with categorization #{cat} and title #{title} (#{index}) could not be parsed, and has been skipped"
        elsif cat.include? "ERROR"
          print "The slide with categorization #{cat} and title #{title} (#{index}) could not be parsed, and has been skipped"
        else
          #puts seenSlides
          #puts index
          #puts cat
          classification=Classification.new(cat).to_s
          angle=linedirectory[classification]
          if angle.class != NilClass and desc[0..desc.index(". ")].downcase.include? "location"
            if desc[0..desc.index(". ")].include? "location"
              parts=desc.split("location")
            elsif desc[0..desc.index(". ")].include? "Location"
              parts=desc.split("Location")
            end
            runningdesc= ""
            parts.insert(1,"location at "+angle)
            parts.length.times do |i|
              runningdesc += parts[i]
            end
            desc=runningdesc
          end
          if seenSlides.include? classification
            slide=seenSlides[classification]
            addLocationToSlide(slide,locationTuple,title,desc)
          else  
            slide=Slide.new(classification)
            addLocationToSlide(slide,locationTuple,title,desc)
            altId=indexConverter(slide.getindex)
            if altId.class == Classification
              slide.addAltID(altId)
            end
            seenSlides[classification]=slide
          end
        end
      end
    end
    lastblock=2
    #populate spreadsheet
    formatspreadsheet(mainsheet)
    slides=seenSlides.values.sort_by {|slide| slide.getindex.to_s}
    lastslide=slides[0].getindex.number
    currentGroup=slides[0].getindex.group
    slides.each do |slide|
      number=slide.getindex.number
      if number > lastslide+1 and fillBlanks
        (number-(lastslide+1)).times do |i|
          thisclassification=Classification.new([currentGroup,lastslide+i+1])
          mainsheet[lastblock,0]=thisclassification.sortingNumber
          mainsheet[lastblock,2]=thisclassification.to_s
          lastblock+=1
        end
      end
      lastslide=number
      #slide.addGeodata
      slideData=formatSlideData(slide)
      for i in [0..slideData.length]
        mainsheet[lastblock,i]=slideData[i]
      end
      lastblock+=1
    end
  end
  if filename != "blank"
    book.write filename
  else 
    book.write generateUniqueFilename(collectionTitle,"xls")
  end
end

def swapSlideIdentifier(title,description)
  slideID=title.split(" ")[0]
  if slideID.include? "-"
    slideID=slideID.split("-")[0]
  end
  title=title.split("-")[1].fullstrip
  description=slideID+" "+description
  return [title,description]
end


def addLocationToSlide(slide,locationTuple,title,desc)
  puts "Description: #{desc}"
  data=stripData(desc)
  if data.class != Array
    notes=data
    slide.addLocation([locationTuple,title,notes],false,false)
    puts "worked! added loc. #{title}"
  elsif data[0].class != NilClass
    slide.addLocation([locationTuple,data[0],data[1],title],true,false)
  end
  
end
  
def stripData(desc)
  if desc.hasDirection? == false
    lastnum=-1
    if desc.include? ". "
      sentences=desc.split(". ")[1..]
      notes= ''
      if sentences.length > 1
        sentences.each do |item|
          notes+=item
        end
      else
        notes=sentences[0]
      end
    else
      desc.each_char do |char|
        if char.is_integer?
          lastnum=desc.rindex char
        end
      end
      notes=desc[lastnum+1..]
    end
    return notes
  else
    firstspace=desc.index " "
    while firstspace <= 1
      firstspace=firstspace+desc[firstspace..].index(" ")
    end
    sentences=desc[firstspace..].split ". "
    angledata=sentences[0]
    if sentences.length > 1
      notes= ''
      sentences[1..].each do |sentence|
        notes += sentence
      end
      return [angledata,notes]
    end
    return [angledata,0 ]
  end
end

def findAngleDirection(angle)
end

def formatspreadsheet(sheet)
  fields=["Sorting Number","Slide Title","Baly Cat","VRC Cat","General Place Name","General Coordinates","Specific Coordinates","Direction","Precision","Notes","City","Region","Country"]
  for i in [0..fields.length]
    sheet[1,i]=fields[i]
#    format=Spreadsheet::Format.new :width => fields[i].length
#    sheet.col(i).default_format=format
  end
end
def formatSlideData(slide)
  balyid=slide.getindex("Baly").to_s
  vrcid=slide.getindex("VRC").to_s
  sortingNumber=slide.getSortNum
  generalLoc=slide.generalLocation
  if generalLoc != 0
    locationName= generalLoc.name
    genCoords = formatCoords(generalLoc.coords)
  else
    locationName= ""
    genCoords = ["",""]
  end
  specificLoc=slide.specificLocation
  if specificLoc!=0
    title=specificLoc.title
    specCoords = formatCoords(specificLoc.coords)
    specAngle=specificLoc.angle.to_s
    precision=specificLoc.precision
  else
    title= ""
    specCoords=["",""]
    specAngle= ""
  end
  resultarray=[sortingNumber,title,balyid,vrcid,locationName,genCoords,specCoords,specAngle,precision]
  notes= ""
  [generalLoc,specificLoc].each do |loc|
    if loc.class < Location
      eachnote=loc.notes
      if eachnote != 0
        notes += eachnote
      end
    end
  end
  resultarray.push notes
  resultarray+=slide.getGeodata
  resultarray.each do |element|
    if element == 0
      element= ""
    end
  end
  return resultarray
end
def formatCoords(coordinateArray)
  latitude=coordinateArray[0]
  longitude=coordinateArray[1]
  return "(#{latitude},#{longitude})"
end
def writeToXls(bigarray, mode="straight", filename="blank")
  #this function makes heavy use of the spreadsheet package. To install, type "gem install spreadsheet" into your terminal (windows)
  # or visit the source at https://rubygems.org/gems/spreadsheet/versions/1.3.0?locale=en
  require "spreadsheet" 
  #Next we set the encoding. This is the default setting but can be changed here
  Spreadsheet.client_encoding='UTF-8'
  
  #Now we define a mode. Each mode will direct the function to a different loop to produce different types of data.
  #"straight" mode keeps data organized by location, ex. Baly Cottage => B43.32-53,location
  #"CatNum" mode interprets each range and re-organizes it to read B43.32 => Baly Cottage, location



  #we now create our spreadsheet file
  book=Spreadsheet::Workbook.new
  mainsheet=book.create_worksheet
  
  #we then collect the title of the group and name our sheet after it
  collectionTitle=bigarray[0]
  mainsheet.name = collectionTitle

  #we define a disclaimer to populate the top left cell, identifying that it was produced by code
  disclaimer= "This is an automatically generated spreadsheet titled \'" + collectionTitle + ".\' Please review the information before copying into permanent data storage."
  mainsheet[0,0] = disclaimer
  
  if mode=="straight"

    #then we make titles for each column
    mainsheet[1,0]="Title"
    mainsheet[1,1]="Description"
    mainsheet[1,2]="Longitude"
    mainsheet[1,3]="Latitude"

    #with our title and disclaimer made, we move into our main loop
    #the writing will take place one row at a time, and will be based on the list of keys (bigarray[1])

    for i in 2..bigarray[1].length
      #gather info
      title = bigarray[1][i]
      description=bigarray[2][title]
      location=bigarray[3][title]
    
      #while most of the data is ready to input, the locations are still a string tuple.
      #we must split this into its parts before entry

      locationTuple = splitLocations location

      #populate info
      mainsheet[i,0]=title
      mainsheet[i,1]=description
      mainsheet[i,2]=locationTuple[0]
      mainsheet[i,3]=locationTuple[1]
    end 
  end

  if mode == "CatNum"
    titlesToMentions=Hash.new
    upperslides=Array.new
    lowerslides=Array.new
    for i in 0...bigarray[1].length
      activetitle=bigarray[1][i]
      desc = bigarray[2][activetitle]
      puts desc
      
      if desc.class != NilClass

        if desc.include? "-"
          smallerarray = parseSlideRange desc
          lowerslides.push smallerarray[1]
          upperslides.push smallerarray[2]
          titlesToMentions[activetitle]=smallerarray[0]
        elsif desc.length > 5
          slide=desc[..6]
          lowerslides.push slide
          upperslides.push slide
          titlesToMentions[activetitle]=[slide]
        end
      end
    end
    lastblock=2

    #populate spreadsheet
    mainsheet[1,0]="Cat#"
    mainsheet[1,1]="Slide Title"
    mainsheet[1,2]="Longitude"
    mainsheet[1,3]="Latitude"

    for i in 0...bigarray[1].length
      activetitle=bigarray[1][i]
      workinglist=titlesToMentions[activetitle]
      location=bigarray[3][activetitle]
      locationTuple=splitLocations location
      if workinglist.class != NilClass
        for j in 0...workinglist.length
          mainsheet[lastblock,0]=workinglist[j]
          mainsheet[lastblock,1]=activetitle
          mainsheet[lastblock,2]=locationTuple[0]
          mainsheet[lastblock,3]=locationTuple[1]
          lastblock=lastblock+1
        end
      end
    end
  end


  if filename != "blank"
    book.write filename
  else 
    time=Time.now
    minutes=time.min
    seconds=time.sec

    book.write collectionTitle+minutes.to_s + "." + seconds.to_s+".xls"
  end
end

#This function reads an xlsfile and turns one column into an array. 
#Its inputs are a string of the file to read, and two integer indexes for the worksheet and column.
def readXLScolumn(xlsfile,worksheet,columnNum)
  require 'spreadsheet'
  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet.open xlsfile
  sheet=book.worksheet worksheet
  
  indexarray=Array.new
  sheet.each do |row|
    eachindex=row[columnNum]
    indexarray.push eachindex
  end
  return indexarray
end
#puts parseSlideRange "B45.321 approximate location at 35 degrees N"
#"B27.012-15, B47.654-63, 716-18,B45.9-10, B45.63-67. WHat the"

#then we take that input and write it to a newfile. 
#These inputs are a string filename, an Array of Arrays representing each column to write,
# plus an optional array input containing the headers
def writeXLSfromColArray(newfile,data,headers=[])
  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet::Workbook.new
  sheet = book.create_worksheet
  if headers != []
    sheet[0,0..headers.length]=headers
    rowtostart=1
  else
    rowtostart=0
  end
  currentcol=0
  data.each do |colArray|
    currentrow=rowtostart
    colArray.each do |item|
      sheet[currentrow,currentcol]=item
      currentrow+=1
    end
    currentcol+=1
  end

  if newfile[-3..] != "xls"
    puts "The file #{newfile} did not meet the formatting criteria, and a generic title was provided"
    newfile=generateUniqueFilename("NewSpreadsheet","xls")
  end
  book.write newfile
end
=begin testing
A sample input
writeXLSfromColArray("test.xls",[["col1","r1","r2","r3","r4","r5"],["col2",1,2,3,4,5]],["sampleHeader1","sampleheader2"])
=end
