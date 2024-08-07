#!/bin/bash
#. /home/ubuntu/.bash_profile # source bash file upon starup
#. /etc/profile # source profile upon startup

##############################################################
# Setting local date variable

# date time
log_date=$(date +"%d-%m-%Y-%H-%M-%S")  

##############################################################
# URL Variables

# format: csv or xml
format="csv"
stationId=48549 # 48549 is Toronto City Center
# declare an array
# option 1
# declare -a year=([0]=2020 [1]=2021 [2]=2023)
# option 2
# year[0]=2020
# year[1]=2021
# year[3]=2023
# option 3
year=(2020 2021 2022)
month=2
day=14
# declare timeframe 
# 1:hourly data 2:daily data 3:monthly data
# data on this website is only available in the daily format, other formats are not available
timeframe=2 

##############################################################
# Project Path
# local variable with project directory path extracted from the script path by getting the grandparent directory 
script_path="$(cd "$(dirname "$(dirname "${BASH_SOURCE:-$0}")")" && pwd)"
echo "[INFO:] Project Directory is: ${script_path}"

##############################################################
# Environment Variables
# project folder
export PROJECT_FOLDER="${script_path}"
# data folder
export DATA_FOLDER="${PROJECT_FOLDER}/data"
export OUTPUT_FOLDER="${PROJECT_FOLDER}/output"
# script folder & file
export SCRIPT_FOLDER="${PROJECT_FOLDER}/script"
export PYTHON_FILE_NAME="transform.py"
export PYTHON_FILE="${SCRIPT_FOLDER}/${PYTHON_FILE_NAME}"
export SCRIPT_FILE_NAME="extract"
export SCRIPT_FILE="${SCRIPT_FOLDER}/${SCRIPT_FILE_NAME}"
# log folder & file
export LOG_FOLDER="${PROJECT_FOLDER}/logs"
export LOG_FILE_NAME="${SCRIPT_FILE_NAME}_${log_date}.log"
export LOG_FILE="${LOG_FOLDER}/${LOG_FILE_NAME}"

echo "[INFO:] LOG FILE: ${LOG_FILE}"
echo "[INFO:] SCRIPT FILE: ${SCRIPT_FILE}.sh"
echo "[INFO:] DATA FOLDER: ${DATA_FOLDER}"
 

##############################################################
# Setting Log Rules
exec > >(tee ${LOG_FILE}) 2>&1

##############################################################
# Step 1: download data with shell command
# Downloading data
echo "[INFO:] DOWNLOADING DATA"

#simple
#website="https://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=${format}&stationID=${stationId}&Year=${year}&Month=${month}&Day=${day}&timeframe=${timeframe}&submit=Download+Data"
# --content-disposition looks into the header for an appropriate file name
#wget --content-disposition ${website}
# to give your own file name
#wget ${website} -O test.csv 

for y in ${year[@]}
do
    website="https://climate.weather.gc.ca/climate_data/bulk_data_e.html?format=${format}&stationID=${stationId}&Year=${y}&Month=${month}&Day=${day}&timeframe=${timeframe}&submit=Download+Data"
    # to supress the download messages and perform download in quiet mode
    wget -q -N --content-disposition ${website} -O "${DATA_FOLDER}/${y}.csv" 
done

RC1=$?
if [ ${RC1} != 0 ]; then
    echo "[ERROR:] DOWNLOAD DATA FAILED"
    echo "[ERROR:] RETURN CODE: ${RC1}"
    echo "[ERROR:] REFER TO THE LOG FOR THE REASON OF FAILURE"
    exit 1
fi

echo "[SUCCESS:] DATA DOWNLOAD COMPLETED SUCCESSFULLY"


##############################################################
# Step 2 & 3 concatenate data to one file with the python script & save output file in the python script 
# Running Python File

echo "[INFO:] RUNNING PYTHON SCRIPT"
python3 "${PYTHON_FILE}"

RC1=$?

if [ ${RC1} != 0 ]; then
    echo "[ERROR:] Error in ${PYTHON_FILE}"
    echo "[ERROR:] RETURN CODE ${RC2}"
    echo "[ERROR:] REFER TO THE LOG FILE ${LOG_FILE} FOR THE REASON OF FAILURE"
    exit 1
fi

# Step 4: print out SUCCESS with shell command.

echo "[SUCCESS:] PYTHON SCRIPT EXECUTED SUCCESSFULLY"

exit 0