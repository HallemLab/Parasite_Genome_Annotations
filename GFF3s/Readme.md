## Are the files in this folder current, or have they been integrated into WormBase and/or WormBase ParaSite?

### *S. stercoralis*

Updated annotations in the *S. stercoralis* GFF3 file were integrated as part of WormBase ParaSite release 17. Community annotation file is a copy of WBSP17 as of Feb 15, 2023.   

### *S. ratti*

Updated annotations in the *S. ratti* GFF3 file have **NOT** been integrated as of WormBase version WS286 and WormBase ParaSite release 17.  
Updates from Bryant *et al* 2022 have been added over the WBSP17 annotation file.  

#### Trimming WormBase *S. ratti* annotation file using UNIX

As of approximately WS286/WBPS17, the size of the *S. ratti* GFF3 file is large (>2.6 GB). In contrast, the WS283/WBPS16 *S. ratti* GFF3 file was 32.1 MB. The increase volume appears to be due to the addition of more JBrowse data tracks, including: BLAT and BLASTX hits, as well as translated feature information and RNASeq data. GitHub is not able to index large file sizes. In order to trim *S. ratti* GFF3 files downloaded from WormBase or WormBase ParaSite down to a size that can be managed by GitHub, we designed the following UNIX pipeline:  

1. Download compressed GFF3 annotation file from WormBase or WormBase ParaSite.  
2. Uncompress the GFF3.gz file  
3. Open Terminal (Mac) or Command Prompt/Windows Terminal (PC). Use the "cd" change direction command to navigate to the folder containing the gff3 file.   
4. Type the following into the command line, altering the gff3 file name as appropriate:  
`grep -vE "BLAT|BLASTX|translated_feature|RNASeq|SL1_acceptor"  s_ratti.PRJEB125.WS287.annotations.gff3 > strongyloides_ratti.PRJEB125.WS287.community.annotations.gff3`  

Once you have generated a trimmed GFF3 annotation file, edit and upload to the repo following directions in Bryant, Akimori, and Hallem (2023).   
Note that labs should make sure to utilize branch merging, and alter line "source" data (GFF3 column 2) to identify which annotation lines have been manually altered.  The format for the altered source data should be: CCA\_\<WormBase Laboratory Identifier\>\_year+month+day (e.g., CCA_EAH_230103).  