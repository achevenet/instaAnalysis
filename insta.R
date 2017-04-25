
require(instaR)
require(httr)
require(rjson)
require(RCurl)
require(ggplot2)
require(data.table)

#############################################
### recuperer le token d'authentification ###
#############################################

if(FALSE){
  
  ###################################
  ##### autentification variables ###
  ###################################
  
  full_url <- oauth_callback()
  full_url <- gsub("(.*localhost:[0-9]{1,5}/).*", x=full_url, replacement="\\1")
  
  app_name <- "testApp"
  client_id <- "fca1a163abf145b092afa5ea06570291"
  client_secret <- "f3f9184fd4fb4683bcc53c1948e927f6"
  scope = "public_content"
  
  #my_oauth <- instaOAuth(client_id, client_secret, scope = "basic")
  #obama <- getUser( username="sven_mc_15",my_oauth)
  
  instagram <- oauth_endpoint(
    authorize = "https://api.instagram.com/oauth/authorize",
    access = "https://api.instagram.com/oauth/access_token")
  myapp <- oauth_app(app_name, client_id, client_secret)
  
  
  ig_oauth <- oauth2.0_token(instagram, myapp,scope="basic",  type = "application/x-www-form-urlencoded",cache=FALSE)
  tmp <- strsplit(toString(names(ig_oauth$credentials)), '"')
  token <- tmp[[1]][4]
  
  save(token,file="token.Rdata")
  
  
  
}

##############################
#### recupérer data ##########
##############################

if(FALSE){
  
  load("token.Rdata")
  
  #############################
  ###### retrieve data ########
  #############################
  
  user_info <- fromJSON(getURL(paste('https://api.instagram.com/v1/users/self/?access_token=',token,sep="")))
  media     <- fromJSON(getURL(paste('https://api.instagram.com/v1/users/self/media/recent/?access_token=',token,sep="")))
  
  #############################
  ###### create datable #######
  #############################
  
  time1 = Sys.time()
  
  
  
  picture = do.call( rbind, lapply( 1:length(media$data),function(i) {
    
    temp = media$data[[i]]
    
    print(i)
    print(temp)
    
    data.table( comments  = temp$comments$count,
                likes     = temp$likes$count,
                date      = toString(as.POSIXct(as.numeric(temp$created_time), origin="1970-01-01")),
                location  = if(is.null(temp$location)){NA}else{temp$location$name},
                filter    = temp$filter,
                user_like = temp$user_has_liked,
                text      = temp$caption$text,
                time      = time1
    )
    
    
    
  }))
  
  picture_hashtag = do.call( rbind, lapply( 1:length(media$data),function(i) {
    
    temp = media$data[[i]]
    
    print(i)
    print(temp)
    
    data.table( comments  = temp$comments$count,
                likes     = temp$likes$count,
                date      = toString(as.POSIXct(as.numeric(temp$created_time), origin="1970-01-01")),
                hashtags  = temp$tags,
                location  = if(is.null(temp$location)){NA}else{temp$location$name},
                filter    = temp$filter,
                user_like = temp$user_has_liked,
                text      = temp$caption$text,
                time      = time1
    )
    
    
    
  }))
  
  profile = data.table( followers = user_info$data$counts$followed_by,
                        follow    = user_info$data$counts$follows,
                        time      = time1)
  
  
  load("donne_inst.Rdata")
  
  picture1         = rbind( picture1,         picture)
  picture_hashtag1 = rbind( picture_hashtag1, picture_hashtag)
  profile1         = rbind( profile1,         profile)
  
  save(picture1,picture_hashtag1,profile1,file="donne_inst.Rdata")
  
}

###################
#### save #########
###################

if(FALSE){
  
  install.packages("googlesheets")
  library("googlesheets")
  
  iris_ss <- gs_new("iris", input = head(iris, 3), trim = TRUE)
  
  p <- gs_ls()
  
}
