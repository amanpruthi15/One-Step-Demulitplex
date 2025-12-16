#!/bin/bash

#Description and Purpose 
#To run the docker container for bcl convert to demultiplex the files 
#Author: Jesleen Sonia Pradeep Kamalesh
#Version: 1.0 ( Initial Version)
#Date: 2021-10-27
#Usage: bash {path-to-script} {config-file-path}
#Input folder: Directory of  the .csv file 
#Input File: data sheet which is .csv file
#Output folder will be created after the script is run and it contains Reports,Logs and .fastq.gz files


#Information source
source $1

if [ -d "${output_path}" ]; then 
	echo "Output Directory already exists"
	echo "Exiting to avoid overwriting"
else
	#command to run the bcl convert
	echo "BCL Convert initiated"
	docker run  -d --name  ${c_name}\
        	 -v ${input_path}:/mnt/run \
        	 -v ${output_path}:/mnt/output \
       	  zymoresearch/bcl-convert:3.9.3 \
           	  --bcl-input-directory /mnt/run \
           	  --output-directory /mnt/output/ \
             	            --sample-sheet /mnt/run/${data}\
           	  --strict-mode true \
           	  --force \
             	  --no-lane-splitting true 


	docker wait ${c_name}
	echo "BCL Convert Completed"

	#Setting permission
	sudo chown -R ${user} ${output_path}

	#Removing docker container
	docker container rm ${c_name}
	echo "Docker container removed"
fi
