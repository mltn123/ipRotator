# ipRotator
R Package to Rotate IPs using AWS  
Useful for Web Scraping with R , using PAWS AWS SDK. 




?run_all  
?rotated_get  
?delete_all_apis

Usage:
```R
devtools::install_github("mltn123/ipRotator")
library(ipRotator)
#Creates REST-API  
run_all("AKIB8KIA9AO85K8IZ5HJ","nbLRi0qiMSoAGybbV2c86SEl2nhIMPNc5fagV7KQ", "eu-central-1", "https://www.google.com")

#Use it like GET in your scraping loops.  
for(i in 1:100) {   
  result <- rotated_get("https://www.google.com") 
  text <- content(result, "text")
}
# Cleanup (deletes all REST APIS on AWS Account, handle with care)
delete_all_apis()
```

Makes use of the monthly 1 million free API hits.

Inspired by / cheated off https://github.com/Ge0rg3/requests-ip-rotator/

Basically works like this
https://bigb0sss.github.io/posts/redteam-rotate-ip-aws-gateway/
with some extra tweaks.

Use https://pipedream.com to debug your scraping, helped me a lot

