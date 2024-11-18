
## This file will test all the functions from the bottom up to determine what causes an error.
# This is especially important when we move to a new ruby version, or make changes to base files.
# We typically work from the bottom up for each file, starting with the standalone functions
# We start by creating a special error class for this file
# 
# For each function, we start with a expect function that will allow us to easily test the method with feedback
# 

require 'minitest'
require 'minitest/autorun'

load 'autoMethods.rb'

class TestingError<StandardError
end
class FileTester
  def testAll()
    puts "No testAll function has been defined"
  end
end

##########################################################################################
### balyClasses.rb

# We define a unique class for this file to keep it organized
class BalyClassesTester < Minitest::Test
  class ExtensionsTester < BalyClassesTester
    def test_StringExtensions
      # These methods should always work, so we use a single test function for all of them.
      # Test the is_integer? method
      assert "1".is_integer?
      assert "89".is_integer?
      assert "-152".is_integer?
      assert "123.45".is_integer? == false
      assert "hi".is_integer? == false
      
      # Test the is_float? method
      assert "1.23".is_float?
      assert "89.123".is_float?
      assert "-152.456".is_float?
      assert !"123".is_float?
      assert !"omega".is_float?

      # Test the lfullstrip method
      assert_equal "hi","   hi".lfullstrip

      # Test the rfullstrip method
      assert_equal "hi","hi   ".rfullstrip

      # Test the fullstrip method
      assert_equal "hi","   hi   ".fullstrip

      # Test the alphValue method
      assert_equal 1,"A".alphValue
      assert_equal 53,"BA".alphValue
      assert_equal 108,"DD".alphValue
      assert_equal 731,"ABC".alphValue

      # Test the cleanSpaces method
      assert_equal "   hi   ","   hi   ".cleanSpaces
      assert_equal " hi   "," hi   ".cleanSpaces
    end
    def test_ArrayExtensions
      # Test the includesAtIndex method
        # Test basic functionality
      assert_equal [1],["1","2","3","4","5"].includesAtIndex("2")
      assert_equal [3],["1","2","3","4","5"].includesAtIndex("4")
      assert_equal [],["1","2","3","4","5"].includesAtIndex("6")
      assert_equal [0,3,4],["1","2","3","1","1"].includesAtIndex("1")
        # Test case insensitivity
      assert_equal [3],["M","N","O","P","Q"].includesAtIndex("p")
      assert_equal [4],["M","N","O","P","Q"].includesAtIndex("q")
        # Test partial finds
      assert_equal [2,3],["The","Lazy","DOG sat alone","Didn't he"].includesAtIndex("d")
      assert_equal [0,3],["The","Lazy","DOG sat alone","Didn't he"].includesAtIndex("He")
      
      # Test the includesCaseAtIndex method
      assert_equal [],["M","N","O","P","Q"].includesCaseAtIndex("p")
      assert_equal [3],["M","N","O","P","Q"].includesCaseAtIndex("P")
        # Test partial finds
      assert_equal [2,3],["The","Lazy","DOG sat alone","Didn't he"].includesCaseAtIndex("D")
      assert_equal [0,3],["The","Lazy","DOG sat alone","Didn't he"].includesCaseAtIndex("he")
      assert_equal [3],["The","Lazy","DOG sat alone","Didn't he"].includesCaseAtIndex("d")
      assert_equal [2,3],["The","Lazy","DOG sat alone","Didn't he"].includesCaseAtIndex("t")
    end
    def test_HashExtensions
      # Test invertible? method
      assert ({"A"=>1,"B"=>2,"C"=>3}.invertible?)
      assert ({"A"=>1,"B"=>2,"C"=>2}.invertible? == false)
    end
  end
    # With the extensions tested, we test each class, starting with Classification
  class ClassificationTester < BalyClassesTester
    def setup
      @c=Classification.new("B.005")
      @d=Classification.new("CD.055")
      @e=Classification.new("B34.3")
      @f=Classification.new("F. 42")
      @g=Classification.new("DF.2")
    end
    def test_to_s
      # Test initialization
        # Standard syntax
      assert_equal "B.005",@c.to_s
      assert_equal "CD.055",@d.to_s
        # Nonstandard syntax
      assert_equal "B34.003",@e.to_s
      assert_equal "F.042",@f.to_s
      assert_equal "DF.002",@g.to_s
    end
    def test_group_number
      # Test group and number methods
      assert_equal "B", @c.group
      assert_equal 5, @c.number
      assert_equal "CD", @d.group
      assert_equal 55, @d.number
      assert_equal "B34", @e.group
      assert_equal 3, @e.number
      assert_equal "F", @f.group
      assert_equal 42, @f.number
      assert_equal "DF", @g.group
      assert_equal 2, @g.number
    end
    def test_sortingNumber
      # Test sortingnumber method
      assert_equal 2005, @c.sortingNumber
      assert_equal 82055, @d.sortingNumber
      assert_equal 0, @e.sortingNumber
      assert_equal 6042, @f.sortingNumber
      assert_equal 110002, @g.sortingNumber
    end
    def test_stringNum
      # Test stringNum method
      assert_equal "005", @c.stringNum
      assert_equal "055", @d.stringNum
      assert_equal "003", @e.stringNum
      assert_equal "042", @f.stringNum
      assert_equal "002", @g.stringNum
    end
    def test_classSystem
      # Test classSystem method
      assert_equal "Baly", @c.classSystem
      assert_equal "Baly", @d.classSystem
      assert_equal "VRC", @e.classSystem
      assert_equal "Baly", @f.classSystem
      assert_equal "Baly", @g.classSystem
    end
    def test_inRange
      # Test inRange?
      assert_equal false, @c.inRange?("C.001-100")
      assert_equal false, @c.inRange?("C.006-10")
      assert_equal true, @c.inRange?("B.001-100")
      assert_equal false, @c.inRange?("B.006-10")
      assert_equal true, @d.inRange?("CD.001-100")
      assert_equal false, @d.inRange?("CD.80-100")
      assert_equal false, @e.inRange?("B34.006-10")
      assert_equal true, @e.inRange?("B34.001-100")
      assert_equal true, @f.inRange?("F.040-80")
      assert_equal false, @f.inRange?("F.006-10")
      assert_equal false, @g.inRange?("DF.019-100")
      assert_equal false, @g.inRange?("DF.006-10")
      assert_equal true, @g.inRange?("DF.002")
    end
  end
    # Now we move to the Location Class. This has two subclasses, General and Specific
  class LocationsTester < BalyClassesTester
    # Test GeneralLocation
    def test_GeneralLocation_std
      # Standard syntax
      genloc = GeneralLocation.new([[0, 0], "A place"])
      assert_equal "A place", genloc.name
      assert_equal [0, 0], genloc.coords
      assert_equal "", genloc.notes
    end
    def test_GeneralLocation_nonstd
      # Nonstandard syntax
      genloc2 = GeneralLocation.new([[1, 1], "Another place", "Notes"])
      assert_equal "Another place", genloc2.name
      assert_equal [1, 1], genloc2.coords
      assert_equal "Notes", genloc2.notes
    end
    # Test SpecificLocation
    def test_SpecificLocation_std
      # Standard syntax
      specloc = SpecificLocation.new([[1, 1], "possible location at 35 degrees NE", "Some notes", "Some medium title"])
      assert_equal "Some medium title", specloc.title
      assert_equal [1, 1], specloc.coords
      assert_equal "Some notes", specloc.notes
      assert_equal "possible", specloc.precision
      assert_equal 35, specloc.angle.degrees
      assert_equal "NE", specloc.angle.direction
      assert_equal "35 degrees NE", specloc.angle.to_s
    end
    def test_SpecificLocation_nonstd
      # Nonstandard syntax
      specloc2 = SpecificLocation.new([[2, 2], "0 degrees N", "Some medium notes", "Some medium title"])
      assert_equal "Some medium title", specloc2.title
      assert_equal [2, 2], specloc2.coords
      assert_equal "Some medium notes", specloc2.notes
      assert_equal "exact", specloc2.precision
      assert_equal 0, specloc2.angle.degrees
      assert_equal "N", specloc2.angle.direction
      assert_equal "0 degrees N", specloc2.angle.to_s
    end
    def test_SpecificLocation_vertical
      # Vertical Direction
      specloc3 = SpecificLocation.new([[2, 2], "estimated location facing up"])
      assert_equal "UP", specloc3.angle.direction
      assert_equal -1, specloc3.angle.degrees
      assert_equal "-1 degrees UP", specloc3.angle.to_s
    end
  end
  class SlideTester < BalyClassesTester
    def setup
      @bSlide=Slide.new("A.001")
      @vSlide=Slide.new("B43.1000")
    end
    # We start with basic methods and get more complicated
    def test_getIndex_and_Groups
      # Simple Case testing getindex and groups
      assert_equal "A", @bSlide.balyGroup
      assert_equal "A.001", @bSlide.getindex.to_s
      assert_equal "A.001", @bSlide.getindex("Baly").to_s
      assert_equal 0, @bSlide.getindex("VRC")
      assert_equal "B43", @vSlide.VRCGroup
      assert_equal "B43.1000", @vSlide.getindex.to_s
      assert_equal 0, @vSlide.getindex("Baly")
      assert_equal "B43.1000", @vSlide.getindex("VRC").to_s
    end
    def test_altId_and_getIndex
      bSlide=Slide.new("A.001")
      vSlide=Slide.new("B43.1000")
      # Test the addAltID method
      # String in
      bSlide.addAltID("B01.001")
      vSlide.addAltID("CD.21")
      # Confirm results
      assert_equal "A.001", bSlide.getindex.to_s # getIndex should always return the Baly id
      assert_equal "CD.021", vSlide.getindex.to_s
      assert_equal "B01.001", bSlide.getindex("VRC").to_s
      assert_equal "CD.021", vSlide.getindex("Baly").to_s
      
      # Classification in
      bclass = Classification.new("B.005")
      vclass = Classification.new("B42.421")
      
      # Refresh examples
      newbSlide = Slide.new("H.100")
      newvSlide = Slide.new("B21.052")
      
      # Add ids
      newbSlide.addAltID(vclass)
      newvSlide.addAltID(bclass)
      
      # Confirm results
      assert_equal "H.100", newbSlide.getindex.to_s
      # getIndex should always return the Baly id
      assert_equal "B.005", newvSlide.getindex.to_s
      assert_equal "B42.421", newbSlide.getindex("VRC").to_s
      assert_equal "B21.052", newvSlide.getindex("VRC").to_s
    end
    def test_addTitle
      # Test addTitle
      @bSlide.addTitle "This is a test title"
      assert_equal "This is a test title",@bSlide.title
    end
    def test_addLocation_gen_sm
      # Test addLocation
      # General Locations
        # Smallest example 
      sgenlocArray=[[0,0],"A place"]
      @bSlide.addLocation(sgenlocArray)
        # get coordinates
        assert_equal [0, 0], @bSlide.getCoordinates
        # get full location
        samplegenloc = GeneralLocation.new(sgenlocArray)
        # we test the slide quality against the regular Location class, 
        # since this is tested independently above.
        assert_equal samplegenloc.name, @bSlide.generalLocation.name
        assert_equal samplegenloc.coords, @bSlide.generalLocation.coords
        assert_equal samplegenloc.notes, @bSlide.generalLocation.notes
    end
    def test_addLocation_gen_lg
      # Larger example
      mgenlocArray=[[10,20],"Place Name","Some notes"]
      #replace location
      @bSlide.addLocation(mgenlocArray,false,true)
      assert_equal [10, 20], @bSlide.getCoordinates
      # get full location
      mamplegenloc = GeneralLocation.new(mgenlocArray)
      assert_equal mamplegenloc.name, @bSlide.generalLocation.name
      assert_equal mamplegenloc.coords, @bSlide.generalLocation.coords
      assert_equal mamplegenloc.notes, @bSlide.generalLocation.notes
    end
    def test_addLocation_spec_sm
      # Specific Locations
        # Smallest example
      sspeclocArray=[[1,1],"possible location at 35 degrees NE"]
      @bSlide.addLocation(sspeclocArray,true) # add specific location
      assert_equal [1, 1], @bSlide.getCoordinates
      # get full location
      samplespecloc = SpecificLocation.new(sspeclocArray)
      assert_nil @bSlide.specificLocation.title
      assert_equal samplespecloc.coords, @bSlide.specificLocation.coords
      assert_equal samplespecloc.notes, @bSlide.specificLocation.notes
      assert_equal samplespecloc.precision, @bSlide.specificLocation.precision
      assert_equal samplespecloc.angle.degrees, @bSlide.specificLocation.angle.degrees
      assert_equal samplespecloc.angle.direction, @bSlide.specificLocation.angle.direction
      assert_equal samplespecloc.angle.to_s, @bSlide.specificLocation.angle.to_s
    end
    def test_addLocation_spec_lg
        # Larger example
      mspeclocArray=[[2,2],"possible location at 0 degrees N","Some medium notes","Some medium title"]
      @bSlide.addLocation(mspeclocArray,true,true) # add specific location
      assert_equal [2, 2], @bSlide.getCoordinates
      # get full location
      mamplespecloc = SpecificLocation.new(mspeclocArray)
      assert_equal mamplespecloc.title, @bSlide.specificLocation.title
      assert_equal mamplespecloc.coords, @bSlide.specificLocation.coords
      assert_equal mamplespecloc.notes, @bSlide.specificLocation.notes
      assert_equal mamplespecloc.precision, @bSlide.specificLocation.precision
      assert_equal mamplespecloc.angle.degrees, @bSlide.specificLocation.angle.degrees
      assert_equal mamplespecloc.angle.direction, @bSlide.specificLocation.angle.direction
      assert_equal mamplespecloc.angle.to_s, @bSlide.specificLocation.angle.to_s
    end
  end
  class SubcollectionTester < BalyClassesTester
    #This class is intended to allow ranges between collections by 
    #predicting what the next group of 100 will look like.
    def test_VRC_std
      # VRC example
      s1 = Subcollection.new("B43.2")
      assert_equal "B43", s1.group
      assert_equal "2", s1.hundreds
      assert_equal "B43.2", s1.to_s
      assert_equal true, s1.isVRC?
      # Test addone
      s1.addone()
      assert_equal "B43.3", s1.to_s
    end
    def test_VRC_edge
      # VRC edge case 
      s2 = Subcollection.new("B48.9")
      assert_equal "B48", s2.group
      assert_equal "9", s2.hundreds
      assert_equal "B48.9", s2.to_s
      assert_equal true, s2.isVRC?
      # Test addone
      s2.addone()
      assert_equal "B49.0", s2.to_s
    end
    def test_Baly_std
      # Baly Case
      # simpler (no skipped)
      s3=Subcollection.new("AB.0")
      assert_equal "AB", s3.group
      assert_equal "0", s3.hundreds
      assert_equal "AB.0", s3.to_s
      assert_equal false, s3.isVRC?
      # Test addone
      s3.addone()
      assert_equal "AC.0", s3.to_s
    end
    def test_Baly_edge
      #harder case (Q collection doesn't exist)
      s4=Subcollection.new("P.0")
      assert_equal "P", s4.group
      assert_equal "0", s4.hundreds
      assert_equal "P.0", s4.to_s
      assert_equal false, s4.isVRC?
      # Test addone
      s4.addone()
      assert_equal "R.0", s4.to_s
    end
  end
end



# prettyCommonFunctions.rb
load 'prettyCommonFunctions.rb'
#   We start with the base functions and move to larger ones
class PrettyCommonFunctionsTester < FileTester
  # Summarize tests for each Function
  def testAll()
    testGetCatType
    testParseSlideRange
    testGenerateUniqueFilename
    return true
  end
private
# getCatType() 
#   IN: a classification of a slide
#   OUT: the system of this classification, either "VRC" or "Baly" or "N/A" (if not parseable)
  def catTypeExpect(inp,exp)
    type=getCatType(inp)
    assertingError.new "getCatType failed to classify #{inp}. Instead returned #{type}." unless type == exp
  end
  def testGetCatType()
    expectations={
      #"B45.555" => "VRC",
      "A.004" => "Baly",
      "BA.042" => "Baly",
      "BG.100" => "Baly",
      "BG.200" => "N/A",
      "BFSDFE" => "N/A"
    }
    expectations.each do |inp,outp|
      catTypeExpect(inp,outp)
    end
  end

# getUniqueFilename()
#   IN: A string filetype ending (default xls)

# parseSlideRange()
#   IN: a series of comma separated ranges similar to A.001-002.
#   OUT: An array of individual classifications contained in the ranges, as well as the max and min of the range.

  def slideRangeExpect(range,arr)
    out=parseSlideRange(range)[0]
    assertingError.new "parseSlideRange failed to parse #{range}. Instead returned #{out}." unless out==arr 
  end
  def testParseSlideRange()
    expectations={
      #Simple Case
      "A.001-05" => ["A.001","A.002","A.003","A.004","A.005"],
      #Multiple simple case
      "A.01,B.002-4,C.2" => ["A.001","B.002","B.003","B.004","C.002"],
      #VRC classification case
      "B45.321-30" => ["B45.321","B45.322","B45.323","B45.324","B45.325","B45.326","B45.327","B45.328","B45.329","B45.330"]
    }
    expectations.each do |inp,res|
      slideRangeExpect(inp,res)
    end
  end
  def testGenerateUniqueFilename
    err=TestingError.new "The Generate Unique Filename function has produced an error. This is not a very complicated function, so something is fundamentally wrong. Check your ruby version."
    # Normal use
    tfile1 = generateUniqueFilename("sampleAPIdata","xls")
    assertunless tfile1[0..12]=="sampleAPIdata" and tfile1[-3..-1]=="xls"
    tfile2 = generateUniqueFilename("loooooooooooooooooooooooooooooooooooooooooooooooooooooongname","pdf")
    assertunless tfile2[0..60]=="loooooooooooooooooooooooooooooooooooooooooooooooooooooongname" and tfile2[-3..-1]=="pdf"
    # Edge Cases
    # No extension
    tfile3 = generateUniqueFilename("title")
    assertunless tfile3[0..4]=="title" and tfile3[-3..-1]=="xls"
    
  end
end

# classes=[BalyClassesTester.new,PrettyCommonFunctionsTester.new]
# classes.each do |tester|
#     puts "Testing #{tester.class}..."
#     tester.testAll
# end
# puts "Testing Successfull as all modules have passed"