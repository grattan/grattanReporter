context("GrattanReport")

test_that("SchoolFunding.tex doesn't fail", {
  expect_null(checkGrattanReport(path = "./SchoolFunding"))
  invisible(vapply(dir(path = "./SchoolFunding/travis/grattanReport/md5/",
                       full.names = TRUE),
                   file.remove,
                   FALSE))
  invisible(vapply(dir(path = "./SchoolFunding",
                       pattern = "((pdf)|(cls))$",
                       full.names = TRUE),
                   file.remove,
                   FALSE))
})

test_that("SchoolFunding.tex", {
  skip_on_travis()
  if (!dir.exists("./SchoolFunding/PRE-RELEASE")){
    dir.create("./SchoolFunding/PRE-RELEASE")
  }


  file_remove("./SchoolFunding/PRE-RELEASE/SchoolFunding.pdf")


  checkGrattanReport(path = "./SchoolFunding",
                     compile = TRUE, pre_release = TRUE, release = FALSE)

  expect_true(file.exists("./SchoolFunding/PRE-RELEASE/SchoolFunding.pdf"))
  invisible(vapply(dir(path = "./SchoolFunding/travis/grattanReport/md5/",
                       full.names = TRUE),
                   file.remove,
                   FALSE))
  file_remove("./SchoolFunding/travis/grattanReport/compile")
  file_remove("./SchoolFunding/travis/grattanReport/pre_release")
  file_remove("./SchoolFunding/travis/grattanReport/release")
})


# test_that("Engaging-students", {
#   skip_on_travis()
#   skip_if_not(nzchar(tools::find_gs_cmd()))
#   if (!dir.exists("./Engaging-students/RELEASE")){
#     dir.create("./Engaging-students/RELEASE")
#   }
# 
#   if (file.exists("./Engaging-students/RELEASE/Engaging-students--creating-classrooms-that-improve-learning.pdf")){
#     file.remove("./Engaging-students/RELEASE/Engaging-students--creating-classrooms-that-improve-learning.pdf")
#   }
# 
#   expect_null(checkGrattanReport(path = "./Engaging-students/",
#                                  compile = TRUE, pre_release = TRUE, release = TRUE))
# 
#   file.remove("./Engaging-students/RELEASE/Engaging-students--creating-classrooms-that-improve-learning.pdf")
#   invisible(vapply(dir(path = "./Engaging-students/travis/grattanReport/md5/",
#                        recursive = TRUE,
#                        include.dirs = FALSE,
#                        full.names = TRUE),
#                    file.remove,
#                    FALSE))
#   file_remove("./Engaging-students/travis/grattanReport/compile")
#   file_remove("./Engaging-students/travis/grattanReport/pre_release")
#   file_remove("./Engaging-students/travis/grattanReport/release")
# })

# test_that("Check NEM 2017 Sep paper", {
#   skip_on_travis()
#   skip_if_not(nzchar(tools::find_gs_cmd()))
#   expect_null(checkGrattanReport("./NEM-capacity-markets/", update_grattan.cls = FALSE))
#   expect_null(checkGrattanReport("./NEM-capacity-markets/",
#                                  compile = TRUE,
#                                  pre_release = TRUE,
#                                  release = TRUE))
#   expect_true(file.exists("./NEM-capacity-markets/RELEASE/Next-Generation--the-long-term-future-of-the-National-Electricity-Market.pdf"))
#   file.remove("./NEM-capacity-markets/RELEASE/Next-Generation--the-long-term-future-of-the-National-Electricity-Market.pdf")
#   invisible(vapply(dir(path = "./NEM-capacity-markets/travis/grattanReport/md5/",
#                        recursive = TRUE,
#                        include.dirs = FALSE,
#                        full.names = TRUE),
#                    file.remove,
#                    FALSE))
#   file_remove("./NEM-capacity-markets/travis/grattanReport/compile")
#   file_remove("./NEM-capacity-markets/travis/grattanReport/pre_release")
#   file_remove("./NEM-capacity-markets/travis/grattanReport/release")
# })

# test_that("Competition report", {
#   skip_on_travis()
#   skip_if_not(nzchar(tools::find_gs_cmd()))
#   hutils::provide.dir("./CompetitionReport/travis/grattanReport")
#   expect_null(checkGrattanReport("./CompetitionReport/", update_grattan.cls = FALSE))
#   expect_null(checkGrattanReport("./CompetitionReport/",
#                                  compile = TRUE,
#                                  pre_release = TRUE,
#                                  release = TRUE))
#   expect_true(file.exists("./CompetitionReport/RELEASE/Competition-in-Australia--Too-little-of-a-good-thing-.pdf"))
#   file.remove("./CompetitionReport/RELEASE/Competition-in-Australia--Too-little-of-a-good-thing-.pdf")
#   file.remove("./CompetitionReport/travis/grattanReport/md5/bib/Grattan-Master-Bibliography.bib")
#   file.remove("./CompetitionReport/travis/grattanReport/md5/bib/Concentration.bib")
# })

file_remove("./SchoolFunding/travis/grattanReport/md5/2016-SchoolFunding.bib")


file_remove("./Engaging-students/travis/grattanReport/md5/bib/Grattan-Master-Bibliography.bib")

file_remove("./Engaging-students/travis/grattanReport/md5/bib/Grattan-Master-Bibliography.bib")

file_remove("./NEM-capacity-markets/travis/grattanReport/md5/bib/Grattan-Master-Bibliography.bib")

# test_that("Health report 2018", {
#   current_wd <- getwd()
#   temp_dir <- tempdir()
#   setwd(temp_dir)
#   if (WINDOWS()) {
#     download.file(url = "https://github.com/grattan/zzz-2018-Health-Using-data-to-reduce-health-complications/zipball/master",
#                   mode = "wb",
#                   quiet = TRUE,
#                   destfile = "Health2018A.zip")
#     unzip("Health2018A.zip", exdir = ".")
#     setwd(grep("grattan-zzz-2018-Health-Using-data-to-reduce-health-complications",
#                list.dirs(recursive = FALSE),
#                fixed = TRUE,
#                value = TRUE))
#     checkGrattanReports(compile = TRUE, pre_release = TRUE, release = FALSE, update_grattan.cls = FALSE)
#   } else {
#     download.file(url = "https://github.com/grattan/zzz-2018-Health-Using-data-to-reduce-health-complications/tarball/master",
#                   mode = "wb",
#                   quiet = TRUE,
#                   destfile = "Health2018A.tar.gz")
#     untar("Health2018A.tar.gz", exdir = ".")
#     setwd(grep("grattan-zzz-2018-Health-Using-data-to-reduce-health-complications",
#                list.dirs(),
#                fixed = TRUE,
#                value = TRUE))
#     checkGrattanReports(compile = !identical(Sys.getenv("TRAVIS"), "true"),
#                         pre_release = !identical(Sys.getenv("TRAVIS"), "true"),
#                         release = FALSE,
#                         update_grattan.cls = FALSE)
#     setwd(current_wd)
#   }
# })

test_that("Higher ed report 2018 (esp. Century footnote)", {
  get_report <- function(name, century = FALSE) {
    current_wd <- getwd()
    temp_dir <- tempfile(pattern = "")
    hutils::provide.dir(temp_dir)
    temp_dir <- normalizePath(temp_dir, winslash = "/")
    setwd(temp_dir)
    WIN <- .Platform$OS.type == "windows"

    dest_file <- paste0(gsub("[^A-Za-z0-9]", "", name),
                        if (WIN) "temp.zip" else "temp.tar.tz")
    download.file(url = paste0("https://github.com/grattan/",
                               name,
                               "/",
                               if (WIN) "zipball" else "tarball",
                               "/master"),
                  mode = "wb",
                  quiet = TRUE,
                  destfile = dest_file)
    unzip(dest_file, exdir = ".")
    new_path <- grep(name,
                     list.dirs(),
                     fixed = TRUE,
                     value = TRUE)

    if (!length(new_path) || !is.character(new_path)) {
      setwd(current_wd)
      skip(paste0(list.dirs(), collapse = "  "))
    } else {
      setwd(new_path)
    }

    checkGrattanReports(compile = TRUE,
                        pre_release = TRUE,
                        release = FALSE,
                        update_grattan.cls = FALSE)
    if (century) {
      file.tex <- dir(pattern = "\\.tex$")[1]
      if (WIN) {
        shell(paste("pdflatex -interaction=batchmode", file.tex), intern = TRUE)
        shell(paste("biber", sub("\\.tex$", "", file.tex)))
        shell(paste("pdflatex -interaction=batchmode", file.tex), intern = TRUE)
        shell(paste("pdflatex -interaction=batchmode", file.tex), intern = TRUE)
      } else {
        system(paste("pdflatex -interaction=batchmode", file.tex), intern = TRUE)
        system(paste("biber", sub("\\.tex$", "", file.tex)))
        system(paste("pdflatex -interaction=batchmode", file.tex), intern = TRUE)
        system(paste("pdflatex -interaction=batchmode", file.tex), intern = TRUE)
      }
      check_CenturyFootnote()
      expect_false(CenturyFootnote_suspect)
    }
    setwd(current_wd)
  }

  get_report("zzz-2018-highered-selection", century = TRUE)
  get_report("zzz-2018-Energy-Stranded-assets", century = TRUE)
  get_report("zzz-2018-Transport-Discount-rates", century = TRUE)

})


