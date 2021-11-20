#!/bin/bash

RUN_MODE=-2;

CUR_DIR_ABS=$(pwd)
CUR_DIR=${PWD##*/}
echo "Welcome to $CUR_DIR running script!"

# Prompt to BACKUP data
read -p "Do you want to save a backup of previous lab?[y]: " BACKUP
if [ "$BACKUP" == 'y' ]; then
	bash ./backup.sh
fi

# Main menu
echo "This is the main menu of the script, you can choose:
 0. To run all scripts
 For Direct-Form:
  1. To run only Simulation and Synthesis
  2. To run only Power Switching Simulation
  3. To run only Planning and Power switching Simulation
 For Look-Ahead form:
  4. To run only Simulation and Synthesis
  5. To run only Power Switching Simulation
  6. To run only Planning and Power switching Simulation
-1. To exit
"
while [ $RUN_MODE -gt 6 ] || [ $RUN_MODE -lt -1 ]
do
	read -p "Enter running mode[-1 - 6]: " RUN_MODE
done

###############################################################################################
PROJECT=Direct-Form-II
PROJECT_DIR=${CUR_DIR_ABS}/${PROJECT}
##############################
if [ $RUN_MODE = '0' ] || [ $RUN_MODE = '1' ]; then
	# Modelsim
	echo -e "\n###############################\n# Starting Modelsim logic simulation of ${PROJECT}\n"
	cd $PROJECT_DIR/sim

	if [ -d "work" ] || [ -d "WORK" ]; then
		echo "Removing old library"
		rm -R work/ WORK/ > /dev/null 2>&1
	fi

	export LM_LICENSE_FILE=1717@led-x3850-3.polito.it

	/software/mentor/modelsim_6.2g/linux/vsim -c -do commands-rtl.do

	# Synopsys
	echo -e "\n###############################\n# Starting Synopsys synthesis of ${PROJECT}\n"
	cd $PROJECT_DIR/syn

	if [ -d "work" ] || [ -d "WORK" ]; then
		echo "Removing old library"
		rm -R work/ WORK/ > /dev/null 2>&1
	fi

	export LM_LICENSE_FILE=27020@led-x3850-3.polito.it

	/software/synopsys/syn_current_64.18/bin/design_vision -f script.scr -no_gui
fi
###############################
if [ $RUN_MODE = '0' ] || [ $RUN_MODE = '2' ]; then
	# Modelsim
	echo -e "\n###############################\n# Starting Modelsim switching simulation of ${PROJECT}\n"
	cd $PROJECT_DIR/sim

	if ! [ -d "../vcd" ]; then
		echo "Creating vcd folder"
		mkdir ../vcd/ > /dev/null 2>&1
	fi
	if ! [ -d "../saif" ]; then
		echo "Creating saif folder"
		mkdir ../saif/ > /dev/null 2>&1
	fi

	if [ -d "work" ] || [ -d "WORK" ]; then
		echo "Removing old library"
		rm -R work/ WORK/ > /dev/null 2>&1
	fi

	export LM_LICENSE_FILE=1717@led-x3850-3.polito.it

	/software/mentor/modelsim_6.2g/linux/vsim -c -do commands-syn.do

	# Synopsys
	echo -e "\n###############################\n# Starting Synopsys power analysis of ${PROJECT}\n"
	cd $PROJECT_DIR/syn

	if [ -d "work" ] || [ -d "WORK" ]; then
		echo "Removing old library"
		rm -R work/ WORK/ > /dev/null 2>&1
	fi

	export LM_LICENSE_FILE=27020@led-x3850-3.polito.it

	/software/synopsys/syn_current_64.18/bin/vcd2saif -input ../vcd/myiir_syn.vcd -output ../saif/myiir_syn.saif
	/software/synopsys/syn_current_64.18/bin/design_vision -f vcd2saif.scr -no_gui
fi
##############################
if [ $RUN_MODE = '0' ] || [ $RUN_MODE = '3' ]; then
	# Innovus
	echo -e "\n###############################\n# Starting Innovus planning of ${PROJECT}\n"
	cd $PROJECT_DIR/innovus

	export LM_LICENSE_FILE=5280@led-x3850-3.polito.it
	export CDS_LIC_FILE=$LM_LICENSE_FILE

	/software/cadence/INNOVUS/INNOVUS17.11/bin/innovus -files script.tcl

	# Modelsim
	echo -e "\n###############################\n# Starting Modelsim switching simulation of ${PROJECT}\n"
	cd $PROJECT_DIR/sim

	if [ -d "work" ] || [ -d "WORK" ]; then
		echo "Removing old library"
		rm -R work/ WORK/ > /dev/null 2>&1
	fi

	export LM_LICENSE_FILE=1717@led-x3850-3.polito.it

	/software/mentor/modelsim_6.2g/linux/vsim -c -do commands-inn.do
	# Innovus
	echo -e "\n###############################\n# Starting Innovus planning of ${PROJECT}\n"
	cd $PROJECT_DIR/innovus

	export LM_LICENSE_FILE=5280@led-x3850-3.polito.it
	export CDS_LIC_FILE=$LM_LICENSE_FILE

	/software/cadence/INNOVUS/INNOVUS17.11/bin/innovus -files commands2.tcl
fi

###################################################################################################
PROJECT=Look-Ahead
PROJECT_DIR=${CUR_DIR_ABS}/${PROJECT}
##############################
if [ $RUN_MODE = '0' ] || [ $RUN_MODE = '4' ]; then
	# Modelsim
	echo -e "\n###############################\n# Starting Modelsim logic simulation of ${PROJECT}\n"
	cd $PROJECT_DIR/sim
	if [ -d "work" ] || [ -d "WORK" ]; then
		echo "Removing old library"
		rm -R work/ WORK/ > /dev/null 2>&1
	fi

	export LM_LICENSE_FILE=1717@led-x3850-3.polito.it

	/software/mentor/modelsim_6.2g/linux/vsim -c -do commands-rtl.do

	# Synopsys
	echo -e "\n###############################\n# Starting Synopsys synthesis of ${PROJECT}\n"
	cd $PROJECT_DIR/syn

	if [ -d "work" ] || [ -d "WORK" ]; then
		echo "Removing old library"
		rm -R work/ WORK/ > /dev/null 2>&1
	fi

	export LM_LICENSE_FILE=27020@led-x3850-3.polito.it

	/software/synopsys/syn_current_64.18/bin/design_vision -f script.scr -no_gui
fi
###############################
if [ $RUN_MODE = '0' ] || [ $RUN_MODE = '5' ]; then
	# Modelsim
	echo -e "\n###############################\n# Starting Modelsim switching simulation of ${PROJECT}\n"
	cd $PROJECT_DIR/sim

	if ! [ -d "../vcd" ]; then
		echo "Creating vcd folder"
		mkdir ../vcd/ > /dev/null 2>&1
	fi
	if ! [ -d "../saif" ]; then
		echo "Creating saif folder"
		mkdir ../saif/ > /dev/null 2>&1
	fi


	if [ -d "work" ] || [ -d "WORK" ]; then
		echo "Removing old library"
		rm -R work/ WORK/ > /dev/null 2>&1
	fi

	export LM_LICENSE_FILE=1717@led-x3850-3.polito.it

	/software/mentor/modelsim_6.2g/linux/vsim -c -do commands-syn.do

	# Synopsys
	echo -e "\n###############################\n# Starting Synopsys power analysis of ${PROJECT}\n"
	cd $PROJECT_DIR/syn

	if [ -d "work" ] || [ -d "WORK" ]; then
		echo "Removing old library"
		rm -R work/ WORK/ > /dev/null 2>&1
	fi

	export LM_LICENSE_FILE=27020@led-x3850-3.polito.it

	/software/synopsys/syn_current_64.18/bin/vcd2saif -input ../vcd/myiir_LA_syn.vcd -output ../saif/myiir_LA_syn.saif
	/software/synopsys/syn_current_64.18/bin/design_vision -f vcd2saif.scr -no_gui
fi
##############################
if [ $RUN_MODE = '0' ] || [ $RUN_MODE = '6' ]; then
	# Innovus
	echo -e "\n###############################\n# Starting Innovus planning of ${PROJECT}\n"
	cd $PROJECT_DIR/innovus

	export LM_LICENSE_FILE=5280@led-x3850-3.polito.it
	export CDS_LIC_FILE=$LM_LICENSE_FILE

	/software/cadence/INNOVUS/INNOVUS17.11/bin/innovus -files script.tcl
	# Modelsim
	echo -e "\n###############################\n# Starting Modelsim switching simulation of ${PROJECT}\n"
	cd $PROJECT_DIR/sim

	if [ -d "work" ] || [ -d "WORK" ]; then
		echo "Removing old library"
		rm -R work/ WORK/ > /dev/null 2>&1
	fi

	export LM_LICENSE_FILE=1717@led-x3850-3.polito.it

	/software/mentor/modelsim_6.2g/linux/vsim -c -do commands-inn.do
	# Innovus
	echo -e "\n###############################\n# Starting Innovus planning of ${PROJECT}\n"
	cd $PROJECT_DIR/innovus

	export LM_LICENSE_FILE=5280@led-x3850-3.polito.it
	export CDS_LIC_FILE=$LM_LICENSE_FILE

	/software/cadence/INNOVUS/INNOVUS17.11/bin/innovus -files commands2.tcl
fi

