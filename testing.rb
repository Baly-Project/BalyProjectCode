## This file will test all the functions from the bottom up to determine what causes an error.
# This is especially important when we move to a new ruby version, or make changes to base files.
# We typically work from the bottom up for each file, starting with the standalone functions
# We start by creating a special error class for this file
#
# For each function, we start with a expect function that will allow us to easily test the method with feedback
#

require 'minitest'
require 'minitest/autorun'

# As the endpoint for users, the automethods.rb file contains the full project
load 'autoMethods.rb'

# We define a custom class to be used in all tests
class BalyTester < Minitest::Test
  # and add some universal functions
  def increaseClassification(classification)
    arr=[classification.group,classification.number]
    arr[1] += 1
    classification = Classification.new arr
  end
end
##########################################################################################
### balyClasses.rb

# We define a unique class for this file to keep it organized
class BalyClassesTester < BalyTester
  class ExtensionsTester < BalyClassesTester
    def test_StringExtensions
      # These methods should always work, so we use a single test function for all of them.
      # Test the is_integer? method
      assert '1'.is_integer?
      assert '89'.is_integer?
      assert '-152'.is_integer?
      assert '123.45'.is_integer? == false
      assert 'hi'.is_integer? == false

      # Test the is_float? method
      assert '1.23'.is_float?
      assert '89.123'.is_float?
      assert '-152.456'.is_float?
      assert !'123'.is_float?
      assert !'omega'.is_float?

      # Test the lfullstrip method
      assert_equal 'hi', '   hi'.lfullstrip

      # Test the rfullstrip method
      assert_equal 'hi', 'hi   '.rfullstrip

      # Test the fullstrip method
      assert_equal 'hi', '   hi   '.fullstrip

      # Test the alphValue method
      assert_equal 1, 'A'.alphValue
      assert_equal 53, 'BA'.alphValue
      assert_equal 108, 'DD'.alphValue
      assert_equal 731, 'ABC'.alphValue

      # Test the cleanSpaces method
      assert_equal '   hi   ', '   hi   '.cleanSpaces
      assert_equal ' hi   ', ' hi   '.cleanSpaces
    end

    def test_ArrayExtensions
      # Test the includesAtIndex method
      # Test basic functionality
      assert_equal [1], %w[1 2 3 4 5].includesAtIndex('2')
      assert_equal [3], %w[1 2 3 4 5].includesAtIndex('4')
      assert_equal [], %w[1 2 3 4 5].includesAtIndex('6')
      assert_equal [0, 3, 4], %w[1 2 3 1 1].includesAtIndex('1')
      # Test case insensitivity
      assert_equal [3], %w[M N O P Q].includesAtIndex('p')
      assert_equal [4], %w[M N O P Q].includesAtIndex('q')
      # Test partial finds
      assert_equal [2, 3], ['The', 'Lazy', 'DOG sat alone', "Didn't he"].includesAtIndex('d')
      assert_equal [0, 3], ['The', 'Lazy', 'DOG sat alone', "Didn't he"].includesAtIndex('He')

      # Test the includesCaseAtIndex method
      assert_equal [], %w[M N O P Q].includesCaseAtIndex('p')
      assert_equal [3], %w[M N O P Q].includesCaseAtIndex('P')
      # Test partial finds
      assert_equal [2, 3], ['The', 'Lazy', 'DOG sat alone', "Didn't he"].includesCaseAtIndex('D')
      assert_equal [0, 3], ['The', 'Lazy', 'DOG sat alone', "Didn't he"].includesCaseAtIndex('he')
      assert_equal [3], ['The', 'Lazy', 'DOG sat alone', "Didn't he"].includesCaseAtIndex('d')
      assert_equal [2, 3], ['The', 'Lazy', 'DOG sat alone', "Didn't he"].includesCaseAtIndex('t')
    end

    def test_HashExtensions
      # Test invertible? method
      assert({ 'A' => 1, 'B' => 2, 'C' => 3 }.invertible?)
      assert({ 'A' => 1, 'B' => 2, 'C' => 2 }.invertible? == false)
    end
  end

  # With the extensions tested, we test each class, starting with Classification
  class ClassificationTester < BalyClassesTester
    def setup
      @c = Classification.new('B.005')
      @d = Classification.new('CD.055')
      @e = Classification.new('B34.3')
      @f = Classification.new('F. 42')
      @g = Classification.new('DF.2')
    end

    def test_to_s
      # Test initialization
      # Standard syntax
      assert_equal 'B.005', @c.to_s
      assert_equal 'CD.055', @d.to_s
      # Nonstandard syntax
      assert_equal 'B34.003', @e.to_s
      assert_equal 'F.042', @f.to_s
      assert_equal 'DF.002', @g.to_s
    end

    def test_group_number
      # Test group and number methods
      assert_equal 'B', @c.group
      assert_equal 5, @c.number
      assert_equal 'CD', @d.group
      assert_equal 55, @d.number
      assert_equal 'B34', @e.group
      assert_equal 3, @e.number
      assert_equal 'F', @f.group
      assert_equal 42, @f.number
      assert_equal 'DF', @g.group
      assert_equal 2, @g.number
    end

    def test_sortingNumber
      # Test sortingnumber method
      assert_equal 2005, @c.sortingNumber
      assert_equal 82_055, @d.sortingNumber
      assert_equal 0, @e.sortingNumber
      assert_equal 6042, @f.sortingNumber
      assert_equal 110_002, @g.sortingNumber
    end

    def test_stringNum
      # Test stringNum method
      assert_equal '005', @c.stringNum
      assert_equal '055', @d.stringNum
      assert_equal '003', @e.stringNum
      assert_equal '042', @f.stringNum
      assert_equal '002', @g.stringNum
    end

    def test_classSystem
      # Test classSystem method
      assert_equal 'Baly', @c.classSystem
      assert_equal 'Baly', @d.classSystem
      assert_equal 'VRC', @e.classSystem
      assert_equal 'Baly', @f.classSystem
      assert_equal 'Baly', @g.classSystem
    end

    def test_inRange
      # Test inRange?
      assert_equal false, @c.inRange?('C.001-100')
      assert_equal false, @c.inRange?('C.006-10')
      assert_equal true, @c.inRange?('B.001-100')
      assert_equal false, @c.inRange?('B.006-10')
      assert_equal true, @d.inRange?('CD.001-100')
      assert_equal false, @d.inRange?('CD.80-100')
      assert_equal false, @e.inRange?('B34.006-10')
      assert_equal true, @e.inRange?('B34.001-100')
      assert_equal true, @f.inRange?('F.040-80')
      assert_equal false, @f.inRange?('F.006-10')
      assert_equal false, @g.inRange?('DF.019-100')
      assert_equal false, @g.inRange?('DF.006-10')
      assert_equal true, @g.inRange?('DF.002')
      assert_equal true, @d.inRange?('CD.55')
    end
  end

  # Now we move to the Location Class. This has two subclasses, General and Specific
  class LocationsTester < BalyClassesTester
    # Test GeneralLocation
    def test_GeneralLocation_std
      # Standard syntax
      genloc = GeneralLocation.new([[0, 0], 'A place'])
      assert_equal 'A place', genloc.name
      assert_equal [0, 0], genloc.coords
      assert_equal '', genloc.notes
    end

    def test_GeneralLocation_nonstd
      # Nonstandard syntax
      genloc2 = GeneralLocation.new([[1, 1], 'Another place', 'Notes'])
      assert_equal 'Another place', genloc2.name
      assert_equal [1, 1], genloc2.coords
      assert_equal 'Notes', genloc2.notes
    end

    # Test SpecificLocation
    def test_SpecificLocation_std
      # Standard syntax
      specloc = SpecificLocation.new([[1, 1], 'possible location at 35 degrees NE', 'Some notes', 'Some medium title'])
      assert_equal 'Some medium title', specloc.title
      assert_equal [1, 1], specloc.coords
      assert_equal 'Some notes', specloc.notes
      assert_equal 'possible', specloc.precision
      assert_equal 35, specloc.angle.degrees
      assert_equal 'NE', specloc.angle.direction
      assert_equal '35 degrees NE', specloc.angle.to_s
    end

    def test_SpecificLocation_nonstd
      # Nonstandard syntax
      specloc2 = SpecificLocation.new([[2, 2], '0 degrees N', 'Some medium notes', 'Some medium title'])
      assert_equal 'Some medium title', specloc2.title
      assert_equal [2, 2], specloc2.coords
      assert_equal 'Some medium notes', specloc2.notes
      assert_equal 'exact', specloc2.precision
      assert_equal 0, specloc2.angle.degrees
      assert_equal 'N', specloc2.angle.direction
      assert_equal '0 degrees N', specloc2.angle.to_s
    end

    def test_SpecificLocation_vertical
      # Vertical Direction
      specloc3 = SpecificLocation.new([[2, 2], 'estimated location facing up'])
      assert_equal 'UP', specloc3.angle.direction
      assert_equal(-1, specloc3.angle.degrees)
      assert_equal '-1 degrees UP', specloc3.angle.to_s
    end
  end

  class SlideTester < BalyClassesTester
    def setup
      @bSlide = Slide.new('A.001')
      @vSlide = Slide.new('B43.1000')
    end

    # We start with basic methods and get more complicated
    def test_getIndex_and_Groups
      # Simple Case testing getindex and groups
      assert_equal 'A', @bSlide.balyGroup
      assert_equal 'A.001', @bSlide.getindex.to_s
      assert_equal 'A.001', @bSlide.getindex('Baly').to_s
      assert_equal 0, @bSlide.getindex('VRC')
      assert_equal 'B43', @vSlide.VRCGroup
      assert_equal 'B43.1000', @vSlide.getindex.to_s
      assert_equal 0, @vSlide.getindex('Baly')
      assert_equal 'B43.1000', @vSlide.getindex('VRC').to_s
    end

    def test_altId_and_getIndex
      bSlide = Slide.new('A.001')
      vSlide = Slide.new('B43.1000')
      # Test the addAltID method
      # String in
      bSlide.addAltID('B01.001')
      vSlide.addAltID('CD.21')
      # Confirm results
      assert_equal 'A.001', bSlide.getindex.to_s # getIndex should always return the Baly id
      assert_equal 'CD.021', vSlide.getindex.to_s
      assert_equal 'B01.001', bSlide.getindex('VRC').to_s
      assert_equal 'CD.021', vSlide.getindex('Baly').to_s

      # Classification in
      bclass = Classification.new('B.005')
      vclass = Classification.new('B42.421')

      # Refresh examples
      newbSlide = Slide.new('H.100')
      newvSlide = Slide.new('B21.052')

      # Add ids
      newbSlide.addAltID(vclass)
      newvSlide.addAltID(bclass)

      # Confirm results
      assert_equal 'H.100', newbSlide.getindex.to_s
      # getIndex should always return the Baly id
      assert_equal 'B.005', newvSlide.getindex.to_s
      assert_equal 'B42.421', newbSlide.getindex('VRC').to_s
      assert_equal 'B21.052', newvSlide.getindex('VRC').to_s
    end

    def test_addTitle
      # Test addTitle
      @bSlide.addTitle 'This is a test title'
      assert_equal 'This is a test title', @bSlide.title
    end

    def test_addLocation_gen_sm
      # Test addLocation
      # General Locations
      # Smallest example
      sgenlocArray = [[0, 0], 'A place']
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
      mgenlocArray = [[10, 20], 'Place Name', 'Some notes']
      # replace location
      @bSlide.addLocation(mgenlocArray, false, true)
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
      sspeclocArray = [[1, 1], 'possible location at 35 degrees NE']
      @bSlide.addLocation(sspeclocArray, true) # add specific location
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
      mspeclocArray = [[2, 2], 'possible location at 0 degrees N', 'Some medium notes', 'Some medium title']
      @bSlide.addLocation(mspeclocArray, true, true) # add specific location
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
    # This class is intended to allow ranges between collections by
    # predicting what the next group of 100 will look like.
    def test_VRC_std
      # VRC example
      s1 = Subcollection.new('B43.2')
      assert_equal 'B43', s1.group
      assert_equal '2', s1.hundreds
      assert_equal 'B43.2', s1.to_s
      assert_equal true, s1.isVRC?
      # Test addone
      s1.addone
      assert_equal 'B43.3', s1.to_s
    end

    def test_VRC_edge
      # VRC edge case
      s2 = Subcollection.new('B48.9')
      assert_equal 'B48', s2.group
      assert_equal '9', s2.hundreds
      assert_equal 'B48.9', s2.to_s
      assert_equal true, s2.isVRC?
      # Test addone
      s2.addone
      assert_equal 'B49.0', s2.to_s
    end

    def test_Baly_std
      # Baly Case
      # simpler (no skipped)
      s3 = Subcollection.new('AB.0')
      assert_equal 'AB', s3.group
      assert_equal '0', s3.hundreds
      assert_equal 'AB.0', s3.to_s
      assert_equal false, s3.isVRC?
      # Test addone
      s3.addone
      assert_equal 'AC.0', s3.to_s
    end

    def test_Baly_edge
      # harder case (Q collection doesn't exist)
      s4 = Subcollection.new('P.0')
      assert_equal 'P', s4.group
      assert_equal '0', s4.hundreds
      assert_equal 'P.0', s4.to_s
      assert_equal false, s4.isVRC?
      # Test addone
      s4.addone
      assert_equal 'R.0', s4.to_s
    end
  end
end

##########################################################################################
# prettyCommonFunctions.rb

#   We start with the base functions and move to larger ones
class PrettyCommonFunctionsTester < BalyTester
  # The rest of the files are function based, so we test each function individually,
  # and give a short explanation of each one. Smaller functions are combined when possible.

  # getCatType()
  #   IN: a classification of a slide
  #   OUT: the system of this classification, either "VRC" or "Baly" or "N/A" (if not parseable)
  class GetCatTypeTester < PrettyCommonFunctionsTester
    # This function currently isn't being used, and is replaced by the
    # classSystem method of Classifications, so it is only lightly tested.
    def test_basic
      assert_equal 'VRC', getCatType('B45.555')
      assert_equal 'Baly', getCatType('A.004')
      assert_equal 'Baly', getCatType('BA.042')
      assert_equal 'Baly', getCatType('BG.100')
      assert_equal 'N/A',  getCatType('BG.200')
      assert_equal 'N/A',  getCatType('BFSDFE')
    end
  end

  # generateUniqueFilename(title,extension)
  #   IN: A string title and a string file extension (default xls)
  #   OUT: a filename composed of the title, digits corresponding
  #        with the current time, and the appropriate extension
  class GenerateUniqueFilenameTester < PrettyCommonFunctionsTester
    def test_basic
      # Normal use
      tfile1 = generateUniqueFilename('sampleAPIdata', 'xls')
      assert_equal 'sampleAPIdata', tfile1[0..12]
      assert_equal 'xls', tfile1[-3..-1]
    end

    def test_long_titles
      tfile2 = generateUniqueFilename('loooooooooooooooooooooooooooooooooooooooooooooooooooooongname', 'pdf')
      assert_equal 'loooooooooooooooooooooooooooooooooooooooooooooooooooooongname', tfile2[0..60]
      assert_equal 'pdf', tfile2[-3..-1]
    end

    def test_defaults
      # No extension provided
      tfile3 = generateUniqueFilename('title')
      assert_equal 'title', tfile3[0..4]
      assert_equal 'xls', tfile3[-3..-1]
    end
  end

  # parseSlideRange()
  #   IN: a series of comma separated ranges similar to A.001-002.
  #   OUT: A nested array containing three elements:
  #         1. Array of individual classifications contained in the ranges
  #         2. Max of range
  #         3. Min of range
  # The general formatting rules are simple, and quite flexible.
  #   1. The first item must be a complete classification, ie, a B00 number or alphanumeric
  #   2. No half of a range can include more that 3 digits
  #   3. The second half of a range always carries the group from the first half, and never includes it
  # From these simple rules, we separate each range by commas, and omit common info where possible.
  # The sequence of ranges ends at the first period, allowing it to be integrated into notes.
  class ParseSlideRangeTester < PrettyCommonFunctionsTester
    # This function, on the other hand, is an important dependency for bigger
    # ones like indexConverter, and so is extensively tested.
    def test_best_case
      a1 = [['F.005', 'F.006', 'F.007', 'F.008'], 'F.005', 'F.008']
      assert_equal a1, parseSlideRange('F.005-008')
    end

    def test_normal_case
      # These are the conventions used in the ClassificationData.rb ranges
      # In this format, VRC ranges always have three digits after the decimal, and Baly ones typically have two (unless its 100).
      a1 = [['A.001', 'A.002', 'A.003', 'A.004', 'A.005'], 'A.001', 'A.005']
      assert_equal a1, parseSlideRange('A.001-005')
      a2 = [['HI.042', 'HI.043', 'HI.044', 'HI.045', 'HI.046', 'HI.047', 'HI.048', 'HI.049', 'HI.050'], 'HI.042',
            'HI.050']
      assert_equal a2, parseSlideRange('HI.42-50')
      a3 = [
        ['B23.012', 'B23.013', 'B23.014', 'B23.015', 'B23.016', 'B23.017', 'B23.018', 'B23.019', 'B23.020',
         'B23.021', 'B23.022', 'B23.023', 'B23.024', 'B23.025', 'B23.026', 'B23.027', 'B23.028', 'B23.029',
         'B23.030', 'B23.031', 'B23.032', 'B23.033', 'B23.034', 'B23.035', 'B23.036', 'B23.037', 'B23.038',
         'B23.039', 'B23.040', 'B23.041', 'B23.042', 'B23.043'],
        'B23.012', 'B23.043'
      ]
      assert_equal a3, parseSlideRange('B23.012-043')
      a4 = [['B02.300', 'B02.301', 'B02.302', 'B02.303', 'B02.304'], 'B02.300', 'B02.304']
      assert_equal a4, parseSlideRange('B02.300-304')
      a5 = [['A.090', 'A.091', 'A.092', 'A.093', 'A.094', 'A.095', 'A.096', 'A.097', 'A.098', 'A.099', 'A.100'], 'A.090',
            'A.100']
      assert_equal a5, parseSlideRange('A.90-100')
    end

    def test_multiple_ranges
      a1 = [['A.001', 'B.002', 'B.003', 'B.004', 'C.002'], 'A.001', 'C.002']
      assert_equal a1, parseSlideRange('A.01,B.002-4,C.2')
      a2 = [['A.003', 'B.005', 'B.006', 'B.007', 'C.010', 'C.011', 'C.012', 'C.013', 'C.014',
             'C.015', 'C.016', 'C.017', 'C.018', 'C.019', 'C.020'], 'A.003', 'C.020']
      assert_equal a2, parseSlideRange('A.3,B.5-7,C.10-20')
    end

    def test_VRC_case
      a1 = [['B45.321', 'B45.322', 'B45.323', 'B45.324', 'B45.325', 'B45.326', 'B45.327', 'B45.328', 'B45.329', 'B45.330'],
            'B45.321', 'B45.330']
      assert_equal a1, parseSlideRange('B45.321-30')
      a2 = [
        ['B32.034', 'B32.035', 'B32.036', 'B32.037', 'B32.038', 'B32.039', 'B32.040', 'B32.041', 'B32.042', 'B32.043',
         'B43.004'], 'B32.034', 'B43.004'
      ]
      assert_equal a2, parseSlideRange('B23.013-8,B43.4,B32.034-43')
    end

    def test_long_range
      pref = 'B43.'
      arr = []
      (4..300).each do |i|
        stri = i.to_s
        stri = '0' + stri while stri.length < 3
        num = pref + stri
        arr.push num
      end
      a1 = [arr, 'B43.004', 'B43.300']
      assert_equal a1, parseSlideRange('B43.004-300')
    end

    def test_singleton
      assert_equal [['B43.004'], 'B43.004', 'B43.004'], parseSlideRange('B43.004')
      assert_equal [['B43.004'], 'B43.004', 'B43.004'], parseSlideRange('B43.4')
      assert_equal [['AF.042'], 'AF.042', 'AF.042'], parseSlideRange('AF.42')
      assert_equal [['BG.001'], 'BG.001', 'BG.001'], parseSlideRange('BG.1')
    end
  end
end

##########################################################################################
# indexConverter.rb

class IndexConverterTester < BalyTester
  class ExpandBhashRangeTester < IndexConverterTester
    def test_easy
      b45s = ['B45.0', 'B45.1', 'B45.2', 'B45.3', 'B45.4', 'B45.5', 'B45.6', 'B45.7', 'B45.8', 'B45.9']
      assert_equal b45s, expandBhashRange('B45.0-45.9')
      b44s = ['B44.2', 'B44.3', 'B44.4', 'B44.5', 'B44.6', 'B44.7', 'B44.8']
      assert_equal b44s, expandBhashRange('B44.2-44.8')
    end

    def test_singleton
      assert_equal ['B12'], expandBhashRange('B12')
      assert_equal %w[B1 B01], expandBhashRange('B01')
    end

    def test_around_the_horn
      assert_equal ['B47.8', 'B47.9', 'B48.0', 'B48.1'], expandBhashRange('B47.8-48.1')
      assert_equal ['B49.9', 'B50.0', 'B50.1'], expandBhashRange('B49.9-50.1')
    end
  end

  # We will skip the getBalySorthashkey function because it depends on the constant BalySorthash, which could change in the future.
  # Besides, the function relies on intRangeIncludes? and the BalySorthash, and any errors in BalySorthash will show up when we test the indexConverter function.
  class IntRangeIncludesTester < IndexConverterTester
    def test_normal
      assert intRangeIncludes?('1000-2000', 1500)
      assert !intRangeIncludes?('1000-2000', 900)
      100.times do
        testval = rand(100_000)
        assert intRangeIncludes?('0-100000', testval)
        assert !intRangeIncludes?('100001-100400', testval)
      end
      assert intRangeIncludes?('11035-11037', 11_035)
      assert intRangeIncludes?('11035-11037', 11_036)
      assert intRangeIncludes?('11035-11037', 11_037)
      assert !intRangeIncludes?('11035-11037', 11_038)
    end

    def test_singleton
      assert intRangeIncludes?('450024', 450_024)
      assert !intRangeIncludes?('450024', 450_023)
      assert intRangeIncludes?('123456789', 123_456_789)
      assert !intRangeIncludes?('123456789', 123_456_790)
    end
  end

  class TranslateRangeElementTester < IndexConverterTester
    def setup
      # for setup we pull some ranges from classificationdata.rb
      # First is a very typical one, in groups of 100
      @d1 = 'B48.113-212'
      @c1 = 'CH.001-100'
      # Second is less typical, being a nonstandard size
      @d2 = 'B48.001-12'
      @c2 = 'FL.089-100'
    end
    def test_hundreds
      baseclassification = Classification.new 'B48.113'
      basereturn = Classification.new('CH.001')
      (100).times do |i|
        assert_equal translateRangeElement(baseclassification,@d1,@c1).to_s,basereturn.to_s
        increaseClassification baseclassification
        increaseClassification basereturn
      end
    end
    def test_twelve
      baseclassification = Classification.new 'B48.001'
      basereturn = Classification.new 'FL.089'
      (12).times do
        assert basereturn.to_s, translateRangeElement(baseclassification,@d2,@c2).to_s
        increaseClassification baseclassification
        increaseClassification basereturn
      end
    end
  end
  class ScanRangeHashTester < IndexConverterTester
    def setup
      # copy sample hashes
      @sampleException = {
        "B03.093" => "C.094",
        "B03.094" => "C.093"    
      }
      @sampleFull = {
        "B44.001" => "EM.67",
        "B44.002-009" => "EM.69-76",
        "B44.010-015" => "EM.78-83",
        "B44.016" => "EN.02",
        "B44.017-018" => "EM.91-92",
        "B44.019" => "EN.03",
        "B44.020" => "EM.84",
        "B44.21-30" => "EM.93-102",
        "B44.031-032" => "EM.89-90",
        "B44.033" => "EM.85",
        "B44.034" => "EM.88",
      }
    end
    def test_excepts
      in1 = Classification.new 'B03.093'
      out1 = Classification.new 'C.094'
      assert_equal out1.to_s,scanRangeHash(in1,@sampleException).to_s
      assert_equal in1.to_s,scanRangeHash(out1,@sampleException,true).to_s
      in2 = Classification.new 'B03.094'
      out2 = Classification.new 'C.093'
      assert_equal out2.to_s,scanRangeHash(in2,@sampleException).to_s
      assert_equal in2.to_s,scanRangeHash(out2,@sampleException,true).to_s
    end

    def test_full
      in1 = Classification.new 'B44.001'
      out1 = Classification.new 'EM.067'
      assert_equal out1.to_s,scanRangeHash(in1,@sampleFull).to_s
      assert_equal in1.to_s,scanRangeHash(out1,@sampleFull,true).to_s
      in2 = Classification.new 'B44.004'
      out2 = Classification.new 'EM.071'
      assert_equal out2.to_s,scanRangeHash(in2,@sampleFull).to_s
      assert_equal in2.to_s,scanRangeHash(out2,@sampleFull,true).to_s
      test_cases = {
        'B44.002' => 'EM.69',
        'B44.003' => 'EM.70',
        'B44.004' => 'EM.71',
        'B44.005' => 'EM.72',
        'B44.006' => 'EM.73',
        'B44.007' => 'EM.74',
        'B44.008' => 'EM.75',
        'B44.009' => 'EM.76'
      }
  
      test_cases.each do |input_code, expected_output_code|
        in_classification = Classification.new(input_code)
        out_classification = Classification.new(expected_output_code)
  
        # Test forward mapping
        assert_equal out_classification.to_s, scanRangeHash(in_classification, @sampleFull).to_s
        # Test reverse mapping
        assert_equal in_classification.to_s, scanRangeHash(out_classification, @sampleFull, true).to_s
      end
    end
  end
  class IndexConverterFuncTester < IndexConverterTester
    def setup
      @test_cases = {
        'B49.196' => 'CS.015',
        'B49.197' => 'CS.016',
        'B49.198' => 'CS.017',
        'B49.199' => 'CS.018',
        'B49.200' => 'CS.019',
        'B49.201' => 'CS.020',
        'B49.202' => 'CS.021',
        'B49.203' => 'CS.022',
        'B49.204' => 'CS.023',
        'B49.205' => 'CS.024',
        'B49.206' => 'CS.025',
        'B49.207' => 'CS.026',
        'B49.208' => 'CS.027',
        'B49.209' => 'CS.028',
        'B49.210' => 'CS.029',
        'B49.211' => 'CS.030',
        'B49.212' => 'CS.031',
        'B49.213' => 'CS.032',
        'B49.214' => 'CS.033',
        'B49.215' => 'CS.034',
        'B49.216' => 'CS.035',
        'B49.217' => 'CS.036',
        'B49.218' => 'CS.037',
        'B49.219' => 'CS.038',
        'B49.220' => 'CS.039',
        'B49.221' => 'CS.040',
        'B49.222' => 'CS.041',
        'B49.223' => 'CS.042',
        'B49.224' => 'CS.043',
        'B49.225' => 'CS.044',
        'B49.226' => 'CS.045',
        'B49.227' => 'CS.046',
        'B49.228' => 'CS.047',
        'B49.229' => 'CS.048',
        'B49.230' => 'CS.049',
        'B49.231' => 'CS.050',
        'B49.232' => 'CS.051',
        'B49.233' => 'CS.052',
        'B49.234' => 'CS.053',
        'B49.235' => 'CS.054',
        'B49.236' => 'CS.055',
        'B49.237' => 'CS.056',
        'B49.238' => 'CS.057',
        'B49.239' => 'CS.058',
        'B49.240' => 'CS.059',
        'B49.241' => 'CS.060'
      }  
    end
    def test_string_in
      @test_cases.each do |key,value|
        assert_equal value, indexConverter(key).to_s
        assert_equal key, indexConverter(value).to_s
      end
    end
    def test_classification_in_classification_out
      @test_cases.each do |key,value|
        assert_equal Classification.new(value).to_s, indexConverter(Classification.new(key)).to_s
        assert_equal Classification.new(key).to_s, indexConverter(Classification.new(value)).to_s
      end
    end
  end
  class GenerateSortingNumbersTester < IndexConverterTester
    def setup
      @sampledata = {
        59080 => 'B45.769',
        59081 => 'B45.770',
        59082 => 'B45.771',
        59083 => 'B45.772',
        96001 => 'B49.082',
        96002 => 'B49.083',
        96003 => 'B49.084'
      }
    end
    def test_all
      @sampledata.each do |key,value|
        assert_equal key, generateSortingNumbers([value])[0]
      end
      assert_equal @sampledata.keys, generateSortingNumbers(@sampledata.values)
    end
  end
end

##########################################################################################
# kmlParser.rb

class KmlParserTester < BalyTester
  def setup
    simplekml = "<Document> \n <name>Simple Title</name> \n  <Placemark>\n      <name>Simple Title</name>\n      <description>Sample description</description> \n      <styleUrl>#icon-1899-0288D1</styleUrl>\n      <Point>\n        <coordinates>\n          2,1,0\n        </coordinates>\n      </Point>\n    </Placemark> \n          <Placemark> \n <name>BG.06 Angle</name>\n <styleUrl>#line-000000-1200-nodesc</styleUrl>\n  <LineString>\n  <tessellate>1</tessellate>\n <coordinates>\n 2,1,0 \n   3,2,0 \n  </coordinates> \n  </LineString> \n </Placemark> \n </Document>"
    samplekml1 = "<?xml?>
    <kml>
      <Document>
        <name>BG - Kermanshah and Bisutun</name>
        <Style>
          <IconStyle>
            <color>ffd18802</color>
            <scale>1</scale>
            <Icon>
              <href>https://www.gstatic.com/mapspro/images/stock/503-wht-blank_maps.png</href>
            </Icon>
            <hotSpot>
          </IconStyle>
          <LabelStyle>
            <scale>0</scale>
          </LabelStyle>
        </Style>
        <Placemark>
          <name>Kermanshah</name>
          <description>BG.001-06</description>
          <styleUrl>#icon-1899-0288D1</styleUrl>
          <Point>
            <coordinates>
              47.0777685,34.3276924,0
            </coordinates>
          </Point>
        </Placemark>
        <Placemark>
          <name>BG.06 - Kurds on Route to Kermanshah</name>
          <description>Possible Location. The mountains in the background allow us to place this image northwest of Kermanshah, facing the mountains. However the location given is not precise beyond this, and just a guess at a spot along a major road.</description>
          <styleUrl>#icon-1899-0288D1</styleUrl>
          <Point>
            <coordinates>
              47.0810041,34.3881913,0
            </coordinates>
          </Point>
        </Placemark>
        <Placemark>
          <name>BG.06 Angle</name>
          <styleUrl>#line-000000-1200-nodesc</styleUrl>
          <LineString>
            <tessellate>1</tessellate>
            <coordinates>
              47.0810041,34.3881913,0
              47.0317336,34.4425962,0
            </coordinates>
          </LineString>
        </Placemark>
        <Placemark>
          <name>BG.29 - Inscription of Darius I</name>
          <description>Estimated Location</description>
          <styleUrl>#icon-1899-0288D1</styleUrl>
          <Point>
            <coordinates>
              47.4363682,34.390528,0
            </coordinates>
          </Point>
        </Placemark>
        <Placemark>
          <name>BG.29 Angle</name>
          <styleUrl>#line-000000-1200-nodesc</styleUrl>
          <LineString>
            <tessellate>1</tessellate>
            <coordinates>
              47.4363682,34.390528,0
              47.4362534,34.3904965,0
            </coordinates>
          </LineString>
        </Placemark>
      </Document>
    </kml>"
    IO.write('testing.kml', simplekml)
    @simplekml = KML.new('testing.kml')
    File.delete('testing.kml')

    IO.write('testing.kml', samplekml1)
    @kml = KML.new('testing.kml')
    @stringkml = KML.new(samplekml1)
    File.delete('testing.kml')
  end
  class KMLTester < KmlParserTester
    def test_basic
      # Simple case
      assert_equal 'Simple Title', @simplekml.title
      assert_equal 1, @simplekml.points.length
      assert_equal 1, @simplekml.lines.length
      # Check attributes. The two KML objects should be equal in every respect so we check them both
      doctitle = 'BG - Kermanshah and Bisutun'
      assert_equal doctitle, @kml.title
      assert_equal doctitle, @stringkml.title
      assert_equal 3, @kml.points.length
      assert_equal 3, @stringkml.points.length
      assert_equal 2, @kml.lines.length
      assert_equal 2, @stringkml.lines.length
    end

    def test_points
      simplepoint = @simplekml.points[0]
      assert_equal 'Simple Title', simplepoint.title
      assert_equal [1, 2], simplepoint.coords

      points = @kml.points
      genpt = points[0]
      assert_equal 'Kermanshah', genpt.title
      assert_equal 'BG.001-06', genpt.description
      assert_equal '[34.3276924, 47.0777685]', genpt.coords.to_s
    end

    def test_angle
      # simple case
      simpleline = @simplekml.lines[0]
      assert_equal [[1, 2], [2, 3]], simpleline.coords
      assert_equal '45 degrees NE', simpleline.angle
      # real case
      (line1, line2) = @kml.lines
      assert_equal 'BG.06 Angle', line1.title
      assert_equal 'BG.29 Angle', line2.title
      assert_equal '320 degrees NW', line1.angle
      assert_equal '255 degrees W', line2.angle
    end
  end
  class SplitLocationsTester < KmlParserTester
    # KML files store
    def test_normal
      assert_equal ['5678','1234'], splitLocations("1234,5678")
    end
    def test_large 
      assert_equal ['10.0040230005','1234567899'], splitLocations('1234567899,10.0040230005')
    end
  end
  
  class WriteToXlsWithClassTester
  end

  class SwapSlideIdentifierTester < KmlParserTester
    def test_basic
      title = 'B32.042 - Basic title stuff'
      desc = 'Any description will do'
      exp_title = 'Basic title stuff'
      exp_desc = 'B32.042 Any description will do'
      assert_equal [exp_title, exp_desc], swapSlideIdentifier(title, desc)
    end

    def test_bad_format
      title1 = 'B32.042-Basic title stuff'
      desc = 'Any description will do'
      exp_title = 'Basic title stuff'
      exp_desc = 'B32.042 Any description will do'
      assert_equal [exp_title, exp_desc], swapSlideIdentifier(title1, desc)

      title2 = 'B32.042- Basic title stuff'
      assert_equal [exp_title, exp_desc], swapSlideIdentifier(title2, desc)

      title3 = 'B32.042 -Basic title stuff'
      assert_equal [exp_title, exp_desc], swapSlideIdentifier(title3, desc)
    end
  end

  class AddLocationToSlideTester < KmlParserTester
    def setup
      @descriptions = {
        'specific' => [
          'A.001 Likely location at 270 degrees W',
          'B.042 Estimated location at 185 degrees S',
          'A.010 likely location at 70 degrees E',
          'A.014 likely location facing up. Notable notes are noted previously',
          'A.083 likely location at 10 degrees N. Structures in background are the fountains (sebils) of Qasim Pasha and Qayt Bay.'
        ],
        'general' => [
          'BG.017,18, 23, 24',
          'AC.042-51',
          'QA.079-90. Notes on this as well'
        ]
      }
    end

    def test_specific_loc
      @descriptions['specific'].each do |desc|
        slide = Slide.new "B42.241"
        addLocationToSlide(slide,['24.12345','99.54321'],'A Title',desc)
        loc = slide.specificLocation
        assert_equal 'A Title', loc.title
        assert (['estimated', 'likely'].include? loc.precision),"Precision value #{loc.precision} not in range"
        assert loc.angle.degrees > -2
        assert (['N','NE','E','SE','S','SW','W','NW','UP','DOWN'].include? loc.angle.direction), "Direction value #{loc.angle.direction} not in range"
      end
    end
    def test_all
      @descriptions.each do |key, array|
        array.each do |desc|
          slide = Slide.new 'B21.053'
          addLocationToSlide(slide,['24.12345','99.54321'],'A Title',desc)
          if key == 'specific'
            loc = slide.specificLocation
          elsif key == 'general'
            loc = slide.generalLocation
            assert_equal 'A Title', loc.name
          end
          assert_equal ['24.12345','99.54321'], loc.coords
          if desc.include? ". "
            assert loc.notes.length > 3
          end
        end
      end
    end
  end

  class StripDataTester < KmlParserTester
    def test_empty
      descs = ['BG.017,18, 23, 24','AC.042-51']
      descs.each do |desc|
        assert_equal '', stripData(desc)
      end
    end
    def test_only_notes
      desc = 'QA.079-90. Notes on this as well'
      assert_equal 'Notes on this as well', stripData(desc)
    end
    def test_angles
      desc1 = 'A.001 Likely location at 270 degrees W'
      assert_equal [' Likely location at 270 degrees W',0],stripData(desc1)
      desc2 =  'B.042 Estimated location at 185 degrees S'
      assert_equal [' Estimated location at 185 degrees S',0],stripData(desc2)
      desc3 =  'A.010 likely location at 70 degrees E'
      assert_equal [' likely location at 70 degrees E',0], stripData(desc3)
    end
    def test_specific_notes
      desc1 = 'A.014 likely location facing up. Notable notes are noted previously'
      assert_equal [' likely location facing up','Notable notes are noted previously'],stripData(desc1)
      desc2 = 'A.083 likely location at 10 degrees N. Structures in background are the fountains (sebils) of Qasim Pasha and Qayt Bay.'
      assert_equal [' likely location at 10 degrees N','Structures in background are the fountains (sebils) of Qasim Pasha and Qayt Bay.'], stripData(desc2)
    end
  end
  class FormatSpreadsheetTester < KmlParserTester
    def test_all
      require 'spreadsheet'
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      formatspreadsheet(sheet)
      assert_equal ["Sorting Number","Slide Title","Baly Cat","VRC Cat","General Place Name","General Coordinates","Specific Coordinates","Direction","Precision","Notes","City","Region","Country"], Array.new(sheet.row(1))
    end
  end

  class FormatSlideDataTester < KmlParserTester
    def test_basic
      slide = Slide.new 'A.001'
      slide.addAltID('B01.001')
      slide.addTitle('Jerusalem')
      slide.addLocation([[10, 20], 'Place Name', 'Some notes'],false,false)
      slide.addLocation([[2, 2], 'possible location at 0 degrees N', 'Some medium notes', 'Some medium title'],true,false)
      expArray = [
        1001,
        'Some medium title',
        'A.001','B01.001',
        'Place Name',
        "(10,20)",
        "(2,2)",
        '0 degrees N',
        'possible',
        'Some notesSome medium notes', 0, 0, 0
      ]
      assert_equal expArray,formatSlideData(slide)
    end
  end

  class FormatCoordsTester < KmlParserTester
    def test_basic
      coords = [45.123, 78.456]
      result = formatCoords(coords)
      assert_equal('(45.123,78.456)', result)
    end
  end

  class ReadXLSCcolumnTester < KmlParserTester
    def test_simple
      require 'spreadsheet'
      # Create test XLS file
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      sheet[0,0] = "A1"
      sheet[1,0] = "A2" 
      sheet[2,0] = "A3"
      test_file = Tempfile.create(['test_one.xls','.xls'])
      book.write test_file.path
      # Test reading first column
      result = readXLScolumn(test_file, 0, 0)
      assert_equal ["A1", "A2", "A3"], result
    end

    def test_full_sheet
      require 'spreadsheet'
      # Create test XLS file
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet
      sheet.row(0).replace ['1','2','3']
      sheet.row(1).replace ['4','5','6']
      sheet.row(2).replace ['7','8','9']
      test_file = Tempfile.create(['test_two.xls','.xls'])
      book.write test_file.path
      assert_equal ['1','4','7'], readXLScolumn(test_file, 0, 0)
      assert_equal ['2','5','8'], readXLScolumn(test_file, 0, 1)
      assert_equal ['3','6','9'], readXLScolumn(test_file, 0, 2)
    end
  end

  class WriteXLSfromColArrayTester < KmlParserTester
    def test_with_headers
      require 'spreadsheet'

      test_file = Tempfile.create ['test','.xls']
      headers = ["Col1", "Col2"]
      data = [["A1", "A2"], ["B1", "B2"]]

      writeXLSfromColArray(test_file.path, data, headers)

      book = Spreadsheet.open(test_file.path)
      sheet = book.worksheet(0)

      assert_equal headers[0], sheet[0,0]
      assert_equal headers[1], sheet[0,1]
      assert_equal "A1", sheet[1,0] 
      assert_equal "A2", sheet[2,0]
      assert_equal "B1", sheet[1,1]
      assert_equal "B2", sheet[2,1]
    end
    def test_write_xls_empty_data
      require 'spreadsheet'
      tfile = Tempfile.create(['empty_test','.xls'])
      headers = ["Col1", "Col2"]
      data = []
    
      writeXLSfromColArray(tfile.path, data, headers)

      book = Spreadsheet.open(tfile.path)
      sheet = book.worksheet(0)
      assert_equal headers[0], sheet[0,0]
      assert_equal headers[1], sheet[0,1]
      assert_nil sheet[1,0]
      assert_nil sheet[1,1]
    end
  end
end
