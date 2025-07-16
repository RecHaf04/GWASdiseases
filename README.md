Hi wassup its Rec, here with bad instructions :)

In order to add new datasets/build an app to fulfil the same process, you will need to do several things 
firstly, convert your file from the .tsv into an .sqlite file with all of them (currently we have one in the /RechumaHafter folder with 65 datasets thats around 185 gb.) 
This will take several hours likely. in fact, half of the steps take several hours each!

Once you have those files all arranged nicely in one sqlite database, source all of the files in the data_prep_scripts. 
This will make pngs for Manhattan Plots and QQplots, make summary .rds files for summary data, and make .rds files seperated by dataset and chromosome to allow for chunked crossDB search 
rerun the prep_API script, deploy API, put API link in app.R file and deploy app.R

Yay. call me if you have issues.
