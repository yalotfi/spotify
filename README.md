# spotify
Organizing 900K Spotify streams.  Unfortunately, the data's spreadsheet was saved as a PDF document... So parsing and cleaning it was the bulk of the challenge.

## Clean Spotify
The basic idea is to deconstruct the PDF and reassemble it into a nicely formatted dataframe.  Basically, I do this through one large loop which goes through each page of the PDF document.  Each page needs its own loop to run through the rows.  The result is a look at one band's (no idea who they are!) streaming log, provising an analyst with compensation and origin country information.  Not much to get out of the data set other than figuring how much this particular band made.  This was really an exercise in cleaning and structuring an unconventional data type.

## Purpose
While these guys clearly used like Excel or Google Sheets, they saved it into a PDF.  Nonetheless, it is cool to test R's ability in "reading" atypical data types.  While everyone talks about the exponential growth of data production (volume), people tend to overlook the variety aspect.  I don't intend to create vizualizations considering the data itself is pretty straightforward.  This little expedition, however, underscores the idea that the majority of a data scientist's time is comprised of cleaning and organizing his or her data.  The subsequent analysis is relatively intuitive.

What would be really cool is if a bunch of artists on Spotify or Apple Music releases their compensation information.  With a diverse sample of data points, and probably stretching the munging techniques in this project, one could reverse engineer how music streaming platforms compensate artists.
