# m3u8

Downloads and concatenates chunks of an HLS video.
Downloading is done in parallel using Parallel::ForkManager perl module.
Concatenation is performed when each and every chunk is downloaded.

Input: Link to m3u8 file in form of a **double quoted command line argument**

Output: ./m3u8tmp/tj.mp4

Usage:

perl m3u8chunks_download.pl "http://...m3u8"

1. Creates m3u8tmp folder in the current directory
2. Downloads m3u8 manifest file and chunks in the temporary directory
3. Concatenates the chunks
