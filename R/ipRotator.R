
#' Initialize Gateway to AWS
#'
#' Initializes Gateway to AWS
#' @param access_key Your AWS Access Key ID
#' @param secret_access_key Your AWS Secret Access Key ID
#' @param region "us-east-1", "us-east-2", "us-west-1", "us-west-2", "eu-west-1", "eu-west-2", "eu-west-3", "eu-north-1", "eu-central-1", "ca-central-1"
#' @examples
#' init_gateway("AKIB8KIA9AO85K8IZ5HJ","nbLRi0qiMSoAGybbV2c86SEl2nhIMPNc5fagV7KQ", "eu-central-1")
#' @export
init_gateway <- function(access_key, secret_access_key, region){
  svc <- apigateway(
    config = list(
      credentials = list(
        creds = list(
          access_key_id = access_key,
          secret_access_key = secret_access_key
        )
      ),
      region = region
    )
  )
 return(svc)
}

#' Create Rest API
#'
#' Creates Rest API
#' @param svc Input your initialized Gateway.
#' @examples
#' create_rest_api(svc)
#' @export
create_rest_api <- function(svc, url){
  rest_api <- svc$create_rest_api(
    name = "ip_rotatoR",
    description = url,
    version = "0.1",
    endpointConfiguration = list(
      types = list(
        "REGIONAL"
      )
    ),
  )
  rest_api
}


#' Create Ressource
#'
#' Creates Resource
#' @param svc Input your initialized Gateway.
#' @examples
#' create_resource(svc)
#' @export
create_resource <- function(svc) {
  svc$create_resource(
    restApiId=rest_api$id,
    parentId=svc$get_resources(restApiId = rest_api$id)$items[[1]]$id,
    pathPart="{proxy+}"
  )
  resource_id <- svc$get_resources(restApiId = rest_api$id)$items[[1]]$id
  resource_id
}


#' Put Method
#'
#' Creates Method
#' @examples
#' put_method()
#' @export
put_method <- function() {
  svc$put_method(
    restApiId = rest_api$id,
    resourceId = resource_id,
    httpMethod = "ANY",
    authorizationType = "NONE",
    requestParameters= list(
      "method.request.path.proxy" = TRUE,
      "method.request.header.X-My-X-Forwarded-For" = TRUE
    )
  )
}

#' Put Integration
#'
#' Creates Integration
#' @param url The target URL you want rotating requesting IPs on
#' @examples
#' put_integration("https://www.google.com")
#' @export
put_integration <- function(url) {
  svc$put_integration(
    restApiId = rest_api$id,
    resourceId = resource_id,
    httpMethod = "ANY",
    type = "HTTP_PROXY",
    integrationHttpMethod = "ANY",
    connectionType="INTERNET",
    uri = url,
    requestParameters=list(
      "integration.request.path.proxy"= "method.request.path.proxy",
      "integration.request.header.X-Forwarded-For"= "method.request.header.X-My-X-Forwarded-For"
    )
  )
  svc$put_integration(
    restApiId = rest_api$id,
    resourceId = resource_id,
    httpMethod = "ANY",
    type = "HTTP_PROXY",
    integrationHttpMethod = "ANY",
    connectionType="INTERNET",
    uri =  paste(url, "/{proxy}", sep=""),
    requestParameters=list(
      "integration.request.path.proxy"= "method.request.path.proxy",
      "integration.request.header.X-Forwarded-For"= "method.request.header.X-My-X-Forwarded-For"
    )
  )
}

#' Create Deployement
#'
#' Deploys API
#' @examples
#' create_deployement()
#' @export
#'
create_deployement <- function (){
svc$create_deployment(
  restApiId=rest_api$id,
  stageName="ProxyStage"
)
}

#' Run All
#'
#' Runs all steps to create the IP Rotating Rest-API
#' @param access_key Your AWS Access Key ID
#' @param secret_access_key Your AWS Secret Access Key ID
#' @param region "us-east-1", "us-east-2", "us-west-1", "us-west-2", "eu-west-1", "eu-west-2", "eu-west-3", "eu-north-1", "eu-central-1", "ca-central-1"
#' @param url The target URL you want rotating requesting IPs on
#' @examples
#' run_all("AKIB8KIA9AO85K8IZ5HJ","nbLRi0qiMSoAGybbV2c86SEl2nhIMPNc5fagV7KQ", "eu-central-1", "https://www.google.com")
#' @export
#'
#'
run_all <- function (access_key, secret_access_key, region, url) {
  svc <<- init_gateway(access_key,secret_access_key, region)
  # Checks if REST-API on url already exists, if it does , connects to existing REST-API instead of creating new one
  exists = FALSE
  if (length(svc$get_rest_apis()$items) > 0) {
    for (i in 1:length(svc$get_rest_apis()$items)){
       if (svc$get_rest_apis()$items[[i]]$description == url){
         rest_api <<- svc$get_rest_api(svc$get_rest_apis()$items[[i]]$id)
         endpoint <<- str_glue("{rest_api$id}.execute-api.{region}.amazonaws.com")
         print(str_glue("REST-API with {url} already exists at {endpoint}"))
         exists = TRUE
         break
       }
    }
  }
    if (exists == FALSE) {
      rest_api <<- create_rest_api(svc, url)
      resource_id <<- create_resource(svc)
      put_method()
      url <- url
      put_integration(url)
      create_deployement()
      endpoint <<- str_glue("{rest_api$id}.execute-api.{region}.amazonaws.com")
      print(endpoint)
    }

}


#' Rotated GET
#'
#' Request URL with rotated_get to request with rotated ips
#' @param url The URL defined in the setup of the Rest API + site path (if needed)
#' @examples
#' rotated_get("https://www.reddit.com/r/all/")
#' @export
rotated_get <- function(url) {
  url <- strsplit(url,"://")
  protocol <- url[[1]][1]
  site <- url[[1]][2]
  site_path <- str_split_fixed(site,"/",2)[2]
  request_url <-  str_glue("{protocol}://{endpoint}/ProxyStage/{site_path}")
  request <- GET(request_url, add_headers("X-My-X-Forwarded-For" = ip_random(1), "Host" = endpoint ))
  print(request_url)
  return (request)
}



