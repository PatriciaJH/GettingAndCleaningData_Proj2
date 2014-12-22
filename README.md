GettingAndCleaningData_Proj2
============================

Project 2 for the John Hopkins Coursera course Getting And Cleaning Data (Dec 2014)

The code for this project consists of two files: run_analysis.R and
feature_names.R

The assignment asked us to write code that takes the UCI HAR dataset,
and does the following: 

1)  Merges the training and the test sets to create one data set.
2)  Extracts only the measurements on the mean and standard deviation
    for each measurement.   
3)  Uses descriptive activity names to name the activities in the data set
4)  Appropriately labels the data set with descriptive variable names. 
5)  From the data set in step 4, creates a second, independent tidy
    data set with the average of each variable for each activity and each
    subject. 

I chose to take these steps slightly out of order, because one of the
challenges of this project is assigning good variable names to a large number
of poorly described numbers from several files.  (I wound up deducing
which file was what based on part on table dimensions.)

As the R data.table function lets column (and row) names to be
assigned from a vector, I thought naming the variables immediately on
read was a good idea.  

File feature_names.R

The file feature_names.R  creates a character vector called
"feature_names".   I created it by taking the variable names listed in
the UCI features.txt, and running emacs editor macros, plus a little
hand tweaking, to systematically map the R-variable-illegal characters
in features.txt to R-legal characters, resulting in a vector of
R-legal variable names. 

Next to the column of R-legal names, I give the original features.txt
names.  This provides documentation of the relationship between the
two, allows any later coder to easily understand and reproduce what I
did, and avoids the need to rename arbitrarily named variables on the
fly using regexps in code -- and all the potential debugging of that.

File run_analysis.R

After the loading necessary libraries, run_analysis.R defines the
function read_data_tables.  This function reads the data set and
creates the R data tables, naming all appropriate variables as they're
read.

Because data for  the "test" and train" phases of the experiment is
identical in structure but stored in different trees, I set function
up to take a "test_or_train" variable; I then call the function once
test, once for train, and combine the output files (step 1 in the
rubric.) 

The single-columned Subject and Activity files are read into
single-columned tables with the column names "Subject" and "Activity";
the Activity column is converted into a factor with the labels
"WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING",
"STANDING", "LAYING" -- chosen to match the dataset's own labels for
clarity. (Step 3. in the rubric: "3) Use descriptive activity names to
name the activities in the data set") 

The file feature_names.R is then sourced, creating the feature_names
vector, which is now used in table.read to assign good variable names to the
"features" measurement variables from the file X_test.txt (or
X_train.txt), creating the LARGE table X_features.table .  (Step 4 in
the rubric: "Appropriately labels the data set with descriptive
variable names.") 

I also created a single-column-table, with its factor-variable column
named phase, with levels "test" and "train".  We weren't asked to do
this, but this preserves and documents  the distinction between the
"test" and "train" phases of the experiment. 

The function cbind then binds the subject.table, phase,
activity.table, and X_features.table together into out.table, the
output.

That's the whole of the read_data_tables function.

The main script of the code now calls read_data_tables twice, creating
test.table and train.table for the test and train datasets; these are
now bound together with rbind (rubric step 1: "1) Merge training and
test sets to create one data set") resulting in all.table

Next comes rubric step 2: "# 2) Extracts only the measurements on the
mean and standard deviation for each measurement."  I do this by
comparing the column names of all.table using the regexp:

%like% "[Mm]ean|std"

and used the resulting truth-vector, tweaked to preserve the first
three id columns, to index all.table.

Although this is now a tidy dataset, with all the id variables
(subject, activity, phase) in named columns, and with all the
"feature" measurement variables also in descriptively named columns,
"long" tidy datasets are considered more flexible.  So I made a vector
of measure variable names, and used that to melt the table into a long
four-column dataset with id variables         
Subject   Phase Activity Feature

and measure variable Value.

I then did the fifth rubric step: "5) From the data set in step 4, creates a
second, independent tidy data set with the average of each (feature)
variable for each activity and each subject" by using a handy-dandy
data.table aggregation feature to apply the function mean across
Subject, Activity, and Feature.

I notice I forgot to rename the output column in the ultimate tidy
table; it's V1.  Drat.  And if I had a little more time, this would be
much shorter and clearer.

Hope your own project went well; 

Regard, Patricia J. Hawkins














