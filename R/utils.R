

AND <- `&&`
OR <- `||`

`%||%` <- function(x, y) if (is.null(x)) y else x

fill_blanks <- function(S) {
  # from zoo
  L <- !is.na(S)
  c(S[L][1L], S[L], use.names = FALSE)[cumsum(L) + 1L]
}

not_length0 <- function(x) as.logical(length(x))

# takes a vector of froms and tos and takes their union
seq.default.Vectorized <- function(x, y)
  Vectorize(seq.default, vectorize.args = c("from", "to"))(x, y)

Seq_union <- function(x, y){
  if (length(x) == 1L && length(y) == 1L){
    seq.int(x, y)
  } else {
    if (length(x) == length(y)){
      unlist(seq.default.Vectorized(x, y))
    } else {
      lengthx <- length(x)
      lengthy <- length(y)
      if (lengthx != 1L && lengthy != 1L){
        stop("x and y must have the same length if neither have length 1.")
      }
      if (lengthx == 1L){
        Seq_union(rep(x, lengthy), y) %>%
          unique.default
      } else {
        Seq_union(x, rep(y, lengthx)) %>%
          unique.default
      }
    }
  }
}

rev_forename_surname_bibtex <- function(author_fields){
  full_names <-
    lapply(author_fields, strsplit, " and ") %>%
    lapply(unlist, recursive = FALSE)

  comma_name <-
    full_names %>%
    lapply(grepl, pattern = ", ", fixed = TRUE)

  forename_surnames <-
    full_names %>%
    lapply(strsplit, split = "(, )|(\\s((?!(?:v[ao]n)|(?:der?)|(?:di))(?=(\\w+$))))", perl = TRUE)

  out <- forename_surnames

  for (field in seq_along(author_fields)){
    for (nom in seq_along(full_names[[field]])){
      if (!comma_name[[field]][[nom]]){
        out[[field]][[nom]] <- rev(out[[field]][[nom]])
      }
    }
  }

  lapply(out, FUN = function(author_name){
    lapply(author_name, paste0, collapse = ", ")
  }) %>%
    sapply(FUN = function(authors){
      paste0(authors, collapse = " and ")
    })
}

nth_max <- function(x, n){
  if (n == 1L) {
    return(max(n))
  } else {
    lx <- length(x)
    sort(x, partial = lx - n + 1L)[lx - n + 1L]
  }
}

nth_min <- function(x, n){
  if (n == 1L) {
    return(min(x))
  }
  sort(x)[n]
}

nth_min.int <- function(x, n){
  sort.int(x)[n]
}

strip_comments <- function(lines){
  gsub("(?<!(\\\\))[%].*$", "%", lines, perl = TRUE)
}

move_to <- function(to.dir,
                    from.dir = ".",
                    pattern = "\\.((pdf)|(tex)|(cls)|(sty)|(Rnw)|(bib)|(png)|(jpg)|(txt))$"){
  x <- list.files(path = from.dir,
                  pattern = pattern,
                  full.names = TRUE,
                  recursive = TRUE,
                  include.dirs = FALSE)
  x.dirs <- file.path(to.dir,
                      list.dirs(path = from.dir, recursive = TRUE, full.names = TRUE))
  dir_create <- function(x) if (!dir.exists(x)) dir.create(x)
  lapply(x.dirs, dir_create)
  file.copy(x, file.path(to.dir, x), overwrite = TRUE, recursive = FALSE)
  setwd(to.dir)
  cat("   Attempting compilation in temp directory:",
      normalizePath(to.dir, winslash = "/"),
      "\n")
}

r2 <- function(a, b) sprintf("%s%s", a, b)
r3 <- function(a, b, d) sprintf("%s%s%s", a, b, d)
r4 <- function(a, b, d, e) sprintf("%s%s%s%s", a, b, d, e)
r5 <- function(a, b, d, e, f) sprintf("%s%s%s%s%s", a, b, d, e, f)
r9 <- function(a1, a2, a3, a4, a5, a6, a7, a8, a9) sprintf("%s%s%s%s%s%s%s%s%s", a1, a2, a3, a4, a5, a6, a7, a8, a9)

trimws_if_char <- function(x) if (is.character(x)) trimws(x) else x


insert <- function(x, i, new) {
  stopifnot(typeof(new) == typeof(x),
            between(i, 1L, length(x)))
  out <- c(x, x[1L])
  for (j in seq_along(out)) {
    if (j == i) {
      out[j] <- new
    }
    if (j > i) {
      out[j] <- x[j - 1L]
    }
  }
  out
}

WINDOWS <- function() {
  identical(.Platform$OS, "windows")
}

dropbox_path <- function() {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    message("jsonlite not available, so Dropbox path unknown")
    return(NA_character_)
  }

  DropboxInfo <-
    if (WINDOWS() || nzchar(Sys.getenv("LOCALAPPDATA"))) {
      file.path(Sys.getenv("LOCALAPPDATA"), "Dropbox", "info.json")
    } else if (file.exists("~/.dropbox/info.json")) {
      "~/.dropbox/info.json"
    } else {
      message("jsonlite is available, but unable to locate info.json")
      return(NA_character_)
    }

  jsonlite::fromJSON(DropboxInfo) %>%
    magrittr::use_series("business") %>%
    magrittr::use_series("path") %>%
    normalizePath(winslash = "/")
}

file_remove <- function(x) {
  file.exists(x) && file.remove(x)
}

