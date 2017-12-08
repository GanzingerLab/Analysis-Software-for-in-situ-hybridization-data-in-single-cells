# Prerequisites:

• 	Data need to be in .tif format with separate, same-sized images for the different colours. 

•	Pairs or triplets of files need to be identified by their file name starting with an Arabic number (index) and need to contain additionally either the letters 'B' or 'R' (or 'Y' for three colour data) to indicate the channel, e.g. 1B, 1R or 23R ,23B, 23Y. The letter code for the colour can be changed in function "get_tiffs" or "get_tiffs_threecolours" in lines 10, 11, 12.

•	Batch processing of a series of datasets is implemented; data sets need to be organised in directories (one directory per data set). 

# How to run the software:
•	copy the main function Single_cell_FISH_analysis.m and the source code (folder: "source codes") into a local directory

•	open the main function in MATLAB and run the code by pressing F5/"Run"

•	You will be prompted to set some parameters in three subsequent GUIs

•	After confirmation of the settings in the last GUI, the software will run without user input unless an interactive option is selected 


# Explanation of GUI Parameters:

[GUI I](ignore/parameters-explained.png)


[GUI II](ignore/GUIobjectiveselection.png): selection of objective used for image acquisition (sets magnification and pixel size)
 
Objectives can be added/removed in function parameter_setup_auto by adding a new case to the switch in line 3. 

[GUI III](ignore/GUIbatchrun.png) and [GUI IV](ignore/batchpathprompt.png): select ‘Yes’ to run multiple sets of images (data are pooled for each individual data set) or ‘No’ to run a single data set.
		If ‘Yes’ is selected, a second GUI asks for the path to the parent directory in which the data directories are located  
 				 
