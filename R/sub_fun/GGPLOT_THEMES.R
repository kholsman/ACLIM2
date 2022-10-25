#' My ggplot2 go-to theme
#'
#' It requires installing Hind fonts unless you change the font parameters
#'
#' @param base_family base font family
#' @param base_size base font size
#' @param strip_text_family facet label font family
#' @param strip_text_size facet label text size
#' @param plot_title_family plot tilte family
#' @param plot_title_size plot title font size
#' @param plot_title_margin plot title margin
#' @param plot_margin plot margin
#' @param subtitle_family plot subtitle family
#' @param subtitle_size plot subtitle size
#' @param subtitle_margin plot subtitle margin
#' @param caption_family plot caption family
#' @param caption_size plot caption size
#' @param caption_margin plot caption margin
#' @param axis_title_family axis title font family
#' @param axis_title_size axis title font size
#' @param axis_title_just axis title font justification \code{blmcrt}
#' @param grid panel grid (\code{TRUE}, \code{FALSE}, or a combination of
#'        \code{X}, \code{x}, \code{Y}, \code{y})
#' @param axis axis \code{TRUE}, \code{FALSE}, [\code{xy}]
#' @param ticks ticks
#' @export
#' 

require("extrafont")
# theme_kir_EBM <- function(...) {
#   theme_kir(base_family="Helvetica",
#             plot_title_family="Helvetica-Bold",
#             subtitle_family="Helvetica",
#             panel_face="bold",
#             caption_family="Helvetica",
#             plot_title_just ="r",
#             axis_title_size = 12,
#             ...)
# }
# theme_kir_EBM <- function(...) {
#   theme_kir(base_family="ArialNarrow",
#             plot_title_family="ArialNarrow-Bold",
#             subtitle_family="ArialNarrow",
#             panel_face="bold",
#             caption_family="ArialNarrow",
#             plot_title_just ="r",
#             axis_title_size = 12,
#             ...)
# }


theme_hrbrmstr <- function(base_family="Hind",
                           base_size = 11,
                           strip_text_family = "Hind Medium",
                           strip_text_size = 12,
                           plot_title_family="Hind",
                           plot_title_size = 18,
                           plot_title_margin = 10,
                           plot_margin = margin(30, 30, 30, 30),
                           subtitle_family="Hind Medium",
                           subtitle_size = 12,
                           subtitle_margin = 15,
                           caption_family="Hind Light",
                           caption_size = 9,
                           caption_margin = 10,
                           axis_title_family = subtitle_family,
                           axis_title_size = 10,
                           axis_title_just = "rt",
                           grid = TRUE,
                           axis = FALSE,
                           ticks = FALSE) {
  
  ret <- theme_minimal(base_family=base_family, base_size=base_size)
  
  ret <- ret + theme(legend.background=element_blank())
  ret <- ret + theme(legend.key=element_blank())
  
  if (inherits(grid, "character") | grid == TRUE) {
    
    ret <- ret + theme(panel.grid=element_line(color="#2b2b2bdd", size=0.10))
    ret <- ret + theme(panel.grid.major=element_line(color="#2b2b2b99", size=0.10))
    ret <- ret + theme(panel.grid.minor=element_line(color="#2b2b2b99", size=0.05))
    
    if (inherits(grid, "character")) {
      if (regexpr("X", grid)[1] < 0) ret <- ret + theme(panel.grid.major.x=element_blank())
      if (regexpr("Y", grid)[1] < 0) ret <- ret + theme(panel.grid.major.y=element_blank())
      if (regexpr("x", grid)[1] < 0) ret <- ret + theme(panel.grid.minor.x=element_blank())
      if (regexpr("y", grid)[1] < 0) ret <- ret + theme(panel.grid.minor.y=element_blank())
    }
    
  } else {
    ret <- ret + theme(panel.grid=element_blank())
  }
  
  if (inherits(axis, "character") | axis == TRUE) {
    ret <- ret + theme(axis.line=element_line(color="#2b2b2b", size=0.15))
    if (inherits(axis, "character")) {
      axis <- tolower(axis)
      if (regexpr("x", axis)[1] < 0) {
        ret <- ret + theme(axis.line.x=element_blank())
      } else {
        ret <- ret + theme(axis.line.x=element_line(color="#2b2b2b", size=0.15))
      }
      if (regexpr("y", axis)[1] < 0) {
        ret <- ret + theme(axis.line.y=element_blank())
      } else {
        ret <- ret + theme(axis.line.y=element_line(color="#2b2b2b", size=0.15))
      }
    } else {
      ret <- ret + theme(axis.line.x=element_line(color="#2b2b2b", size=0.15))
      ret <- ret + theme(axis.line.y=element_line(color="#2b2b2b", size=0.15))
    }
  } else {
    ret <- ret + theme(axis.line=element_blank())
  }
  
  if (!ticks) {
    ret <- ret + theme(axis.ticks = element_blank())
    ret <- ret + theme(axis.ticks.x = element_blank())
    ret <- ret + theme(axis.ticks.y = element_blank())
  } else {
    ret <- ret + theme(axis.ticks = element_line(size=0.15))
    ret <- ret + theme(axis.ticks.x = element_line(size=0.15))
    ret <- ret + theme(axis.ticks.y = element_line(size=0.15))
    ret <- ret + theme(axis.ticks.length = grid::unit(5, "pt"))
  }
  
  xj <- switch(tolower(substr(axis_title_just, 1, 1)), b=0, l=0, m=0.5, c=0.5, r=1, t=1)
  yj <- switch(tolower(substr(axis_title_just, 2, 2)), b=0, l=0, m=0.5, c=0.5, r=1, t=1)
  
  ret <- ret + theme(axis.text.x=element_text(margin=margin(t=0)))
  ret <- ret + theme(axis.text.y=element_text(margin=margin(r=0)))
  ret <- ret + theme(axis.title=element_text(size=axis_title_size, family=axis_title_family))
  ret <- ret + theme(axis.title.x=element_text(hjust=xj, size=axis_title_size, family=axis_title_family))
  ret <- ret + theme(axis.title.y=element_text(hjust=yj, size=axis_title_size, family=axis_title_family))
  ret <- ret + theme(strip.text=element_text(hjust=0, size=strip_text_size, face="bold", family=strip_text_family))
  ret <- ret + theme(panel.spacing.x=grid::unit(2, "lines"))
  ret <- ret + theme(panel.spacing.y=grid::unit(2, "lines"))
  ret <- ret + theme(plot.title=element_text(hjust=0, size=plot_title_size, margin=margin(b=plot_title_margin), face="bold", family=plot_title_family))
  ret <- ret + theme(plot.subtitle=element_text(hjust=0, size=subtitle_size, margin=margin(b=subtitle_margin), family=subtitle_family))
  ret <- ret + theme(plot.caption=element_text(hjust=1, size=caption_size, margin=margin(t=caption_margin), family=caption_family))
  ret <- ret + theme(plot.margin=plot_margin)
  
  ret
  
}


#' Arial Narrow theme
#'
#' @export
theme_hrbrmstr_an <- function(...) {
  theme_hrbrmstr(base_family="ArialNarrow",
                 plot_title_family="ArialNarrow-Bold",
                 subtitle_family="ArialNarrow-Italic",
                 caption_family="ArialNarrow",
                 ...)
}

#' Kir's ggplot2 go-to theme based on theme_hrbrmstr
#'
#' It requires installing Hind fonts unless you change the font parameters
#'
#' @param base_family base font family
#' @param base_size base font size
#' @param strip_text_family facet label font family
#' @param strip_text_size facet label text size
#' @param plot_title_family plot tilte family
#' @param plot_title_size plot title font size
#' @param plot_title_margin plot title margin
#' @param plot_margin plot margin
#' @param subtitle_family plot subtitle family
#' @param subtitle_size plot subtitle size
#' @param subtitle_margin plot subtitle margin
#' @param caption_family plot caption family
#' @param caption_size plot caption size
#' @param caption_margin plot caption margin
#' @param axis_title_family axis title font family
#' @param axis_title_size axis title font size
#' @param axis_title_just axis title font justification \code{blmcrt} rt = right top, bl = bottom left, etc.
#' @param grid panel grid (\code{TRUE}, \code{FALSE}, or a combination of
#'        \code{X}, \code{x}, \code{Y}, \code{y})
#' @param axis axis \code{TRUE}, \code{FALSE}, [\code{xy}]
#' @param subplottxt color of the subplot titles
#' @param ticks ticks
#' @export
#' 

theme_kir <- function(base_family="Hind",
                      base_size = 11,
                      strip_text_family = "Hind Medium",
                      strip_text_size = 12,
                      plot_title_family="Hind",
                      plot_title_size = 18,
                      plot_title_margin = 10,
                      plot_title_just ="r",
                      xangle=0,
                      plot_margin = margin(30, 30, 30, 30),
                      subtitle_family="Hind Medium",
                      subtitle_size = 12,
                      subtitle_face ="plain",
                      subtitle_margin = 15,
                      panel_face ="plain",
                      caption_family="Hind Light",
                      caption_size = 9,
                      caption_margin = 10,
                      axis_title_family = subtitle_family,
                      axis_title_size = 9,
                      axis_title_just = "cm",
                      xaxis_size=9,
                      yaxis_size=9,
                      grid = TRUE,
                      axis = FALSE,
                      sub_title_size =10,
                      sub_title_col = "black",
                      sub_title_just ="c",
                      panel_dist_y =2,
                      panel_dist_x= 2,
                      ticks = FALSE) {
  
  ret <- theme_minimal(base_family=base_family, base_size=base_size)
  
  ret <- ret + theme(legend.background=element_blank())
  ret <- ret + theme(legend.key=element_blank())
  
  if (inherits(grid, "character") | grid == TRUE) {
    
    ret <- ret + theme(panel.grid=element_line(color="#2b2b2bdd", size=0.10))
    ret <- ret + theme(panel.grid.major=element_line(color="#2b2b2b99", size=0.10))
    ret <- ret + theme(panel.grid.minor=element_line(color="#2b2b2b99", size=0.05))
    
    if (inherits(grid, "character")) {
      if (regexpr("X", grid)[1] < 0) ret <- ret + theme(panel.grid.major.x=element_blank())
      if (regexpr("Y", grid)[1] < 0) ret <- ret + theme(panel.grid.major.y=element_blank())
      if (regexpr("x", grid)[1] < 0) ret <- ret + theme(panel.grid.minor.x=element_blank())
      if (regexpr("y", grid)[1] < 0) ret <- ret + theme(panel.grid.minor.y=element_blank())
    }
    
  } else {
    ret <- ret + theme(panel.grid=element_blank())
  }
  
  if (inherits(axis, "character") | axis == TRUE) {
    ret <- ret + theme(axis.line=element_line(color="#2b2b2b", size=0.15))
    if (inherits(axis, "character")) {
      axis <- tolower(axis)
      if (regexpr("x", axis)[1] < 0) {
        ret <- ret + theme(axis.line.x=element_blank())
      } else {
        ret <- ret + theme(axis.line.x=element_line(color="#2b2b2b", size=0.15))
      }
      if (regexpr("y", axis)[1] < 0) {
        ret <- ret + theme(axis.line.y=element_blank())
      } else {
        ret <- ret + theme(axis.line.y=element_line(color="#2b2b2b", size=0.15))
      }
    } else {
      ret <- ret + theme(axis.line.x=element_line(color="#2b2b2b", size=0.15))
      ret <- ret + theme(axis.line.y=element_line(color="#2b2b2b", size=0.15))
    }
  } else {
    ret <- ret + theme(axis.line=element_blank())
  }
  
  if (!ticks) {
    ret <- ret + theme(axis.ticks = element_blank())
    ret <- ret + theme(axis.ticks.x = element_blank())
    ret <- ret + theme(axis.ticks.y = element_blank())
  } else {
    ret <- ret + theme(axis.ticks = element_line(size=0.15))
    ret <- ret + theme(axis.ticks.x = element_line(size=0.15))
    ret <- ret + theme(axis.ticks.y = element_line(size=0.15))
    ret <- ret + theme(axis.ticks.length = grid::unit(5, "pt"))
  }
  
  xj2 <- switch(tolower(substr(sub_title_just, 1, 1)), b=0, l=0, m=0.5, c=0.5, r=1, t=1)
  xj <- switch(tolower(substr(axis_title_just, 1, 1)), b=0, l=0, m=0.5, c=0.5, r=1, t=1)
  yj <- switch(tolower(substr(axis_title_just, 2, 2)), b=0, l=0, m=0.5, c=0.5, r=1, t=1)
  
  j_t <- switch(tolower(substr(plot_title_just, 1, 1)), b=0, l=0, m=0.5, c=0.5, r=1, t=1)
  
  ret <- ret + theme(axis.text.x=element_text(margin=margin(t=0),angle = xangle,size=xaxis_size))
  ret <- ret + theme(axis.text.y=element_text(margin=margin(r=0),size=yaxis_size))
  ret <- ret + theme(axis.title=element_text(size=axis_title_size, family=axis_title_family))
  ret <- ret + theme(axis.title.x=element_text(hjust=xj, size=axis_title_size, family=axis_title_family))
  ret <- ret + theme(axis.title.y=element_text(hjust=yj, size=axis_title_size, family=axis_title_family))
  ret <- ret + theme(strip.text=element_text(hjust=j_t, size=strip_text_size, face="bold", family=strip_text_family))
  ret <- ret + theme(strip.text.x=element_text(face=panel_face))
  ret <- ret + theme(strip.text.y=element_text(face=panel_face))
  
  ret <- ret + theme(panel.spacing.x=grid::unit(panel_dist_y, "lines"))
  ret <- ret + theme(panel.spacing.y=grid::unit(panel_dist_x, "lines"))
  ret <- ret + theme(plot.title=element_text(hjust=0, size=plot_title_size, margin=margin(b=plot_title_margin), face="bold", family=plot_title_family))
  ret <- ret + theme(plot.subtitle=element_text(hjust=0, size=subtitle_size, margin=margin(b=subtitle_margin), family=subtitle_family,face=subtitle_face))
  ret <- ret + theme(plot.caption=element_text(hjust=1, size=caption_size, margin=margin(t=caption_margin), family=caption_family))
  ret <- ret + theme(plot.margin=plot_margin)
  ret <- ret + theme(strip.text = element_text(colour = sub_title_col, hjust=xj2,size=sub_title_size, margin=margin(t=caption_margin), family=caption_family))
  ret
  
}

#' Arial Narrow theme
#'
#' @export
theme_kir_an <- function(...) {
  theme_kir(base_family="ArialNarrow",
            plot_title_family="ArialNarrow-Bold",
            subtitle_family="ArialNarrow-Italic",
            caption_family="ArialNarrow",
            axis_title_size = 12,
            ...)
}

theme_kir2<-function (base_size = 11, base_family = "", base_line_size = base_size/22, 
                      base_rect_size = base_size/22) 
{
  half_line <- base_size/2
  theme_grey(base_size = base_size, base_family = base_family, 
             base_line_size = base_line_size, base_rect_size = base_rect_size) %+replace% 
    theme(panel.background = element_rect(fill = "white",colour = NA), 
          panel.border = element_rect(fill = NA,colour = "grey70", size = rel(1)), 
          panel.grid = element_line(colour = "grey87"), 
          panel.grid.major = element_line(size = rel(0.5)), 
          panel.grid.minor = element_line(size = rel(0.25)), 
          axis.ticks = element_line(colour = "grey70", size = rel(0.5)), 
          legend.key = element_rect(fill = "white", colour = NA), 
          strip.background = element_rect(fill = "grey70",colour = NA), 
          strip.text = element_text(colour = "white", size = rel(0.8), 
                                    margin = margin(0.8 * half_line, 0.8 * half_line, 0.8 * half_line, 0.8 * half_line)), 
          complete = TRUE)
}

# theme_kir_EBM <- function(...) {
#   theme_kir(base_family="Helvetica",
#             plot_title_family="Helvetica-Bold",
#             subtitle_family="Helvetica",
#             panel_face="bold",
#             caption_family="Helvetica",
#             plot_title_just ="r",
#             axis_title_size = 12,
#             ...)
# }
theme_kir_EBM <- function(...) {
  theme_kir(base_family="ArialNarrow",
            plot_title_family="ArialNarrow-Bold",
            subtitle_family="ArialNarrow",
            panel_face="bold",
            caption_family="ArialNarrow",
            plot_title_just ="r",
            axis_title_size = 12,
            ...)
}

