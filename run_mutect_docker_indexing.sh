#!/bin/bash

# Set defaults
YAMLPATH="~/mutect2-pon-cwl/tools/cramtools.cwl.yaml";
CRAMPATH="~/NA19771.alt_bwamem_GRCh38DH.20150826.MXL.exome.cram";
FASTAPATH="~/mutect_ref_files/Homo_sapiens_assembly38.fa";
UUID="uuid";

# Parse input options
while getopts ":y:c:f:u:dh" opt; do
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
	    echo "Script to run Shenglai's docker for indexing CRAM files";
	    echo "This is 1/2 scripts for the 1000 genome normal panel varient calling";
	    echo "(Also see run_mutect_calling.sh)";
	    echo "The script generates an indexed cram (*.cram.bai) from a cram (*.cram)";
	    echo "It requires a reference fasta file.";
	    echo ""
	    echo "OPTIONS:";
	    echo "     -y|--yamlpath          (string) Required - PATH/FILE for the *.yaml (cwl workflow)";
	    echo "                                 Default = \"$YAMLPATH\"";
	    echo "     -c|--crampath          (string) Required - PATH/FILE for the *.cram (input cram)";
	    echo "                                 Default = \"$CRAMPATH\"";
	    echo "     -f|--fastapath         (string) Required - PATH/FILE for the *.fa (reference fasta)";
	    echo "                                 Default = \"$FASTAPATH\"";
	    echo "     -u|--uuid              (string) Required - string indicating shell fuction to generate uuid";
	    echo "                                 Default = \"uuid\"";
	    echo "     -h|--help              (flag) display this help/usage text";
	    echo "     -d|--debug             (flag) run in debug mode";
	    echo ""
	    echo "USAGE";
	    echo "     run_mutect_docker_indexing.sh -y < > -c < > -f < > -u < > [other options]";
	    echo "";
	    echo "EXAMPLE:";
	    echo "run_mutect_docker_indexing.sh -y \"/home/kevin/git/mutect2-pon-cwl/tools/cramtools.cwl.yaml\" -c \"/home/kevin/HG00115.alt_bwamem_GRCh38DH.20150826.GBR.exome.cram\" -f \"/home/kevin/mutect_ref_files/Homo_sapiens_assembly38.fa\" -u \"uuid\" -d"
	    echo ""
	    echo "Kevin P. Keegan, 2016";
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

# MAIN

# create log names after the input cram	   
INPUTFILE=`basename $CRAMPATH`
LOG=$INPUTFILE."MUTECT_INDEXING.log"
echo `date` > $LOG
echo "run_mutect_docker_indexing.sh log" >> $LOG
echo "yamlpath:  "$YAMLPATH >> $LOG
echo "crampath:  "$CRAMPATH >> $LOG
echo "fastapath: "$FASTAPATH >> $LOG
echo "uuid:      "$UUID >> $LOG

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
if [ ! -e $FASTAPATH ]; then
    MESSAGE="fastapath $FASTAPATH was not supplied or does not exist - it is required"
    echo $MESSAGE
    echo $MESSAGE >> $LOG
    exit 1
fi

# write command as string -- option to run it in normal or debug mode	   
if [ $DEBUG -eq 1 ]; then
    SHELLCMD="sudo cwl-runner --debug $YAMLPATH --cram_path $CRAMPATH --reference_fasta_path $FASTAPATH --uuid $UUID 2>> $LOG"
else
    SHELLCMD="sudo cwl-runner $YAMLPATH --cram_path $CRAMPATH --reference_fasta_path $FASTAPATH --uuid $UUID 2>> $LOG"
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

# Working example from shell
# sudo cwl-runner --debug /home/kevin/git/mutect2-pon-cwl/tools/cramtools.cwl.yaml\
# --cram_path /home/kevin/HG00115.alt_bwamem_GRCh38DH.20150826.GBR.exome.cram\
# --reference_fasta_path /home/kevin/mutect_ref_files/Homo_sapiens_assembly38.fa\
# --uuid uuid 2> error.log

# same example with this script (with debug on, as it is in the example above)
# run_mutect_docker_indexing.sh -y "/home/kevin/git/mutect2-pon-cwl/workflows/mutect2-pon-workflow.cwl.yaml" -c "/home/kevin/HG00115.alt_bwamem_GRCh38DH.20150826.GBR.exome.cram" -s "/home/kevin/mutect_ref_files/dbsnp_144.grch38.vcf" -f "/home/kevin/mutect_ref_files/Homo_sapiens_assembly38.fa" -i "reference_fasta_fai /home/kevin/mutect_ref_files/Homo_sapiens_assembly38.fa.fai" -k "/home/kevin/mutect_ref_files/Homo_sapiens_assembly38.dict" -x "/home/kevin/mutect_ref_files/CosmicCombined.srt.vcf" -b "50000000" -t "8" -u "uuid" -d
