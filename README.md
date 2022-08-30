# ipRotator
R Package to Rotate IPs using AWS 
Useful for Webscraping with R , using PAWS AWS SDK.

devtools::install_github("mltn123/ipRotator")


?run_all  
?rotated_get

Usage:

Creates REST-API  
run_all("AKIB8KIA9AO85K8IZ5HJ","nbLRi0qiMSoAGybbV2c86SEl2nhIMPNc5fagV7KQ", "eu-central-1", "https://www.google.com")

Use it like GET in your scraping loops.  
rotated_get("https://www.google.com") 


Makes use of the monthly 1 million free IP adresses AWS offers.

Inspired by / cheated off https://github.com/Ge0rg3/requests-ip-rotator/

