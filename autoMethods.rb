#load accessory files
#make sure you're in the right directory when you run this 
# or it won't be able to find the file
load 'bIndexOps.rb'

############### Mapping Functions ################################
# The first puts together the two main functions above into a simple mapping function
# the inputfile is a kml filename that has been downloaded from the google Mymaps.
# the resultfile can be any filename you like ending in .xls. If you don't pass a 
# resultfile, a (hopefully) unique one will be generated
# 
# To try an example, download UnitedKingdom.kml from the github and place it 
# in the same folder as this file. Then open a terminal and navigate to that 
# folder with the "cd" command. Once in the correct folder, the terminal should look like 
#
# C:\Users\SomeUser\aFolder\...\thisFolder> 
#
# Then type "irb" into the command line to start a ruby session.
#
# then type "load "kmlParser.rb"". If the terminal returns true, you are done.
# If it generates an error, you are probably not in the correct folder.
#
# Once the file is loaded, just call the mapping function below. For the sample file, that looks like
#
# mapKMLtoXLS("UnitedKingdom.kml")
#
# If this runs with no errors, there should be a new xls file containing the data in that folder.
#
# If an error is encountered, it is probably related to the syntax of the descriptions.
# The last output before the error should give you the slide number and title of the last one read.

def mapKMLtoXLS(inputfile,fillBlanks=true,resultfile="blank",mode="CatNum")
  kmlfile=KML.new(inputfile)
  writeToXlsWithClass(kmlfile, mode, resultfile, fillBlanks)
end

def addSortingNumbers(inputfile,resultfile="blank",worksheet=0,columnNum=1)
  indexes=readXLScolumn(inputfile,worksheet,columnNum)
  sortingNumbers=generateSortingNumbers(indexes)
  writeXLSfromArray(resultfile,[sortingNumbers,indexes],["Sorting Number","Index"])
end
#filename="UnitedKingdom.kml"

#Excel Functions
def fillJSON(indexfile,removeEmpty=true,overwrite=true)
  #we begin by collecting all of the endpoints we will need
  sheetfields=["Written Date","Printed Date","old identification numbers","Keywords","Search Terms","Internal Links"]
  overfillerror=InputError.new "metadata nesting exceeded 3 levels and could not be parsed. Check MetaFields hash in bIndexOps.rb"
  addedFields=parseNestedEndpoints(MetaFields,overfillerror)
  finalfields=["Image ID"]+sheetfields+addedFields+["JSON"]
  data=readIndexData(indexfile,0,finalfields,"Hash")
  newdata=Array.new
  data.each do |row|
    newrow=row.values
    if row[-1].to_s.length < 3 and overwrite==false
      json=row[-1]
    else
      json=writeJSON(row,removeEmpty)
    end
    newrow[-1]=json
    newdata.push newrow
  end
  newfilename=generateUniqueFilename("JSONAdded","xls")
  writeXLSfromRowArray(newfilename,newdata[1..],finalfields)
end

def fillImageNotes(indexfile,overwrite=false)
  fields=["Image ID","Written Date","Printed Date","VRC slide number","old identification numbers","Words written on the slide","Words written on the Baly index","Image Notes"]
  data=readIndexData(indexfile,0,fields,"Array")
  newdata=Array.new
  data.each do |row|
    newrow=row[..-1]
    if row[-1].to_s.length > 3 and overwrite == false
      imNotes=row[-1]
    else
      begin
        imNotes=writeImageNotes(row[1],row[2],row[3],row[4],row[5],row[6])
      rescue => e
        puts "Encountered #{e.class} stating #{e.message} writing image notes for slide #{row[0]}"
        imNotes= "None"          
      end
    end
    newrow[-1]=imNotes
    newdata.push newrow
  end
  newfilename=generateUniqueFilename("ImageNotesAdded","xls")
  writeXLSfromRowArray(newfilename,newdata[1..],fields)
end
