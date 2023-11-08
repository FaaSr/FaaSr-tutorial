library(arrow)

compute_sum_arrow <- function(folder, input1, input2, output) {

  # Download two input files from bucket, generate a sum of their contents, and write back to bucket

  # The function uses the default S3 bucket name, configured in the FaaSr JSON 
  # folder: name of the folder where the inputs and outputs reside
  # input1, input2: names of the input files
  # output: name of the output file
  
  # The bucket is configured in the JSON payload as My_S3_Bucket
  # In this demo code, all inputs/outputs are in the same S3 folder, which is also configured by the user

  # Set up s3 bucket using arrow
  s3 <- faasr_arrow_s3_bucket()

  # Get file from s3 bucket using arrow
  frame_input1 <- arrow::read_csv_arrow(s3$path(file.path(folder, input1)))
  frame_input2 <- arrow::read_csv_arrow(s3$path(file.path(folder, input2)))
  
  # This demo function computes output <- input1 + input2 and stores the output back into S3
  # First, read the local inputs, compute the sum
  #
  frame_output <- frame_input1 + frame_input2

  # Upload the output file to S3 bucket using arrow
  arrow::write_csv_arrow(frame_output, s3$path(file.path(folder, output)))

  # Print a log message
  # 
  log_msg <- paste0('Function compute_sum finished; output written to ', folder, '/', output, ' in default S3 bucket')
  faasr_log(log_msg)
}	
