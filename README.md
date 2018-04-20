# m3u8

Downloads and concatenates chunks of an HLS video.
Downloading is done in parallel using Parallel::ForkManager perl module.
Concatenation is performed when each and every chunk is downloaded.

#### Input
Link to m3u8 file in form of a *double quoted command line argument*

#### Output
./m3u8tmp/tj.mp4

#### Usage
`perl m3u8chunks_download.pl "http://...m3u8"`

#### Blocks of execution
1. Create *m3u8tmp* folder in the current directory

2. Downloads m3u8 manifest file and chunks in this temporary directory

    Display:

    `Parsing chunkfile... 157 chunks`

    `Started 103/157   Finished 84/157   Unsuccessful 0/157   Active 19`

3. Concatenates the chunks into *./m3u8tmp/tj.mp4*

    Display:

    `Download finished, concatenating... 157/157`
