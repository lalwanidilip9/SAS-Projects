/*********************************************************************/
/*Program Name- HW11.sas*/
/* Date Created: October 25 2017 */
/* Author: Dilip Lalwani */
/* Purpose: SAS and working with datasets */
libname jobsdata "/folders/myfolders/jobsdata" access=readonly;
/*#2a Data set must contain only Sector, state, month and year variables*/
data work.monthly_jobs(keep=Sector state month year jobs);
set jobsdata.jobs2017;
/*#2b Rename sector name*/
if upcase(Sector)="PROFESSIONAL AND BUSINESS SERVICES" then
Sector="PROFESSIONAL/BUSINESS SERVICES";
/*#2c Change sector names to proper case*/
Sector=PROPCASE(Sector);
/*#2d Create month, year and jobs variables and perform observations check*/
length month $10;
if Aug__2016 ne . then do;
month="August";
year="2016";
jobs=Aug__2016;
output;
end;
if Sept__2016 ne . then do;
month="September";
year="2016";
jobs=Sept__2016;
output;
end;
if Oct__2016 ne . then do;
month="October";
year="2016";
jobs=Oct__2016;
output;
end;
if Nov__2016 ne . then do;
month="November";
year="2016";
jobs=Nov__2016;
output;
end;
if Dec__2016 ne . then do;
month="December";
year="2016";
jobs=Dec__2016;
output;
end;
if Jan__2017 ne . then do;
month="January";
year="2017";
jobs=Jan__2017;
output;
end;
if Feb__2017 ne . then do;
month="February";
year="2017";
jobs=Feb__2017;
output;
end;
if Mar__2017 ne . then do;
month="March";
year="2017";
jobs=Mar__2017;
output;
end;
if Apr__2017 ne . then do;
month="April";
year="2017";
jobs=Apr__2017;
output;
end;
if May_2017 ne . then do;
month="May";
year="2017";
jobs=May_2017;
output;
end;
if June_2017 ne . then do;
month="June";
year="2017";
jobs=June_2017;
output;
end;
if July_2017 ne . then do;
month="July";
year="2017";
jobs=July_2017;
output;
end;
if Aug__2017 ne . then do;
month="August";
year="2017";
jobs=Aug__2017;
output;
end;
run;
data large(keep=Sector state averagejobs)
medium(keep=Sector state averagejobs)
small(keep=Sector state averagejobs)
government(keep= state averagejobs marketsize)
goods(keep= Sector state averagejobs marketsize)
services(keep= Sector state averagejobs marketsize);
/*#3a Remove variables rep_date and ann_chng*/
set jobsdata.monthly_jobs1617(drop= rep_Date ann_chg);
/*#3b Compute average number of jobs on each observation*/
totaljobs=sum(of Aug__2016--Aug__2017);
averagejobs=totaljobs/13;
format averagejobs 10.1;
/*#3c Remove observations where value of Average Jobs is missing*/
if averagejobs eq . then delete;
/*#3d Create datasets based on average no of jobs*/
if averagejobs gt 900 then do;
marketsize="Large";
output large;
end;
else if averagejobs >= 100 and averagejobs <= 900 then do;
marketsize="Med.";
output medium;
end;
else do;
marketsize="Small";
output small;
end;
/*#3e Create remaining data sets based on Sector*/
select (upcase(Sector));
when("GOVERNMENT")
output government;
when("CONSTRUCTION","MANUFACTURING")
output goods;
when("FINANCIAL ACTIVITIES", "PROFESSIONAL AND BUSINESS SERVICES", "EDUCATION AND HEALTH
SERVICES", "LEISURE AND HOSPITALITY")
output services;
OTHERWISE
END;
run;
/*#4 Set PDF output*/
filename result "/folders/myfolders/HW11/dilip.k.lalwani_HW11_output.pdf";
ods pdf file=result bookmarkgen=yes bookmarklist=hide;
/*#5 Print first 50 and last 50 observations of the dataset from step 2*/
proc print data=monthly_jobs(firstobs=1 obs=50) noobs;
title "5.1-First 50 Observations from Monthly Jobs Data Set";
proc print data=monthly_jobs(firstobs=5385 obs=5435) noobs;
title "5.2-Last 50 Observations from Monthly Jobs Data Set";
proc print data=monthly_jobs(firstobs=2800 obs=2849) noobs;
title "5.3-Fifty Observations from Monthly Jobs Data Set Beginning with #2800";
/*#6 Print selected observations from each of temporary data sets created from monthly_jobs1617*/
proc print data=small(firstobs=1 obs=30) label;
LABEL
	averagejobs='Average Jobs';
title "6a-First 30 Observations of Small Markets";
proc print data=Medium(firstobs=1 obs=30) label;
LABEL 
	averagejobs='Average Jobs';
title "6b-First 30 Observations of Medium Markets";
proc print data=large(firstobs=1 obs=30) label;
LABEL 
	averagejobs='Average Jobs';
title "6c-Large Markets";
proc print data=goods(firstobs=75 obs=104) noobs label;
title "6d-Selected Observations from Goods sector";
LABEL 
averagejobs='Average Jobs'
marketsize='Market Size';
proc print data=services(firstobs=1 obs=30) label;
LABEL  
	averagejobs='Average Jobs' 
	marketsize='Market Size';
where marketsize="Small";
title "6e-Small Markets in the Services sector";
proc print data=government label;
LABEL  
	averagejobs='Average Jobs' 
	marketsize='Market Size';
title "6f-Government sector";
/*Print data sets in the WORK library*/
proc print data=SASHELP.VTABLE(keep=libname memname crdate nobs nvar) noobs label;
LABEL 
		libname='Library Name' 
		memname='Member Name'
		crdate='Date Created'
		nobs='Number of Physical Observations'
		nvar='Number of Variables';
		where upcase(libname)="WORK";
title "7-Data Sets in the WORK Library";

run;
ods pdf close;