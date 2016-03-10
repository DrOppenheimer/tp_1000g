	if [[ $USEPARCEL -eq 1 ]]; then
	    # download with parcel
	    # start parcel in a separate screen session
	    echo "Starting parcel session with server $PARCELIP" >> $my_run_log;
	    screen -dmS parcel
	    screen -S parcel -X stuff "parcel-tcp2udt $PARCELIP:9000\n"
	    # perform downloads with parcel







	    START_TIME=`date +%s.%N`;
		    wget $mate_1;
		    status_cmd=$?
		    if [[ ${status_cmd} -gt 0 ]]; then
			dl_fail=$(($dl_fail+1));
			echo "download fail: $dl_fail";
			echo "download fail: $dl_fail" >> $my_run_log;
			echo "download fail: $dl_fail" >> $my_error_log;
			sleep 5;
		    else
			dl_complete=$(($dl_complete+1))
			FINISH_TIME=`date +%s.%N`;
			ELAPSED_TIME=`echo "$FINISH_TIME - $START_TIME" | bc -l`;
			FILESIZE=`ls -ltr $mate_1 | cut -d " " -f 7`;
			echo -e "file_size:\t"$FILESIZE;

sleep 5

			


			# # From Satish 12-3-15 # INSTALLING AND USING PARCEL
# # Install
# python setup.py develop
# sudo apt-get install python-pip
# sudo python setup.py develop
# # Setup
# sudo vi /etc/hosts  - add 127.0.0.1 parcel.opensciencedatacloud.org
# parcel-tcp2udt 192.170.232.76:9000 &
# parcel-udt2tcp localhost:9000 &
# wget https://parcel.opensciencedatacloud.org:9000/asgc-geuvadis/ERR188021.tar.gz
