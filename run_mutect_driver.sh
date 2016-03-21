#!/bin/bash

# driver script for 100 genome analysis
# have included as few command line options as possible
# vars for the individual script calls are hard coded below.
UPLOADRESULTS=0;

STARTDATE=`date`;
STARTTIME=`date +%s.%N`;			
#CURRENTTIME=`date +%s.%N`;
#ELAPSEDTIME=`echo "$CURRENT_TIME - $START_TIME" | bc -l`;


# Fix UUID problem that Shenglai spotted 3-17-16
# Fix time calculation problem (   calc=$(echo "$String2 + $String8"|bc)   )
# have it dl ref data automatically 3-17-16

# vars for ARK_download.gamma.py
URLPATTERN1='https://griffin';  # -p
URLPATTERN2='https://s3';       # -p
PARCELIP='172.16.128.7';        # -rp

# vars for run_mutect_docker_indexing.sh
INDEXYAMLPATH="/home/ubuntu/git/mutect2-pon-cwl/tools/cramtools.cwl.yaml"; # -y

# vars for run_mutect_docker_calling.sh
CALLINGYAML="/home/ubuntu/git/mutect2-pon-cwl/workflows/mutect2-pon-workflow.cwl.yaml" # -y
SNPPATH="/mnt/mutect_ref_files/dbsnp_144.grch38.vcf"                       # -s
FAIPATH="/mnt/mutect_ref_files/Homo_sapiens_assembly38.fa.fai"             # -i
DICTPATH="/mnt/mutect_ref_files/Homo_sapiens_assembly38.dict"              # -k
COSMICPATH="/mnt/mutect_ref_files/CosmicCombined.srt.vcf";                 # -x
BLOCKSIZE="50000000";                                                      # -b # Shenglai (3-15-16) # Play with smaller block sizes to see if you can change the speed
THREADCOUNT=`grep -c "processor" /proc/cpuinfo`;                           # -t

# vars for upload
UPLOADBUCKET="1000_genome_exome";


# vars used by more than one script
FASTAPATH="/mnt/mutect_ref_files/Homo_sapiens_assembly38.fa";  # -f
UUID="uuid";                                                # -u

# Parse input options
while getopts ":l:czh" opt; do
    case $opt in
	l)
	    echo "-l was triggered, Parameter: $OPTARG" >&2
	    LIST=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
	
	c)
	    echo "-c was triggered, Parameter: $OPTARG" >&2
	    CLEAN=1;
	    ;;
	z)
	    echo "-z was triggered, Parameter: $OPTARG" >&2
	    DEBUG=1;
	    ;;
	h)
	    echo ""
	    echo "DESCRIPTION: run_mutect_driver.sh";
	    echo "Takes a list of ARK IDs for CRAM files and uses the following scripts to process them:";
	    echo "     ARK_download.gamma.py         :: to download the *.cram";
	    echo "     run_mutect_docker_indexing.sh :: to index the *.cram";
	    echo "     run_mutect_docker_indexing.sh :: variant calling";
	    echo "Arguments for each of these steps are hard coded in this script";
	    echo ""
	    echo "USAGE";
	    echo "     run_mutect_driver.sh -l <filename> [other options]";
	    echo "";
	    echo "EXAMPLE:";
	    echo "Perform analysis that deletes intermediate files:";
	    echo "     run_mutect_driver.sh -l some_list.txt -c";
	    echo ""
	    echo "Kevin P. Keegan, 2016";
	    echo ""
	    exit 1;
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
    esac
done

# Make sure the list file exists
if [ ! -e $LIST ]; then
    echo "List $LIST not supplied or does not exist - this is required"
    exit 1
fi

### Make sure that the reference data exists -- if not, download it automatically
#if [ ! -e $LIST ]

# Start the log and stats files
LOG=$LIST".run_mutect_driver.log.txt";
echo $LIST".run_mutect_driver.log.txt" > $LOG
echo $STARTDATE >> $LOG
STATS=$LIST".run_mutect_driver.stats.txt";
echo $LIST".run_mutect_driver.stats.txt" > $STATS
echo -e "ark\tsample\ts3_w_parcel.dl_time\ts3_w_parcel.md5\ts3_wo_parcel.dl_time\ts3_wo_parcel.md5\tgrif_w_parcel.dl_time\tgrif_w_parcel.md5\tgrif_wo_parcel.dl_time\tgrif_wo_parcel.md5\tindexing.run_time\tcalling.run_time" >> $STATS

# Download the ref data if it is not already there
# no logging or error checking
dl_ref_data.sh

# start parcel (tcp2udt)

#test=`ps | grep parcel`
#if [[ -z "$test" ]]; then echo "works"; fi


for i in `cat $LIST`; do

    #############################################################################################################
    ### Perform download -- from Grif and Amazon S3, both with and without parcel (leave off amazon until Monday)
    #############################################################################################################
    
    # From Amazon with parcel
    # echo "#################################" >> $LOG"
    # echo "DOWNLOAD from Amazon WITH parcel:" >> $LOG"
    # S3_W_PARCELDLSTARTTIME=`date +%s.%N`;
    # CMD="ARK_download.gamma.py -a $i -p $URLPATTERN2 -up -rp $PARCELIP -d -b";
    # echo $CMD >> $LOG;
    # eval $CMD &>>$LOG;
    # CMD_STATUS=$?;
    # echo -e "Command status: \t"$CMD_STATUS >> $LOG;
    # S3_W_PARCELDLENDTIME=`date +%s.%N`;
    # S3_W_ELAPSEDTIME=`echo "$S3_W_PARCELDLENDTIME - $S3_W_PARCELDLSTARTTIME" | bc -l`;
    # echo -e "Command runtime: \t"$S3_WO_ELAPSEDTIME >> $LOG;
    # URL=`curl $i | python -mjson.tool | grep -e $URLPATTERN2` # get raw URL -- will be quoted and possibly followed by comma
    # URL=`echo $URL | sed -e 's/,$//'` # remove trailing comma
    # URL=`echo $URL | sed -e 's/^"//'  -e 's/"$//'` # remove quotes
    # FILE=`basename $URL`;
    # S3_W_MD5=`md5sum $FILE | cut -d " " -f1`;
    # echo -e "md5: \t"$S3_W_MD5 >> $LOG;
    # if [ ! -e $FILE ]; then
    # 	MESSAGE="$FILE does not exist/ does not need to be deleted";
    #   echo $MESSAGE
    #   echo $MESSAGE >> $LOG;
    # else
    # 	rm $FILE;
    #   echo $MESSAGE >> $LOG;
    # fi
    # echo "#################################" >> $LOG"

    # From Amazon without parcel
    # echo "#################################" >> $LOG"
    # echo "DOWNLOAD from Amazon withOUT parcel:" >> $LOG"
    # S3_WO_PARCEL_DL_STARTTIME=`date +%s.%N`;
    # CMD="ARK_download.gamma.py -a $i -p $URLPATTERN2 -d -b";
    # echo $CMD >> $LOG;
    # eval $CMD &>>$LOG;
    # CMD_STATUS=$?;
    # echo -e "Command status: \t"$CMD_STATUS >> $LOG;
    # S3_WO_PARCEL_DL_ENDTIME=`date +%s.%N`;
    # S3_WO_ELAPSEDTIME=`echo "$S3_WO_PARCEL_DL_ENDTIME - $S3_WO_PARCEL_DL_STARTTIME" | bc -l`;
    # echo -e "Command runtime: \t"$S3_WO_ELAPSEDTIME >> $LOG;
    # URL=`curl $i | python -mjson.tool | grep -e $URLPATTERN2` # get raw URL -- will be quoted and possibly followed by comma
    # URL=`echo $URL | sed -e 's/,$//'` # remove trailing comma
    # URL=`echo $URL | sed -e 's/^"//'  -e 's/"$//'` # remove quotes
    # FILE=`basename $URL`;
    # S3_WO_MD5=`md5sum $FILE | cut -d " " -f1`;
    # echo -e "md5: \t"$S3_WO_MD5 >> $LOG;
    # if [ ! -e $FILE ]; then
    # 	MESSAGE="$FILE does not exist/ does not need to be deleted";
    #   echo $MESSAGE
    #   echo $MESSAGE >> $LOG;
    # else
    # 	rm $FILE;
    #   echo $MESSAGE >> $LOG;
    # fi
    # echo "#################################" >> $LOG"
    
    # From Grif with parcel
    echo "#################################" >> $LOG
    echo "DOWNLOAD from Griffin WITH parcel:" >> $LOG
    GRIF_W_PARCELDL_START_TIME=`date +%s.%N`;
    CMD="ARK_download.gamma.py -a $i -p $URLPATTERN1 -up -rp $PARCELIP -d -b";
    echo $CMD >> $LOG;
    eval $CMD &>>$LOG;
    CMD_STATUS=$?;
    echo -e "Command status: \t"$CMD_STATUS >> $LOG;
    GRIF_W_PARCELDL_ENDTIME=`date +%s.%N`;
    GRIF_W_ELAPSED_TIME=`echo "$GRIF_W_PARCELDL_ENDTIME - $GRIF_W_PARCELDL_START_TIME" | bc -l`;
    echo -e "Command runtime: \t"$GRIF_W_ELAPSEDTIME >> $LOG;
    URL=`curl $i | python -mjson.tool | grep -e $URLPATTERN1` # get raw URL -- will be quoted and possibly followed by comma
    URL=`echo $URL | sed -e 's/,$//'` # remove trailing comma
    URL=`echo $URL | sed -e 's/^"//'  -e 's/"$//'` # remove quotes
    FILE=`basename $URL`;
    GRIF_W_MD5=`md5sum $FILE | cut -d " " -f1`;
    echo -e "md5: \t"$GRIF_W_MD5 >> $LOG;
    if [ ! -e $FILE ]; then
	MESSAGE="$FILE does not exist/ does not need to be deleted";
	echo $MESSAGE
	echo $MESSAGE >> $LOG;
    else
	rm $FILE;
	echo $MESSAGE >> $LOG;
    fi
    echo "#################################" >> $LOG"
    
    # From Grif without parcel
    echo "#################################" >> $LOG
    echo "DOWNLOAD from Griffin withOUT parcel:" >> $LOG
    GRIF_WO_PARCEL_DL_START_TIME=`date +%s.%N`;
    CMD="ARK_download.gamma.py -a $i -p $URLPATTERN1 -d";
    echo $CMD >> $LOG;
    eval $CMD &>>$LOG;
    CMD_STATUS=$?;
    echo -e "Command status: \t"$CMD_STATUS >> $LOG;
    GRIF_WO_PARCEL_DL_ENDTIME=`date +%s.%N`;
    GRIF_WO_ELAPSEDTIME=`echo "$GRIF_WO_PARCEL_DL_ENDTIME - $GRIF_WO_PARCEL_DL_START_TIME" | bc -l`;
    echo -e "Command runtime: \t"$GRIF_WO_ELAPSEDTIME >> $LOG;
    URL=`curl $i | python -mjson.tool | grep -e $URLPATTERN1` # get raw URL -- will be quoted and possibly followed by comma
    URL=`echo $URL | sed -e 's/,$//'` # remove trailing comma
    URL=`echo $URL | sed -e 's/^"//'  -e 's/"$//'` # remove quotes
    FILE=`basename $URL`;
    GRIF_WO_MD5=`md5sum $FILE | cut -d " " -f1`;
    echo -e "md5: \t"$GRIF_WO_MD5 >> $LOG;
    if [ ! -e $FILE ]; then
    	MESSAGE="$FILE does not exist; script can't use a file that doesn't exist";
    	echo $MESSAGE;
    	echo $MESSAGE >> $LOG;
    	exit 1;
    else
    	MESSAGE="$FILE exists, will now start processing";
    	echo $MESSAGE;
    	echo $MESSAGE >> $LOG;
    fi
    echo "#################################" >> $LOG

    
    #############################################################################################################
    
    
    #############################################################################################################
    ### PERFORM MUTECT CALCULATIONS  -- ONLY IF OUTPUT VCF IS NOT ALREADY PRESENT
    #############################################################################################################
    #extension="${FILE##*.}"
    filename="${FILE%.*}"
    VCFOUT=$filename"_pon.srt.vcf";
    
    if [ ! -e $VCFOUT ]; then

	MESSAGE="$VCFOUT does not exist, will now start indexing";
    	echo $MESSAGE;
    	echo $MESSAGE >> $LOG;
	
        #############################################################################################################
        ### MuTect step 1, Indexing
        #############################################################################################################
	
        #run_mutect_docker_indexing.sh -y \"/home/kevin/git/mutect2-pon-cwl/tools/cramtools.cwl.yaml\" -c \"/home/kevin/HG00115.alt_bwamem_GRCh38DH.20150826.GBR.exome.cram\" -f \"/home/kevin/mutect_ref_files/Homo_sapiens_assembly38.fa\" -u \"uuid\" -d
	MUTECT1_STARTTIME=`date +%s.%N`;
	CMD="run_mutect_docker_indexing.sh -y $INDEXYAMLPATH -c $FILE -f $FASTAPATH -u $UUID";
	echo $CMD >> $LOG;
	eval $CMD &>>$LOG;
	CMD_STATUS=$?;
	echo -e "Command status: \t"$CMD_STATUS >> $LOG;
	MUTECT1_ENDTIME=`date +%s.%N`;
	MUTECT1_ELAPSEDTIME=`echo "$MUTECT1_ENDTIME - $MUTECT1_STARTTIME" | bc -l`
	echo -e "Command runtime: \t"$MUTECT1_ELAPSEDTIME >> $LOG;
	
	#############################################################################################################
	
	#############################################################################################################
	### MuTect step 2, Calling
	#############################################################################################################
	# run_mutect_docker_calling.sh -y \"/home/kevin/git/mutect2-pon-cwl/workflows/mutect2-pon-workflow.cwl.yaml\" -c \"/home/kevin/HG00115.alt_bwamem_GRCh38DH.20150826.GBR.exome.cram\" -s \"/home/kevin/mutect_ref_files/dbsnp_144.grch38.vcf\" -f \"/home/kevin/mutect_ref_files/Homo_sapiens_assembly38.fa\" -i \"reference_fasta_fai /home/kevin/mutect_ref_files/Homo_sapiens_assembly38.fa.fai\" -k \"/home/kevin/mutect_ref_files/Homo_sapiens_assembly38.dict\" -x \"/home/kevin/mutect_ref_files/CosmicCombined.srt.vcf\" -b \"50000000\" -t \"8\" -u \"uuid\" -d"
	MUTECT2_STARTTIME=`date +%s.%N`;
	CMD="run_mutect_docker_calling.sh -y $CALLINGYAML -c $FILE -s $SNPPATH -f $FASTAPATH -i $FAIPATH -k $DICTPATH -x $COSMICPATH -b $BLOCKSIZE -t $THREADCOUNT";
	echo $CMD >> $LOG;
	eval $CMD &>>$LOG;
	CMD_STATUS=$?;
	echo -e "Command status: \t"$CMD_STATUS >> $LOG;
	MUTECT2_ENDTIME=`date +%s.%N`;
	MUTECT2_ELAPSEDTIME=`echo "$MUTECT2_ENDTIME - $MUTECT2_STARTTIME" | bc -l`
	echo -e "Command runtime: \t"$MUTECT2_ELAPSEDTIME >> $LOG;
	#############################################################################################################

	#############################################################################################################
	### Upload Results (if option is selected)
	#############################################################################################################
	if [ $UPLOADRESULTS -eq 1 ]; then
	    
	    MESSAGE="Uploading results ( "$VCFOUT" ) to location specified in ~/.s3.upload.cfg";
	    echo $MESSAGE;
	    echo $MESSAGE >> $LOG;
	    CMD="s3cmd -c ~/.upload.cfg put $VCFOUT s3://$UPLOADBUCKET"
	    echo $CMD >> $LOG;
	    eval $CMD &>>$LOG;
	    CMD_STATUS=$?;
	    echo -e "Command status: \t"$CMD_STATUS >> $LOG;

	    ########################################
	    # INCLUDE DELETION OF LOCAL RESULTS HERE
	    ########################################
	    
	    # Put file into bucket
            # s3cmd put FILE [FILE...] s3://BUCKET[/PREFIX]

	    # Conditional transfer — only files that don’t exist at the destination in the same version are transferred
	    # by the s3cmd sync command. By default a md5 checksum and file size is compared.

	    # Synchronize a directory tree to S3 (checks files freshness using size and 
	    # md5 checksum, unless overridden by options, see below)
            # s3cmd sync LOCAL_DIR s3://BUCKET[/PREFIX] or s3://BUCKET[/PREFIX] LOCAL_DIR
	fi
	#############################################################################################################
	### Cleanup
	#############################################################################################################
	if [ ! -e $FILE ]; then
	    MESSAGE="$FILE does not exist; script should have failed before this";
	    echo $MESSAGE;
	    exit 1;
	else
	    MESSAGE="Done processing $FILE, will now delete it and any *.bai files";
	    echo $MESSAGE;
	    echo $MESSAGE >> $LOG;
	    sudo rm $FILE
	    sudo rm *.bai;
	fi
	#############################################################################################################
	
	#############################################################################################################
	### Write nice formatted results to the stats file
	#############################################################################################################
	# echo -e "ark\tsample\ts3_w_parcel.dl_time\ts3_w_parcel.md5\ts3_wo_parcel.dl_time\ts3_wo_parcel.md5\tgrif_w_parcel.dl_time\tgrif_w_parcel.md5\tgrif_wo_parcel.dl_time\tgrif_wo_parcel.md5\tindexing.run_time\tcalling.run_time\n" >> $STATS
	echo -e "$i\t$FILE\t$S3_W_ELAPSEDTIME\t$S3_W_MD5\t$S3_WO_ELAPSEDTIME\t$S3_WO_MD5\t$GRIF_W_PARCELDLENDTIME\t$GRIF_W_MD5\t$GRIF_WO_PARCEL_DL_ENDTIME\t$GRIF_WO_MD5\t$MUTECT1_ELAPSEDTIME\t$MUTECT2_ELAPSEDTIME" >> $STATS;
    else
	MESSAGE="$VCFOUT already exists, will skip indexing and calling";
    	echo $MESSAGE;
    	echo $MESSAGE >> $LOG;
	echo -e "$i\t$FILE\t$S3_W_ELAPSEDTIME\t$S3_W_MD5\t$S3_WO_ELAPSEDTIME\t$S3_WO_MD5\t$GRIF_W_PARCELDLENDTIME\t$GRIF_W_MD5\t$GRIF_WO_PARCEL_DL_ENDTIME\t$GRIF_WO_MD5\t$MESSAGE" >> $STATS;
	if [ ! -e $FILE ]; then
	    MESSAGE="$FILE does not exist; script should have failed before this";
	    echo $MESSAGE;
	    exit 1;
	else
	    MESSAGE="Done processing $FILE, will now delete it and any *.bai files";
	    echo $MESSAGE;
	    echo $MESSAGE >> $LOG;
	    sudo rm $FILE
	    sudo rm *.bai;
	fi
    fi
    
done;
