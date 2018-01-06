/***********************************************************************************/
/* Program Name: HW10.sas */
/* Date Created: October 18 2017 */
/* Author: Dilip Lalwani */
/* Purpose: SAS and working with datasets */

/*#2 Create two libname statements*/

libname jobsdata '/folders/myfolders/jobsdata/' access=readonly;
libname hw10 '/folders/myfolders/HW10/';

/*#3 Specify a fileref for PDF output*/

filename hw10pdf '/folders/myfolders/HW10/hw10.pdf';

/*#4 Create a new data set using jobs2017 dataset*/

data hw10.newjobs2017;
	set jobsdata.jobs2017;
	/* a. Remove observations that have a missing State value */
	where State is not missing;
	
	/* b. Supply labels for all of the month variables so the full month name and the year will be displayed like “August 2016”. */
label Aug__2016='August 2016'
Sept__2016='September 2016'
Oct__2016='October 2016'
Nov__2016='November 2016'
Dec__2016='December 2016'
Jan__2017='January 2017'
Feb__2017='February 2017'
Mar__2017='March 2017'
Apr__2017='April 2017'
May_2017='May 2017'
June_2017='June 2017'
July_2017='July 2017'
Aug__2017='August 2017';

	/* c. Create a new variable labeled Report Date 	*/

	reportdate =	'12OCT2017'd;
	FORMAT reportdate MMDDYY10.;
		LABEL reportdate = 'Report Date';
	
	/* d. Create a variable labeled Annual Change */
	annualchange = (Aug__2017-Aug__2016)/Aug__2016;
	FORMAT annualchange percent8.1;
		LABEL annualchange = 'Annual Change';
	
run;

/*#5 Create temporary dataset from enhanced dataset having an annual change of 5 percent or more positive or negative*/

data work.BIGCHANGE;
set hw10.newjobs2017;
where annualchange ne . and ((annualchange*100 ge 5) or (annualchange*100 le -5));
keep reportdate annualchange State Sector Aug__2016 Aug__2017;
run;

/*#6 Create temporary dataset for the number of jobs logic*/

data work.NEWJUMPS;
set hw10.newjobs2017;
where Aug__2017 ge July_2017+1 and July_2017 ne .;
keep Sector State Jan__2017 Feb__2017 Mar__2017 Apr__2017 May_2017 June_2017
July_2017 Aug__2017;
run;

/*#7 Create temporary dataset of service industries*/

data work.SERVICES;
set hw10.newjobs2017;
where annualchange ne . and Sector like '%SERVICES%';
keep State Aug__2016 Aug__2017 annualchange Sector reportdate;
format Aug__2016 Aug__2017 COMMA5.0;
run;

/*#8 Create temporary dataset of Southern States*/
data work.SOUTHERN;
set hw10.newjobs2017;
where ( (State in ('Texas', 'Oklahoma', 'Arkansas', 'Louisiana', 'Mississippi', 'Kentucky',
'Alabama', 'Florida', 'Georgia', 'South Carolina', 'North Carolina', 'Virginia'))or (State like
'District of Columbia%') or (State like 'Tennessee%') ) and Sector not contains 'GOVERNMENT';
keep Sector State annualchange Jan__2017 Feb__2017 Mar__2017 Apr__2017 May_2017 June_2017
July_2017 Aug__2017;
run;

/*#9 Open a PDF destination using the fileref above*/

ods pdf file=hw10pdf bookmarkgen=no;

/*#10 Print descriptor of cleaned up jobs dataset*/
proc contents data=hw10.newjobs2017;
title '#10. Descriptor Portion of Cleaned Jobs DataSet';
run;

/*#11 Print a listing of all temporary data sets excludes the details*/
proc contents data=work._all_ nods;
title '#11. List of Temporary Data Sets';
run;

/*#12 Print data portion of temporary dataset work.BIGCHANGE*/
proc print data=work.BIGCHANGE label noobs;
title '#12 Records with over 5% Annual Change';
var /*report_date*/ annualchange State Sector Aug__2017 Aug__2016;
run;

/*#13 Print data portion of temporary dataset work.NEWJUMPS*/
proc print data=work.NEWJUMPS label noobs;
title '#13 Records with Recently Monthly Increase';
var Sector State Jan__2017 Feb__2017 Mar__2017 Apr__2017 May_2017 June_2017 July_2017
Aug__2017;
run;

/*#13 Print data portion of temporary dataset work.SERVICES*/
proc print data=work.SERVICES label;
title '#13 Services';
var State Aug__2016 Aug__2017 annualchange Sector reportdate;
run;

/*#13 Print data portion of temporary dataset work.SOUTHERN*/
proc print data=work.SOUTHERN label noobs;
title '#13 SOUTHERN States';
var Sector State Jan__2017 Feb__2017 Mar__2017 Apr__2017 May_2017 June_2017 July_2017 Aug__2017 annualchange;
run;

ods pdf close;