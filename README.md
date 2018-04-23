# m3u8

Downloads and merges chunks of an HLS video.
Downloading is done in parallel using Parallel::ForkManager perl module.
Concatenation is performed when each and every chunk is downloaded.

#### Input
Link to m3u8 file in form of a *double quoted command line argument*

#### Output
./m3u8tmp/tj.mp4

#### Usage
`perl m3u8chunks_download.pl "http://...m3u8" [outputpath/outputfilename.mp4]`

Order of arguments does not matter, but the m3u8 link must be an internet link.

#### Blocks of execution
1. Create *m3u8tmp* folder in the current directory

2. Download m3u8 manifest file and chunks in this temporary directory

    Display:

    `Parsing chunkfile... 157 chunks`

    `Started 103/157   Finished 84/157   Unsuccessful 0/157   Active 19`

3. Merge the chunks into *./m3u8tmp/tj.mp4*

    Display:

    `Download finished, merging... 157/157`

#### Requirements

* cygwin - This script was tested in cygwin. It is supposed to work in Linux as well.
* wget - used for downloading the manifest file and the chunks
* make - to install Parallel::ForkManager
* Parallel::ForkManager - to download the chunks in parallel. Command to install: `cpan Parallel::ForkManager` . You may need elevated rights in Linux.
