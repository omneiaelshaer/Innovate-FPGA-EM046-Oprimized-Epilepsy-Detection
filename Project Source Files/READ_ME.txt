Epileptic patients suffer from seizure periods that occur to their brain not allowing them to lead a normal life.
In this project we are employing machine learning for the detection of the neural brain signals and sending back an electric stimuli to 
recover the brain to its normal state treating the seizure. 
The EEG signal is fed to the FPGA and the training of the Support Vector Machine (SVM) 
takes place to classify between seizure and non-seizure periods. 
Hence, triggering an electric stimuli whenever the seizure is detected to treat the seizure. 

Provided is the code of the quartus software for the vhdl project, showing the RTL design of our project.
The training of the SVM was performed by implementing Gilbert's Algorithm. The file integration_file is the top level of the hierarchy.
