1.
Download the IMDb Files
The files are here:
https://datasets.imdbws.com/

Place the files into the "imdb_test_data" directory (as shown in Files In Folder.png)

2.
Open a command prompt, navigate to the imdb_test_data directory and run the following command:


python 01_process_imdb_files.py  



This is a one-time process.  It can take a while to run (approx. 60 minutes on my modest PC). I did nothing to optimize/parallelize how the job runs.

Running this script does the following:

    Unzips the IMDb source files.
    Processes each unzipped file in turn.
    Generates a new set of CSV files, containing re-arranged and normalize data.
    Places these new CSV files in the “csv” directory.
