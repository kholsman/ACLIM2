# aclim_list_services <-
# function (dataset_url,lvl=3) 
# {
#   base_url_parsed       <- httr::parse_url(dataset_url)
#   base_url_parsed$query <- NULL
#   base_url_parsed$path  <- NULL
#   list_url              <- dataset_url %>% xml2::read_html() %>% xml2::as_list()
#   x                     <- list_url$html$body$table[[lvl+1]][[1]]
#   base_url_parsed$path  <-  x$a %>% attr("href")
#   out                   <- httr::build_url(base_url_parsed) %>% utils::URLdecode()
#   
#   dataset_url %>% xml2::read_html() %>% xml2::as_list() %$%
#     html %$% body %$% table %>% purrr::map_dfr(function(x) {
#       if (is.null(names(x)))
#         return(NULL)
#       tibble::tibble(service = x$tr[[lvl+1]][[1]] %>% stringr::str_remove(stringr::coll(":",
#                                                                               TRUE)), path = x$a %>% attr("href"))
#     }) %>% dplyr::mutate(path = purrr::map_chr(path, function(p) {
#       base_url_parsed$path <- p
#       httr::build_url(base_url_parsed) %>% utils::URLdecode()
#     }))
#   
#   
#   return(out)
#   
#   dataset_url %>% xml2::read_html() %>% xml2::as_list() %$%
#     html %$% body %$% ol %>% purrr::map_dfr(function(x) {
#       if (is.null(names(x)))
#         return(NULL)
#       tibble::tibble(service = x$b[[1]] %>% stringr::str_remove(stringr::coll(":",
#                                                                               TRUE)), path = x$a %>% attr("href"))
#     }) %>% dplyr::mutate(path = purrr::map_chr(path, function(p) {
#       base_url_parsed$path <- p
#       httr::build_url(base_url_parsed) %>% utils::URLdecode()
#     }))
# }
# 
# 
# aclim_list_vars<-
# function (l2_cat) 
# {
#   base_url <- l2_cat %>% stringr::str_remove("([^/]+$)") %>% 
#     stringr::str_remove("(\\/+$)")
#   base_url %>% stringr::str_c("/Level2.xml") %>% xml2::read_xml() %>% 
#     xml2::xml_find_all(".//grid") %>% purrr::map_dfr(function(x) {
#       xml2::xml_attrs(x) %>% as.list() %>% tibble::as_tibble() %>% 
#         dplyr::bind_cols(x %>% xml2::xml_find_all(".//attribute") %>% 
#                            xml2::xml_attrs() %>% purrr::map(`[`, c("name", 
#                                                                    "value")) %>% purrr::map(function(i) {
#                                                                      out <- i["value"]
#                                                                      names(out) <- i["name"]
#                                                                      out
#                                                                    }) %>% unlist() %>% as.matrix() %>% t() %>% tibble::as_tibble())
#     })
# }
# 
#   
#   
#   
#   
#   
#   vars     <- tds_ncss_list_vars(ncss_url = l2_url)
# 
# 
# 
# 
# 
# url <- l2_url
# aclim_download<-
# function (url, out_file, bbox, vars = NULL, ncss_args = NULL, 
#           overwrite = TRUE, ...) 
# {
#   base_url <- url %>% stringr::str_remove("([^/]+$)") %>% 
#     stringr::str_remove("(\\/+$)")
#   if (is.null(vars)) {
#     vars <- tds_ncss_list_vars(url)
#   }
#   query <- list(var = vars %>% stringr::str_c(collapse = ","), 
#                 north = bbox[["ymax"]], west = bbox[["xmin"]], east = bbox[["xmax"]], 
#                 south = bbox[["ymin"]])
#   if (!is.null(ncss_args)) 
#     query %<>% c(ncss_args)
#   if (missing(out_file)) 
#     out_file <- stringr::str_c("./", basename(base_url), 
#                                ".nc")
#   dir.create(dirname(out_file), recursive = TRUE, showWarnings = FALSE)
#   if (!overwrite & file.exists(out_file)) 
#     return(out_file)
#   httr::GET(base_url, query = query, httr::write_disk(out_file,overwrite = overwrite), ...)
#   return(out_file)
# }
