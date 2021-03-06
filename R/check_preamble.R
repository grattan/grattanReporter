#' Check the preamble of a document
#' @param filename .tex file to check for errors
#' @param .report_error How should errors be reported
#' @param pre_release See \code{\link{checkGrattanReport}}.
#' @param release See \code{\link{checkGrattanReport}}.
#' @export

check_preamble <- function(filename, .report_error, pre_release = FALSE, release = FALSE){
  if (missing(.report_error)){
    .report_error <- function(...) report2console(...)
  }

  file_path <- dirname(filename)
  lines <-
    read_lines(filename) %>%
    strip_comments %>%
    trimws


  if (!grepl("^\\\\documentclass.*\\{grattan\\}$", lines[[1]], perl = TRUE)){
    .report_error(line_no = 1,
                  context = lines[[1]],
                  error_message = "Line 1 was not \\documentclass[<options>]{grattan}")
    stop("Line 1 was not \\documentclass[<options>]{grattan}")
  }

  if (grepl("submission", lines[[1L]], fixed = TRUE)) {
    return(NULL)
  }

  begin_document <- which(lines == "\\begin{document}") - 1L
  if (length(begin_document) != 1L){
    .report_error(error_message = "Missing \\begin{document}. (Must occur on a line alone.)")
    stop("Missing \\begin{document}.")
  }
  lines_before_begin_document <-
    # begin_document == 0 is impossible due to \documentclass{grattan} required on line 1
    lines[1:begin_document]

  if (!any(grepl("^\\\\addbibresource", lines_before_begin_document, perl = TRUE))){
    stop("\\addbibresource not present in document preamble. (Must not be merely present in an \\input .)")
  }

  if (pre_release){
    author_line_no <- grep("^\\\\author", lines_before_begin_document, perl = TRUE)
    len_author_lines <- length(author_line_no)

    if (len_author_lines == 0L){
      stop("\\author line not present in document preamble.")
    }

    if (len_author_lines != 1L){
      stop("More than one \\author line in document preamble.")
    }

    first_author <- gsub("^\\\\author\\{(\\w+\\s\\w+)\\b.*$",
                         "\\1",
                         lines_before_begin_document[author_line_no],
                         perl = TRUE)
    if (first_author %notin% Grattan_staff[["name"]]){
      .report_error(line_no = author_line_no[[1]],
                    context = lines_before_begin_document[author_line_no[[1]]],
                    error_message = "First author does not appear to be a member of Grattan staff.")
      stop("First author does not appear to be a member of Grattan staff.")
    }

    title_line_no <- grep("^\\\\title", lines_before_begin_document, perl = TRUE)
    len_title_lines <- length(title_line_no)

    if (len_title_lines == 0L){
      stop("\\title line not present in document preamble.")
    }

    if (len_title_lines != 1L){
      stop("More than one \\title line in document preamble.")
    }

    the_title <- gsub("^\\\\title\\{(.*)\\}\\s*$",
                      "\\1",
                      lines_before_begin_document[title_line_no],
                      perl = TRUE)
    if (nchar(the_title) < 2){
      .report_error(line_no = title_line_no,
                    context = lines_before_begin_document[title_line_no],
                    error_message = "Title is too short.")
      stop("Title is too short (possibly empty).")
    }

  }


  if (any(grepl("\\input", lines_before_begin_document, fixed = TRUE))){
    # Ensure the only input in acknowledgements is tex/acknowledgements
    acknowledgements <-
      paste0(lines_before_begin_document, collapse = " ") %>%
      gsub("^.*\\\\(acknowledgements)", "", ., perl = TRUE)

    if (any(grepl("\\input", acknowledgements, fixed = TRUE))){
      inputs <-
        gsub("^.*\\\\(?:(?:input)|(?:include(?!(?:graphics))))[{]([^\\}]+(?:\\.tex)?)[}].*$",
             "\\1",
             acknowledgements,
             perl = TRUE)

      if (inputs[[1]] != "tex/acknowledgements"){
        stop("The only permitted \\input in the preamble after \\acknowledgements is \\input{tex/acknowledgements}")
      }

      lines_before_begin_document <-
        c(lines_before_begin_document,
          readLines(file.path(file_path, "./tex/acknowledgements.tex"),
                    encoding = "UTF-8",
                    warn = FALSE))
    }
  }

  report_specific_phrases <- c("This report was written by",
                               "The opinions in this report are those of the authors",
                               "This report may be cited as")
  report_specific_phrases_regex <- sprintf("(%s)", paste0(report_specific_phrases, collapse = ")|("))

  if (AND(any(grepl("\\ReportOrWorkingPaper{Working Paper}",
                    lines_before_begin_document,
                    fixed = TRUE)),
              any(grepl(report_specific_phrases_regex,
                        lines_before_begin_document,
                        perl = TRUE)))){

    bad_phrases <- report_specific_phrases
    for (i in seq_along(report_specific_phrases)) {
      if (!any(grepl(report_specific_phrases[i], lines_before_begin_document))) {
        bad_phrases[i] <- NA_character_
      }
    }
    bad_phrases <- bad_phrases[!is.na(bad_phrases)]

    if (length(bad_phrases) > 1) {
      .report_error(error_message = "Working paper / Report inconsistency",
                    advice = paste0("\\ReportOrWorkingPaper set to {Working Paper} but statements\n\t",
                                    paste0(bad_phrases, collapse = "\n\t"),
                                    "\nstill present in document.",
                                    "\n\n",
                                    "If your document is a working paper, amend the above phrases to be consistent with a working paper.",
                                    collapse = ""))
      stop("Working paper / Report inconsistency")
    } else {
      .report_error(error_message = "Working paper / Report inconsistency",
                    advice = paste0("\\ReportOrWorkingPaper set to {Working Paper} but statement\n\t",
                                    bad_phrases,
                                    "\nstill present in document.",
                                    "\n\n",
                                    "If your document is a working paper, amend the above phrases to be consistent with a working paper.",
                                    collapse = ""))
      stop("Working paper / Report inconsistency")
    }
  }

  if (AND(any(grepl("This working paper was written by",
                    lines_before_begin_document,
                    perl = TRUE)),
          !any(grepl("\\ReportOrWorkingPaper{Working Paper}",
                     lines_before_begin_document,
                     fixed = TRUE)))){
    .report_error(error_message = "Working paper / Report inconsistency",
                  advice = paste0("\\ReportOrWorkingPaper not set to {Working Paper} but statement\n\t'This working paper was written by'\nstill present in document.",
                                  "\n\n",
                                  "If your report is a working paper, put\n\t\\ReportOrWorkingPaper{Working Paper}",
                                  "\n\n",
                                  "otherwise, say\n\t'This report was written by'",
                                  collapse = ""))
    stop("\\ReportOrWorkingPaper not set to {Working Paper} but\n\t'This working paper was written by'\nexists in document.")
  }




  if (!any(grepl("\\YEAR", lines_before_begin_document, fixed = TRUE))){
    year_provided <- FALSE
    current_year <- format(Sys.Date(), "%Y")
  } else {
    year_provided <- TRUE
    year_line <- grep("\\YEAR", lines_before_begin_document, fixed = TRUE)
    if (length(year_line) != 1L){
      stop("Multiple \\YEAR provided.")
    }
    current_year <- gsub("[^0-9]", "", lines_before_begin_document[year_line])
  }

  if (pre_release){
    if (release){
      if (any(grepl("embargo", lines_before_begin_document, perl = TRUE, ignore.case = TRUE))){
        .report_error(error_message = "String 'embargo' found before begin{document} while attempting to release a report.")
        stop("String 'embargo' found before \\begin{document} while attempting to release a document.")
      }



      GrattanReportNumber <- grep("\\GrattanReportNumber", lines_before_begin_document, fixed = TRUE, value = TRUE)
      if (length(GrattanReportNumber) >= 1L){
        if (length(GrattanReportNumber) > 1L){
          stop("Multiple \\GrattanReportNumbers in document.")
        }
        GrattanReportNumberArg <- gsub("^.*[{](.*)[}].*$", "\\1", GrattanReportNumber, perl = TRUE)

        if (substr(GrattanReportNumberArg, 0, 4) != current_year){
          if (!year_provided){
            stop("GrattanReportNumber using ", substr(GrattanReportNumberArg, 0, 4),
                 " for the year of publication, but today's date is ",
                 Sys.Date(),
                 " and \\YEAR has not been specified.")
          } else {
            stop("GrattanReportNumber using ", substr(GrattanReportNumberArg, 0, 4),
                 " for the year of publication, but line ", year_line, " is ",
                 lines_before_begin_document[year_line], ".")
          }
        }

        is.wholenumber <- function(x){
          x <- as.integer(x)
          and(!is.na(x),
              abs(x - round(x)) < .Machine$double.eps^0.5)
        }

        if (!is.wholenumber(gsub("^.{5}", "", GrattanReportNumberArg))){
          stop("GrattanReportNumber not in the form YYYY-z where z is an integer.")
        }
      }
    }


    # Check authors
    if (!any(grepl("^\\{\\\\footnotesize", lines_before_begin_document, perl = TRUE))){
      stop("Lines from 'This report may be cited as:' to 'All material ... Unported License' must be \\footnotesize.")
    }

    if (!any(lines_before_begin_document %chin% c("All material published or otherwise created by Grattan Institute is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License\\par",
                                                  "All material published or otherwise created by Grattan Institute is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. Front cover photo credit: ``the Commons'' project -- Breathe Architecture, photographer Andrew Wuttke.\\par"))){
      stop("License line not present and correct. Could not find (as a single line)\n>",
           "All material published or otherwise created by Grattan Institute is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License\\par<")
    }
    licence_line <- which(lines_before_begin_document  %chin% c("All material published or otherwise created by Grattan Institute is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License\\par",
                                                                "All material published or otherwise created by Grattan Institute is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. Front cover photo credit: ``the Commons'' project -- Breathe Architecture, photographer Andrew Wuttke.\\par"))

    if (lines_before_begin_document[licence_line + 1] != "}"){
      stop("Line after licence line must be a closing brace.")
    }

    # Check ISBN (13-digit)
    # 978-1-925015-95-9

    isbn_line <- grep("^ISBN:", lines_before_begin_document, perl = TRUE, value = FALSE)

    if (length(isbn_line) != 1L){
      if (length(isbn_line) == 0L){
        .report_error(error_message = "Missing ISBN: line.")
        stop("Missing ISBN: line.")
      } else {
        .report_error(error_message = "Multiple ISBNs provided on lines ", which(lines_before_begin_document %in% isbn_line))
        stop("Multiple ISBNs provided.")
      }
    }

    if (isbn_line != licence_line - 2){
      stop("ISBN: line must be two lines before licence line.")
    }

    isbn <-
      lines_before_begin_document %>%
      .[isbn_line] %>%
      gsub("[^0-9]", "", ., perl = TRUE) %>%
      strsplit(split = "") %>%
      unlist %>%
      as.integer

    if (identical(isbn,
                  as.integer(c(9, 7, 8, 1, 9, 2, 5, 0, 1, 5, 9, 6, 6)))){
      if (AND(the_title != "Circuit breaker: a new compact for school funding",
              !identical(Sys.getenv("TRAVIS"), "true"))) {
        the_next_isbn <- next_isbn()
        the_next_isbn_age <-
          if (is.null(attr(the_next_isbn, "isbn_age"))) {
            "(The ISBN table may be old: its age could not be determined.)"
          } else {
            paste0("(The ISBN table was updated ",
                   attr(the_next_isbn, "isbn_age"),
                   " days ago.)")
          }

        AdvisoryISBN <-
          if (nzchar(the_next_isbn)) {
            paste0("The next ISBN is ", as.character(the_next_isbn), ". ",
                   the_next_isbn_age)
          } else {
            "See grattan-admin for a new ISBN."
          }

        .report_error(line_no = isbn_line,
                      context = lines_before_begin_document[isbn_line],
                      error_message = "ISBN has already been used in 'Circuit breaker'.",
                      advice = AdvisoryISBN)
        stop("ISBN has already been used in 'Circuit breaker'.")
      }
    }

    if (length(isbn) != 13){
      .report_error(context = isbn_line,
                    error_message = "ISBN provided did not have 13 digits.")
      stop("ISBN provided did not have 13 digits.")
    }

    w <- c(1L, 3L, 1L, 3L, 1L, 3L, 1L, 3L, 1L, 3L, 1L, 3L, 1L)
    if (sum(isbn * w) %% 10 != 0){
      check_sum <- sum(isbn * w) %% 10
      .report_error(context = isbn_line,
                    error_message = paste0("Invalid ISBN. Checksum was ", check_sum))
      stop(paste0("Invalid ISBN. Checksum was ", check_sum))
    }

    rmbca <- function(x) {
      # This x may be cited as
      sprintf("This %s may be cited as:", reporttype(x))
    }
    preamble <- lines_before_begin_document

    if (!OR(OR(preamble[isbn_line - 3] %in% rmbca(preamble),
               preamble[isbn_line - 4] %in% rmbca(preamble)),
            identical(preamble[isbn_line - c(4:3)],
                      c(rmbca(preamble), "\\newline")))) {
      stop("When parsing the document preamble, I could not find 'This report/working paper may be cited as:' on the 3rd or 4th lines before 'ISBN: '.", "\n",
           "You must place that text on one of those lines for the check to continue.")
    }

    project_authors <- get_authors(filename, include_editors = FALSE)
    project_authors_initials <- gsub("^([A-Z])[a-z]+ ", "\\1. ", project_authors, perl = TRUE)
    project_authors_reversed_inits <- rev_forename_surname_bibtex(project_authors_initials)
    project_authors_textcite_inits <-
      switch(pmin.int(length(project_authors), 3),
             gsub("\\.$",
                  "\\\\@\\.",
                  project_authors_reversed_inits),

             paste0(project_authors_reversed_inits[1], " and ", gsub("\\.$",
                                                                     "\\\\@\\.",
                                                                     project_authors_reversed_inits[2])),

             paste0(paste0(project_authors_reversed_inits[-length(project_authors_reversed_inits)], collapse = ", "),
                    ", and ",
                    gsub("\\.$",
                         "\\\\@\\.",
                         last(project_authors_reversed_inits))))

    project_authors_reversed <- rev_forename_surname_bibtex(project_authors)
    project_authors_textcite <- paste0(paste0(project_authors_reversed[-length(project_authors_reversed)], collapse = ", "),
                                       ", and ",
                                       last(project_authors_reversed))

    project_authors_textcite_forename_surname <-
      paste0(paste0(project_authors[-length(project_authors)], collapse = ", "),
             ", and ",
             last(project_authors))

    project_authors_textcite_full <-
      switch(pmin.int(length(project_authors), 3),
             # 1
             project_authors_reversed_inits,

             # 2
             paste0(project_authors_textcite[1], " and ", project_authors_textcite[2]),

             # >= 3
             project_authors_textcite)

    recommended_citations <-
      c(paste0(project_authors_textcite_inits, " (", current_year, "). ",
               "\\emph{\\mytitle}. Grattan Institute."),
        paste0(project_authors_textcite_forename_surname, ". (", current_year, "). ",
               "\\emph{\\mytitle}. Grattan Institute."),
        paste0(paste0(project_authors_textcite_full, " (", current_year, "). ",
                      "\\emph{\\mytitle}. Grattan Institute.")),
        paste0(paste0(project_authors_textcite_full, ". (", current_year, "). ", # extra full stop
                      "\\emph{\\mytitle}. Grattan Institute."))
      )


    if (lines_before_begin_document[isbn_line - 2] %notin% recommended_citations){
      .report_error(error_message = "Recommended citation not present.",
                    line_no = lines_before_begin_document[isbn_line - 2],
                    column = 1)
      cat("\n")
      stop("Recommended citation should be two lines before ISBN: . ",
           "I expected one of the the citations\n\t",
           paste0(recommended_citations, collapse = "\n\t"),
           "\nbut saw\n\t", lines_before_begin_document[isbn_line - 2])
    }

    # Check todonotes hl
    todonotes_sentinel <- function(filename){
      lines <- read_lines(filename)
      any(grepl("\\\\usepackage.*(?:(?:\\{todonotes\\})|(?:\\{soul\\}))", lines, perl = TRUE))
    }

    filenames_to_guard <-
      setdiff(list.files(path = file_path,
                         pattern = "\\.tex",
                         recursive = TRUE,
                         full.names = TRUE),
              "./doc/grattexDocumentation.tex")

    has_todonotes <-
      vapply(filenames_to_guard,
             todonotes_sentinel,
             logical(1))

    if (any(has_todonotes)){
      files_w_todonotes <- filenames_to_guard[has_todonotes]
      .report_error(error_message = paste0("Found todonotes"))

      stop("pre_release = TRUE but found string usepackage{todonotes}' or 'usepackage{soul}' in ",
           "the following:\n\t", paste0(filename, collapse = "\n\t"), "\n\n",
           "most likely due to \\usepackage{todonotes}. ",
           "These strings are not permitted anywhere in the project ",
           "(even commented out or disabled) when preparing a finished document.")
    }

    hl_sentinel <- function(filename){
      any(grepl("\\hl{", lines, fixed = TRUE))
    }

    has_hl <-
      vapply(filenames_to_guard,
             hl_sentinel,
             logical(1L))

    if (any(has_hl)) {
      filenames <- filenames_to_guard[has_hl]
      filename <- filenames[[1L]]
      .report_error(context = filename,
                    extra_cat_post = paste0("Found command \\hl somewhere in ", filename,
                                            ". Ensure all comments are removed from the document."),
                    error_message = "Found command \\hl in project.")
      stop("Found command \\hl in project while attempting to prepare a final document. ",
           "Commands such as these are not permitted anywhere in the project area when a final document is being prepared.")
    }

  }
}

ReportType <- function(preamble) {
  # Title case Report / Working Paper or other
  if (any(grepl("\\ReportOrWorkingPaper", preamble, fixed = TRUE))) {
    extract_LaTeX_argument(grep("\\ReportOrWorkingPaper",
                                preamble,
                                fixed = TRUE,
                                value = TRUE),
                           "ReportOrWorkingPaper")
  } else {
    "Report"
  }
}

reporttype <- function(preamble) {
  tolower(ReportType(preamble))
}

