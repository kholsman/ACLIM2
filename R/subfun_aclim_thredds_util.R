#' fun_thredds_nc_list.R
#'
#'
#'grab the list of files and folders on the ACLIM thredds server and corresponding url
#'
#'@param section  options are "files", for the runs or "ancillary" for extras
#'@param base_catalog  path to the server html to catalog
#'@param base_fileserver     base fileserver code 
#'@param pattern             what to search for (default is .nc files)
#'@param max_pages           limit the number so it doesn't bomb
#'@param run = NULL
#'@param level = NULL
#'
#'
#'@example
#'
#'
# sims <- aclim_thredds()
# head(sims)
# 
# # what are the sub folders?
# aclim_thredds(run = sims[2])
# 
# files_L3 <- aclim_thredds(run =sims[2], level = 3)
# files_L3

require(curl)
require(stringr)
# install.packages(c("curl", "stringr"))
library(curl)
library(stringr)

aclim_thredds <- function(section = c("files", "ancillary"),
                          run = NULL, level = NULL, time_period = NULL,
                          base_catalog = "https://data.pmel.noaa.gov/aclim/thredds/catalog/",
                          base_fileserver = "https://data.pmel.noaa.gov/aclim/thredds/fileServer/") {
  
  section <- match.arg(section)
  
  h <- new_handle(followlocation = TRUE, useragent = "R curl ACLIM THREDDS")
  fetch_html <- function(url) rawToChar(curl_fetch_memory(url, handle = h)$content)
  
  hrefs_from_html <- function(html) {
    unique(na.omit(str_match_all(html, 'href="([^"]+)"')[[1]][, 2]))
  }
  
  # Normalize any scraped value into a clean fileServer .nc/.nc4 URL (or NA)
  normalize_nc_url <- function(x) {
    if (is.na(x) || x == "") return(NA_character_)
    x <- URLdecode(x)
    
    # If it contains a fileServer path anywhere, extract and rebuild
    m <- str_match(x, "(/aclim/thredds/fileServer/[^\\s\"'&>]+\\.nc4?)")
    if (!is.na(m[1, 2])) return(paste0("https://data.pmel.noaa.gov", m[1, 2]))
    
    # If already a full URL, keep only valid fileServer .nc links
    if (grepl("^https?://", x)) {
      if (grepl("/aclim/thredds/fileServer/.*\\.nc4?$", x)) return(x)
      return(NA_character_)
    }
    
    # Otherwise treat as relative dataset id ending in .nc/.nc4
    if (grepl("\\.nc4?$", x)) {
      x <- sub("^/+", "", x)
      x <- gsub("//+", "/", x)
      return(paste0(base_fileserver, x))
    }
    
    NA_character_
  }
  
  # Extract "variable option" from a Level2 filename
  # Example:
  #  B10K-H16_CMIP5_CESM_rcp85_2005-2009_average_Cop_integrated.nc
  # -> average_Cop_integrated
  extract_variable <- function(filename, run, time_period) {
    stem <- sub("\\.nc4?$", "", filename)
    prefix <- paste0(run, "_", time_period, "_")
    sub(paste0("^", stringr::fixed(prefix)), "", stem)
  }
  
  # -------------------------
  # ANCILLARY SECTION
  # -------------------------
  if (section == "ancillary") {
    url <- paste0(base_catalog, "ancillary/catalog.html")
    html <- fetch_html(url)
    href <- hrefs_from_html(html)
    
    ds <- str_match(href, "dataset=([^&]+)")[, 2]
    ds <- unique(na.omit(ds))
    
    urls <- unique(na.omit(vapply(ds, normalize_nc_url, FUN.VALUE = character(1))))
    urls <- urls[order(urls)]
    
    out <- data.frame(
      section = "ancillary",
      filename = basename(urls),
      download_url = urls,
      stringsAsFactors = FALSE
    )
    out <- out[!duplicated(out$download_url), ]
    rownames(out) <- NULL
    return(out)
  }
  
  # -------------------------
  # FILES SECTION
  # -------------------------
  
  # 1) If run is NULL: return all model runs
  if (is.null(run)) {
    html <- fetch_html(paste0(base_catalog, "files.html"))
    href <- hrefs_from_html(html)
    
    runs <- str_match(href, "^files/([^/?#]+)\\.html$")[, 2]
    runs <- sort(unique(na.omit(runs)))
    return(runs)
  }
  
  # 2) If level is NULL: return available levels for this run
  if (is.null(level)) {
    run_url <- paste0(base_catalog, "files/", run, ".html")
    html <- fetch_html(run_url)
    href <- hrefs_from_html(html)
    
    lvls <- unique(na.omit(str_match(href, "Level\\s*([123])")[, 2]))
    if (!length(lvls)) lvls <- unique(na.omit(str_match(href, "Level([123])")[, 2]))
    
    lvls <- sort(as.integer(lvls))
    return(paste0("Level", lvls))
  }
  
  # Parse level number
  level_num <- if (is.character(level)) {
    m <- str_match(gsub("\\s+", "", level), "Level([123])")[, 2]
    if (is.na(m)) stop("level must be 1,2,3 or 'Level1'/'Level2'/'Level3'")
    as.integer(m)
  } else as.integer(level)
  
  if (!(level_num %in% 1:3)) stop("level must be 1, 2, or 3")
  
  # ---- NEW: Level2 supports time_period listing + time_period-specific file listing ----
  if (level_num == 2) {
    
    # A) If time_period is NULL: list available time_periods (e.g., 2005-2009)
    if (is.null(time_period)) {
      lvl2_url <- paste0(base_catalog,"files/", run, "/Level2.html")
      html <- fetch_html(lvl2_url)
      href <- hrefs_from_html(html)
     
      # Find folder-like links containing "YYYY-YYYY"
      time_periods <- str_match(href, "([0-9]{4}-[0-9]{4})")[, 2]
      time_periods <- sort(unique(na.omit(time_periods)))
      return(time_periods)
    }
    
    # B) If time_period == "all": index all time_periods and bind
    if (is.character(time_period) && tolower(time_period) == "all") {
      time_periods <- aclim_thredds(section = "files", run = run, level = 2, time_period = NULL,
                               base_catalog = base_catalog, base_fileserver = base_fileserver)
      dfs <- lapply(time_periods, function(p) {
        aclim_thredds(section = "files", run = run, level = 2, time_period = p,
                      base_catalog = base_catalog, base_fileserver = base_fileserver)
      })
      out <- do.call(rbind, dfs)
      out <- out[!duplicated(out$download_url), ]
      rownames(out) <- NULL
      return(out)
    }
    
    # C) Otherwise: list files under a specific time_period
    cat_url <- paste0(base_catalog, run, "/Level2/", time_period, "/catalog.html")
    html <- fetch_html(cat_url)
    href <- hrefs_from_html(html)
    
    ds <- str_match(href, "dataset=([^&]+)")[, 2]
    ds <- unique(na.omit(ds))
    
    urls <- unique(na.omit(vapply(ds, normalize_nc_url, FUN.VALUE = character(1))))
    urls <- urls[order(urls)]
    
    out <- data.frame(
      section = "files",
      run = run,
      level = "Level2",
      time_period = time_period,
      filename = basename(urls),
      download_url = urls,
      stringsAsFactors = FALSE
    )
    
    out <- out[!duplicated(out$download_url), ]
    out$variable <- vapply(out$filename, extract_variable, FUN.VALUE = character(1),
                           run = run, time_period = time_period)
    
    rownames(out) <- NULL
    return(out)
  }
  
  # ---- Level1 / Level3 (as before) ----
  cat_url <- paste0(base_catalog, "files/", run, "/Level", level_num, "/catalog.html")
  html <- fetch_html(cat_url)
  href <- hrefs_from_html(html)
  
  ds <- str_match(href, "dataset=([^&]+)")[, 2]
  ds <- unique(na.omit(ds))
  
  urls <- unique(na.omit(vapply(ds, normalize_nc_url, FUN.VALUE = character(1))))
  urls <- urls[order(urls)]
  
  out <- data.frame(
    section = "files",
    run = run,
    level = paste0("Level", level_num),
    filename = basename(urls),
    download_url = urls,
    stringsAsFactors = FALSE
  )
  
  out <- out[!duplicated(out$download_url), ]
  rownames(out) <- NULL
  out
}


#'
#'make_fldr
#'supportive utility for downloading and creating local folders for L2 thredds
#'
#'@param list_obj  aclim_thredds output object
#'@param onefolder default is F to match thredds structure
#'
make_fldr <- function(list_obj, base_path = nc_data_path, onefolder = F){
   
  if(!dir.exists(base_path)) dir.create(base_path)

  
  if(onefolder){
    
    tt <- file.path(base_path, list_obj$level,
                  list_obj$filename)
    return(tt)
  }else{
    tt <- file.path(base_path, 
                    list_obj$run)
    if(!dir.exists(tt)) dir.create(tt)
    
    tt <- file.path(base_path, 
                    list_obj$run,
                    list_obj$level)
    
    if(!dir.exists(tt)) dir.create(tt)
    
    
    if(list_obj$level == "Level3"){
    
      tt <- file.path(base_path, 
                      list_obj$run,
                      list_obj$level,
                      list_obj$filename)
      return(tt)
    }
    if(list_obj$level == "Level2"){
      tt <- file.path(base_path, 
                      list_obj$run,
                      list_obj$level,
                      list_obj$time_period)
      if(!dir.exists(tt)) dir.create(tt) 
      
      tt <- file.path(base_path, 
                      list_obj$run,
                      list_obj$level,
                      list_obj$time_period,
                      list_obj$filename)
      return(tt)
    }
  }
}


#'  ============================================================
#'  ACLIM R code
#'  Streamlined cross-platform downloader:
#'  Dependencies: none (uses system curl + base R)
#'  ============================================================
#'@param url  path to the server html to catalog
#'@param dest     where to save the output
#'@param cache_dir temporary cache directory
#'@param overwrite   overwrite existing file?, default = F
#'@param print_expected progress output, default = T
#'@param remove_partial_on_cancel  default = T
#'
#'  
require(curl)

thredds_download_nc <- function(url,
                                dest = NULL,
                                cache_dir = "~/.aclim_cache",
                                overwrite = FALSE,
                                print_expected = TRUE,
                                remove_partial_on_cancel = TRUE) {
  
  message(paste("Downloading ",url))
  # destination
  
  if (is.null(dest)) {
    cache_dir <- path.expand(cache_dir)
    dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)
    dest <- file.path(cache_dir, basename(url))
  } else {
    dest <- path.expand(dest)
    dir.create(dirname(dest), showWarnings = FALSE, recursive = TRUE)
  }
  
  if (file.exists(dest) && !overwrite) {
    message("File exists, skipping: ", dest)
    return(dest)
  }
  
  curl_bin <- Sys.which("curl")
  if (!nzchar(curl_bin)) stop("curl not found on PATH.")
  
  # (optional) expected size via HEAD
  if (isTRUE(print_expected)) {
    head_cmd <- sprintf('"%s" -sI -L "%s"', curl_bin, url)
    hdr <- tryCatch(system(head_cmd, intern = TRUE), error = function(e) character())
    clen <- hdr[grepl("^content-length:", tolower(hdr))]
    if (length(clen)) {
      expected <- as.numeric(trimws(sub("(?i)^content-length:\\s*", "", clen[1], perl = TRUE)))
      if (!is.na(expected)) message("Expected size: ", format(expected, big.mark = ","), " bytes")
    }
  }
  
  # IMPORTANT: do NOT add -# / --progress-bar / -s if you want the default meter
  cmd <- sprintf(
    '"%s" -L -C - --retry 10 --retry-delay 5 -o "%s" "%s"',
    curl_bin, dest, url
  )
  
  message("Downloading… curl progress meter follows.")
  message("Press ESC / Cmd+. to cancel.")
  
  tryCatch(
    {
      system(cmd)  # foreground => ESC kills curl
      if (!file.exists(dest)) stop("Download failed: file not created.")
      dest
    },
    interrupt = function(e) {
      message("Download cancelled by user.")
      if (isTRUE(remove_partial_on_cancel) && file.exists(dest)) {
        file.remove(dest)
        message("Partial file removed: ", dest)
      }
      stop("Cancelled.", call. = FALSE)
    }
  )
}


save_as <- function(x, name, file) {
  e <- list2env(setNames(list(x), name), parent = emptyenv())
  save(list = name, file = file, envir = e)
}
