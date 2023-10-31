compute_sum <- function(folder, input1, input2, output) {

  # Download two input files from bucket, generate a sum of their contents, and write back to bucket

  # The function uses the default S3 bucket name, configured in the FaaSr JSON 
  # folder: name of the folder where the inputs and outputs reside
  # input1, input2: names of the input files
  # output: name of the output file
  
  # The bucket is configured in the JSON payload as My_S3_Bucket
  # In this demo code, all inputs/outputs are in the same S3 folder, which is also configured by the user
  # The downloaded files are stored in a "local" folder under names input1.csv and input2.csf
  #
  faasr_get_file(remote_folder=folder, remote_file=input1, local_file="input1.csv")
  faasr_get_file(remote_folder=folder, remote_file=input2, local_file="input2.csv")
  
  # This demo function computes output <- input1 + input2 and stores the output back into S3
  # First, read the local inputs, compute the sum, and store the output locally
  # 
  frame_input1 <- read.table("input1.csv", sep=",", header=T)
  frame_input2 <- read.table("input2.csv", sep=",", header=T)
  frame_output <- frame_input1 + frame_input2
  write.table(frame_output, file="output.csv", sep=",", row.names=F, col.names=T)

  # Now, upload the output file to the S3 bucket
  #
  faasr_put_file(local_file="output.csv", remote_folder=folder, remote_file=output)

  # Print a log message
  # 
  log_msg <- paste0('Function compute_sum finished; output written to ', folder, '/', output, ' in default S3 bucket')
  faasr_log(log_msg)
}	
