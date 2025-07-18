Hi wassup its Rec, here with bad instructions :)

In order to add new datasets/build an app to fulfil the same process, you will need to do several things 
**** Use the create_gwas_data_v2.sqlite code to combine all of the new datasets into 1 sqlite file
This will take several hours likely. in fact, half of the steps take several hours each!

Once you have those files all arranged nicely in one sqlite database:
***Source render_all_plots
***Source prepare_summary_data
***Source prepare_cross_pheno_data
***Add names of new datasets into app.R
Deploy API (backend_api folder with plumber.R and folders full of .rds files)
Deploy App (shiny_frontend folder with app.R and folder full of .png files


Yay. call me if you have issues.
