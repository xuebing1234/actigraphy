# actigraphy
sleep training/staging algorithm for actigraphy data

Instructions: 
To perform training: open Matlab, run para=perform_fitting(traindata, trainlabel, flag), where traindata is a n x 1 vector (times series of actigraphy data for n epochs), trainlabel is a nx1 vector (sleep / wake for these n epochs), and flag is a binary value ( flag is 1 if actigraphy data is from cp patients, or 0 otherwise). In command window, Matlab will also display the AUROC, accuracy, sensitivity and specificity of each run during its cross-validation. 
To perform prediction: open Matlab, run sleep_predict(testdata, para, interval, flag), where testdata is a n x 1 vector (times series of actigraphy data for n epochs), para is what returned from perform_fitting, interval is the parameter for defining sleep latency (put interval= 10 if you do not know how to use it), and flag is the binary value indicating patient type ( flag=1 if CP patients, 0 otherwise).  In command window, Matlab will also display sleep measures, including SOL, WASO, TST, and SE. 
