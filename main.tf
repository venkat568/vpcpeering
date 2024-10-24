
provider "aws" {
  
   region = "us-east-1"
}

## accepter 
provider "aws" {
 
  alias  = "central"
  region = "us-east-2"
}


