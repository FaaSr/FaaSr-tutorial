create_sample_data <- function(folder, output1, output2) {

  # Create sample files for FaaSr demo and stores in an S3 bucket
  #
  # The function uses the default S3 bucket name, configured in the FaaSr JSON
  # folder: name of the folder where the sample data is to be stored
  # output1, output2: names of the sample files to be created 
  
  # This demo function generates two data frames, exports them as CSV files and store them into S3
  # First we create two data frames df2 and df2
  #
  df1 <- NULL
  for (e in 1:10)
    rbind(df1,data.frame(v1=e,v2=e^2,v3=e^3)) -> df1
  df2 <- NULL
  for (e in 1:10)
    rbind(df2,data.frame(v1=e,v2=2*e,v3=3*e)) -> df2

  # Now we export these data frames to CSV files df1.csv and df2.csv stored in a local directory
  #
  write.table(df1, file="df1.csv", sep=",", row.names=F, col.names=T)
  write.table(df2, file="df2.csv", sep=",", row.names=F, col.names=T)
  
  # Now, upload the these file to the S3 bucket with folder name and file name provided by user
  #
  faasr_put_file(local_file="df1.csv", remote_folder=folder, remote_file=output1)
  faasr_put_file(local_file="df2.csv", remote_folder=folder, remote_file=output2)

  # Print a log message
  # 
  log_msg <- paste0('Function create_sample_data finished; outputs written to folder ', folder, ' in default S3 bucket')
  faasr_log(log_msg)
}	
