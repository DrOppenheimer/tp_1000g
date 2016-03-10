#!/bin/bash

# Set defaults
YAMLPATH="~/mutect2-pon-cwl/workflows/mutect2-pon-workflow.cwl.yaml";
CRAMPATH="~/NA19771.alt_bwamem_GRCh38DH.20150826.MXL.exome.cram";
SNPPATH="~/mutect_ref_files/dbsnp_144.grch38.vcf";
FASTAPATH="~/mutect_ref_files/Homo_sapiens_assembly38.fa";
FAIPATH="~/mutect_ref_files/Homo_sapiens_assembly38.fa.fai";
DICTPATH="~/mutect_ref_files/Homo_sapiens_assembly38.dict";
COSMICPATH="~/mutect_ref_files/CosmicCombined.srt.vcf";
BLOCKSIZE="50000000"; # should this be defined by resources on the machine instead of arbitrary?
THREADCOUNT==`grep -c "processor" /proc/cpuinfo`;
UUID="uuid";

# Parse input options
while getopts ":y:c:s:f:i:k:x:b:t:u:dh" opt; do
    case $opt in
	y)
	    echo "-y was triggered, Parameter: $OPTARG" >&2
	    YAMLPATH=$OPTARG
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
	    CRAMPATH=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
	s)
	    echo "-s was triggered, Parameter: $OPTARG" >&2
	    SNPPATH=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;	
	f)
	    echo "-f was triggered, Parameter: $OPTARG" >&2
	    FASTAPATH=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;

	i)
	    echo "-i was triggered, Parameter: $OPTARG" >&2
	    FAIPATH=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
	k)
	    echo "-d was triggered, Parameter: $OPTARG" >&2
	    DICTPATH=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
	x)
	    echo "-x was triggered, Parameter: $OPTARG" >&2
	    COSMICPATH=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
	b)
	    echo "-b was triggered, Parameter: $OPTARG" >&2
	    BLOCKSIZE=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	t)
	    echo "-t was triggered, Parameter: $OPTARG" >&2
	    THREADCOUNT=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	u)
	    echo "-u was triggered, Parameter: $OPTARG" >&2
	    UUID=$OPTARG
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	d)
	    echo "-z was triggered, Parameter: $OPTARG" >&2
	    DEBUG=1;
	    ;;
	h)
	    # Show the help 
	    echo "DESCRIPTION: run_mutect_docker_indexing.sh";
	    echo "Script to run Shenglai's docker for variant calling of *.cram with *.cram.bai index";
	    echo "This is 2/2 scripts for the 1000 genome normal panel varient calling";
	    echo "(Also see run_mutect_indexing.sh)";
	    echo "The script generates an indexed cram (*.cram.bai) from a cram (*.cram)";
	    echo "It requires a reference fasta file.";
	    echo ""
	    echo "OPTIONS:";
	    echo "     -y|--yamlpath          (string) Required - PATH/FILE for the *.yaml (cwl workflow)";
	    echo "                                 Default = \"$YAMLPATH\"";
	    echo "     -c|--crampath          (string) Required - PATH/FILE for the *.cram (input cram)";
	    echo "                                 Default = \"$CRAMPATH\"";
	    echo "     -s|--snppath           (string) Required - PATH/FILE for the *.vcf (genome reference variants)";
	    echo "                                 Default = \"$SNPPATH\"";
	    echo "     -f|--fastapath         (string) Required - PATH/FILE for the *.fa (reference fasta)";
	    echo "                                 Default = \"$FASTAPATH\"";
	    echo "     -i|--faipath           (string) Required - PATH/FILE for the *.fai (reference fasta index)";
	    echo "                                 Default = \"$FAIAPATH\"";
	    echo "     -k|--dictpath          (string) Required - PATH/FILE for the *.dict (reference dictionary)";
	    echo "                                 Default = \"$DICTPATH\"";
	    echo "     -x|--cosmicpath        (string) Required - PATH/FILE for the cosmic...vcf (cosmic reference variants)";
	    echo "                                 Default = \"$COSMICPATH\"";
	    echo "     -b|--blocksize         (int string) Required - blocksize for each thread";
	    echo "                                 Default = \"$BLOCKSIZE\"";
	    echo "     -t|--threadcount       (int string) Required - number of threads (default is number of cpus)";
	    echo "                                 Default = \"$BLOCKSIZE\"";
	    echo "     -u|--uuid              (string) Required - string indicating shell fuction to generate uuid";
	    echo "                                 Default = \"uuid\"";
	    echo "     -h|--uuid              (flag) display this help/usage text";
	    echo "     -d|--debug             (flag) run in debug mode";
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

# MAIN	   

# create log names after the input cram	   
INPUTFILE=`basename $CRAMPATH`;
LOG=$INPUTFILE".MUTECT_CALLING.log";
echo `date` > $LOG;
echo "run_mutect_docker_calling.sh log" >> $LOG;
echo "yamlpath:     "$YAMLPATH >> $LOG;
echo "crampath:     "$CRAMPATH >> $LOG;
echo "snppath:      "$SNPPATH >> $LOG;
echo "fastapath:    "$FASTAPATH >> $LOG;
echo "faipath:      "$FAIPATH >> $LOG;
echo "dictpath:     "$DICTPATH>> $LOG;
echo "cosmicpath:   "$COSMIC >> $LOG;
echo "blocksize :   "$BLOCKSIZE >> $LOG;
echo "threadcount : "$THREADCOUNT>> $LOG
echo "uuid:         "$UUID >> $LOG;

# Check to make sure all inputs exist
if [ ! -e $YAMLPATH ]; then
    MESSAGE="yamlpath $YAMLPATH was not supplied or does not exist - it is required"
    echo $MESSAGE
    echo $MESSAGE >> $LOG
    exit 1
fi	   
if [ ! -e $CRAMPATH ]; then
    MESSAGE="crampath $CRAMPATH was not supplied or does not exist - it is required"
    echo $MESSAGE
    echo $MESSAGE >> $LOG
    exit 1
fi
if [ ! -e $SNPPATH ]; then
    MESSAGE="snppath $SNPPATH was not supplied or does not exist - it is required"
    echo $MESSAGE
    echo $MESSAGE >> $LOG
    exit 1
fi
if [ ! -e $FASTAPATH ]; then
    MESSAGE="fastapath $FASTAPATH was not supplied or does not exist - it is required"
    echo $MESSAGE
    echo $MESSAGE >> $LOG
    exit 1
fi
if [ ! -e $FAIPATH ]; then
    MESSAGE="faipath $FAIPATH was not supplied or does not exist - it is required"
    echo $MESSAGE
    echo $MESSAGE >> $LOG
    exit 1
fi
if [ ! -e $DICTPATH ]; then
    MESSAGE="dictpath $DICTPATH was not supplied or does not exist - it is required"
    echo $MESSAGE
    echo $MESSAGE >> $LOG
    exit 1
fi
if [ ! -e $COSMICPATH ]; then
    MESSAGE="cosmicpath $COSMICPATH was not supplied or does not exist - it is required"
    echo $MESSAGE
    echo $MESSAGE >> $LOG
    exit 1
fi
if [ ! -e $BLOCKSIZE ]; then
    MESSAGE="blocksize $BLOCKSIZE was not supplied or does not exist - it is required"
    echo $MESSAGE
    echo $MESSAGE >> $LOG
    exit 1
fi
if [ ! -e $THREADCOUNT ]; then
    MESSAGE="threadcount $THREADCOUNT was not supplied or does not exist - it is required"
    echo $MESSAGE
    echo $MESSAGE >> $LOG
    exit 1
fi

# write command as string -- option to run it in normal or debug mode	   
if  [ $DEBUG -eq 1 ]; then
    SHELLCMD="sudo cwl-runner --debug $YAMLPATH --cram_path $CRAMPATH --known_snp_vcf_path $SNPPATH --reference_fasta_path $FASTAPATH --reference_fasta_fai $FAIPATH --reference_fasta_dict $DICTPATH --cosmic_path $COSMICPATH --Parallel_Block_Size $BLOCKSIZE --thread_count $THREADCOUNT --uuid $UUID 2>> $LOG"
else
    SHELLCMD="sudo cwl-runner $YAMLPATH --cram_path $CRAMPATH --known_snp_vcf_path $SNPPATH --reference_fasta_path $FASTAPATH --reference_fasta_fai $FAIPATH --reference_fasta_dict $DICTPATH --cosmic_path $COSMICPATH --Parallel_Block_Size $BLOCKSIZE --thread_count $THREADCOUNT --uuid $UUID 2>> $LOG"
fi

# print command string to log
echo "$SHELLCMD " >> $LOG;

# evaluate  command string
eval $SHELLCMD;
# check and log results
status_cmd=$?;
if [[ ${status_cmd} -gt 0 ]]; then
    echo "FAILED" >> $LOG;
else
    echo "SUCCEEDED" >> $LOG;
fi

# working example
# sudo cwl-runner --debug /home/kevin/git/mutect2-pon-cwl/workflows/mutect2-pon-workflow.cwl.yaml\
# --cram_path /home/kevin/HG00115.alt_bwamem_GRCh38DH.20150826.GBR.exome.cram\
# --known_snp_vcf_path /home/kevin/mutect_ref_files/dbsnp_144.grch38.vcf\
# --reference_fasta_path /home/kevin/mutect_ref_files/Homo_sapiens_assembly38.fa\
# --reference_fasta_fai /home/kevin/mutect_ref_files/Homo_sapiens_assembly38.fa.fai\
# --reference_fasta_dict /home/kevin/mutect_ref_files/Homo_sapiens_assembly38.dict\
# --cosmic_path /home/kevin/mutect_ref_files/CosmicCombined.srt.vcf\
# --Parallel_Block_Size 50000000\
# --thread_count 8\
# --uuid uuid 2> error.log2

# same example with this script (with debug on, as it is in the example above)
# run_mutect_docker_calling.sh -y "/home/kevin/git/mutect2-pon-cwl/workflows/mutect2-pon-workflow.cwl.yaml" -c "/home/kevin/HG00115.alt_bwamem_GRCh38DH.20150826.GBR.exome.cram" -s "/home/kevin/mutect_ref_files/dbsnp_144.grch38.vcf" -f "/home/kevin/mutect_ref_files/Homo_sapiens_assembly38.fa" -i "reference_fasta_fai /home/kevin/mutect_ref_files/Homo_sapiens_assembly38.fa.fai" -k "/home/kevin/mutect_ref_files/Homo_sapiens_assembly38.dict" -x "/home/kevin/mutect_ref_files/CosmicCombined.srt.vcf" -b "50000000" -t "8" -u "" -d

