# Baly Project Code
##### A collection of ready-to-use tools and classes for the Denis Baly Slide Collection
***
## How to Open and Run in a Terminal
* ****Install Ruby****
  - Mac instructions
    
    Open a terminal window, and type the following commands 
    ```sh
    echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.zshrc
    source ~/.zshrc

    rbenv install 3.3.5
    rbenv global 3.3.5
    ```

    Now Ruby version 3.3 should be installed and set as default. To make sure everything is right, type 
    ```sh
    ruby -v
    ```
    and the output should be something like this 
    ```sh
    ruby 3.3.5 (2023-12-25 revision 5124f9ac75) [x86_64-darwin20]
    ```
  - Windows instructions
    
    Download the installer at [https://rubyinstaller.org/](https://rubyinstaller.org/)

  - Linux instructions

  Then we install dependencies with the command
  ```sh
  bundle install
  ```
* ****Download Program****

    At the top of this (the main) webpage for the project, click the button titled 'Code' and a dropdown will appear. If you do not have a github account, press the option to download it as a zip file, and then unzip it on your computer and put the folder somewhere convenient to find.
  
    If you have a github account, you can copy the https link from the dropdown. Then in your terminal, navigate to the folder you would like to put the download in. Then type the following line of code into the command line
    ```sh
    git clone pastedhttpslink
    ```
    it will then prompt you for your github username and password before downloading the folder.
* ****Navigate to Folder****

    Open a terminal window and navigate to the BalyProjectCode folder using the Change Directory (`cd`) command. For example, a terminal on startup will usually start at your user, and on a windows terminal, the prompt may look something like 
    ```sh
    C: Users/GenericUsername>
    ```
   Suppose the BalyProjectCode folder is in your downloads. Then you would type the following command into the terminal:
   ```sh
   cd Downloads/BalyProjectCode
   ```
   to see something like 
   ```sh
   C: Users/GenericUsername/Downloads/BalyProjectCode>
   ```
   The terminal will always display the current folder in the prompt, so once you see BalyProjectCode as in the example above you know you are finished.

* ****Start Session and Load****
  
   Once you are in the right folder, start an inline Ruby session by typing `irb` into the command line and press enter. If your computer has ruby pre-installed, your command prompt should read `irb(main):001:0>`. If you attempt this but encounter an error, you may not have ruby correctly installed, and you can find the directions at [Kenyon College CompSci Dept](https://cs.kenyon.edu/index.php/comp-318-software-development-s24/) in the schedule item for January 18th. 

    Once you're in the Ruby session, load the methods file by typing this command
    ```sh
    load('autoMethods.rb')
    ```
    When you press enter, it should display some warning dialog, which is completely fine as long as the last line it displays is 
    ```sh
    => true
    ```
    Now you are ready to use any of the available methods below
***

## Current Methods
#### Keywords Tool
An HTML page that allows for easy creation and analysis of keyword lists

[Instructions](#how-to-use-keywords-tool)

#### mapKMLtoXLS
Reads a kml file downloaded from a Google MyMaps Project (such as Baly Locations), sorts the location data by slide, and produces a xls file with all the info.

[Instructions](#how-to-use-mapkmltoxls)

#### addSortingNumbers
Reads a column containing Baly Classifications from an xls file and generates a column with the corresponding sorting numbers for each row.

[Instructions](#how-to-use-addsortingnumbers)

#### fillJSON
Reads a spreadsheet and generates the JSON necessary for use in the Baly Gallery website

[Instructions](#how-to-use-filljson)

#### fillImageNotes
Reads a spreadsheet and generates the Image Notes field for each slide, a formulaic summary of creation date and documented info.

[Instructions](#how-to-use-fillimagenotes)

#### formatReferences
Reads a spreadsheet row of Chicago formatted references and generates an HTML version to be included on Digital Kenyon

[Instructions](#how-to-use-formatreferences)

***

## How to use Keywords Tool
* ****Open file from folder****
  
  Open the balyProjectCode folder and click on the file "keywords.html". A webpage will open in the browser and a single textbox will appear.
* ****Paste Keywords****
  
  Open the Baly Slide Index and select the entire keywords column by clicking on the bar above it. You can deselect the header row if you like, then copy the selection. Return to the Keyword Tool tab and either press "Paste and Go" or paste into the textbox and press the "Go" button at the bottom.

* ****Write Keywords****
  
  As you type a keyword into the searchbar, it will search the existing keywords and show the top results. You can click these results to add them to a running list, or press enter to add the top result. If the keyword you would like to add does not exist, continue typing until no results appear. Then pressing enter will add the word to the list, and make it available for subsequent searches.

* ****Export to Spreadsheet****

  When the list is complete, press the copy button on top of the list to copy it to your clipboard. Reopen the Baly Slide Index and paste it into the Keywords cell of the corresponding slide. When you begin the next slide, you can press the red button at the top of the list to clear it.

* ****Bugs****

  Note that you may encounter the problem of trying to add a keyword that is contained by another keyword (eg. adding "Word" when "Keyword" already exists). To add these words, complete the list without it and export the list to the Index. Add the missing word directly into the cell, refresh the Keyword Tool and recopy the keywords column with the new word included.

## How to Use mapKMLtoXLS
* ****Download kml file from MyMaps****

    Open a Google MyMaps project in your browser and click the three dots at the top right of the side panel. From this menu, select **Export to KML/KMZ**. In the selector showing "Entire Map," change the selection to a single layer that you are trying to transform. Then click the checkbox titled **Export as KML instead of KMZ** and press the "Download" button. Then move the kml file to the BalyProjectCode folder (where this `README` file is located).
* ****Use the Method****
  
    Make sure you have a terminal window prepared using the instructions at the top of this page. Then type the following code into the command line 
    ```sh
    mapKMLtoXLS('yourkmlfilename')
    ```
    where yourkmlfilename is the name of the kml file you downloaded above, making sure it ends in '.kml' (add it if not). This will generate an xls file with a name based on the kml file name. This xls file will appear in the BalyProjectCode folder, and you can open it using excel.
    
* **Options**
  
    If you would like to specify the name of the xls file, you can instead type 
    ```sh
    mapKMLtoXLS('yourkmlfilename','newxlsfilename')
    ```
    as long as newxlsfilename is a sequence of characters ending in '.xls'
    
    If you would not like to get a spreadsheet organized by slide, but instead want a direct transcription of the kml file (organized by location entry), type 
    ```sh
    mapKMLtoXLS('yourkmlfilename','newxlsfilename',"straight")
    ```
    using the same filenames from the previous steps.
***
## How to Use addSortingNumbers
* ****Create Input Spreadsheet****

    To start, we will need to open our spreadsheet table containing a column of Baly (alphanumeric) classifications. Then start a new spreadsheet, give it a name, and save it in BalyProjectCode as an 'Excel 97-2003 Workbook (.xls)" file. *You should check the file in your system to make sure it is not a .xlsx*. If you are working off a cloud spreadsheet (such as the Baly Slide Index, export it to a .xls file.
    Then copy the entire row of baly classifications and paste it into the new .xls spreadsheet, in the second row (leaving a row for the sorting numbers to the left). Then clear everything that is not a Baly Classification from the top of the column, and delete those rows from the spreadsheet to shift the remainder of the column upwards, before saving the file *and closing it*.
* ****Use the Method****

    Open a terminal window and Ruby session using the instructions above, and then type the following code into the command line
    ```sh
    require_relative "autoMethods.rb"
    addSortingNumbers('inputfilename')
    ```
    The program will create a new file titled NewSpreadsheet, with a random sequence of numbers following this and ending in .xls. The new spreadsheet will contain the sorting numbers in the first column and the classifications used in the second. There are options for the method as well, but these will be discussed at the end.
    Open the new spreadsheet, and do a quick check to make sure the sorting numbers look alright. You should mostly be checking that the numbers line up, and any blank rows in the classifications row have blank entries in the Sorting Number row. If everything looks good, you can copy the column of sorting numbers and paste it into your original spreadsheet, lining up the first number with the first classification that was used.
* ****Method Options****

    The first method option is to select a new filename for the automatically generated spreadsheet. This has to be a collection of characters ending in .xls, and you would type
  ```sh
  addSortingNumbers('inputfilename','resultfilename')
  ```
  Sometimes it is more convenient to read from an original document than to copy-paste into a new input spreadsheet, although it is much more time consuming for the program to read a large spreadsheet compared to one with the one column it needs. If you are doing this, you need to find what worksheet the column you need is in (starting from 0), and the column number (starting from 0) that is the one you need. You then type this code into the command line
  ```sh
  addSortingNumbers('inputfilename','resultfilename',worksheetNumber,columnNumber)
  ```
  where worksheetNumber and columnNumber are both integer values, with the first worksheet being number 0, and the first column being number 0.

***
### Generating an Input.xls
The rest of the methods require the data in .xls format, so it will be helpful to keep one in the BalyProjectCode folder and reuse it. Follow these instructions to make it.
* ****Open a blank new excel document****, and immediately save it as "Input". In the save options, select Excel 97-2003 (xls) and save it to the BalyProjectCode folder. Open the folder and ensure it is saved as a .xls. Then reopen it and select the entire sheet by clicking in the top left corner. Change the cell format for this selection from 'General' to 'Text'.

* ****Copy Data from Index****
Open the Baly Slide Index Google sheet, and copy the header row from the top. Paste this into the top row of Input.xls. Then copy and paste the rows you would like to work on. Note that methods working on input.xls should be resistant to input errors, so the inclusion of incomplete rows as part of the selection is ok. However you should be careful not to copy incomplete derived data back to the Index.

* ****Save and close Input.xls****

***
## How to use fillJSON
* ****Generate Input.xls**** using the [instructions here.](#generating-an-inputxls) If you have an existing Input.xls, clear the contents and double-check it is formatted as text.

* ****Use the method****
    Open and prepare a terminal using the instructions at the top of the page. Then enter 
    ```sh 
    fillJSON('input.xls') 
    ``` 
    This will read the info from Input.xls and generate a new spreadsheet titled "JSONaddedXXXX.xls, where XXXX is a number sequence tied to the minute and second it was produced. 

* ****Verify Correctness and Export****
Open the JSONadded sheet and widen the JSON column so that the data is readable. Then make sure that nothing looks incomplete by comparing it to existing JSON records (those in A: Jerusalem are good examples). Pay particular attention to the dates, and make sure it corresponds with the input data. When the data looks good, copy the JSON column from the JSONadded file and paste it into the corresponding cells in the Baly Slide Index.

***
## How to use fillImageNotes


## How to use formatReferences
