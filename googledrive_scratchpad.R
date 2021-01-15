library(tidyverse)
library(googledrive)
library(rlang)

# https://googledrive.tidyverse.org/
# https://cran.r-project.org/web/packages/googledrive/googledrive.pdf


# setwd
setwd("C:/Users/Stephen/Desktop/R/googledrive")


#//////////////////////////


# drive_find
drive_find(n_max = 30)
drive_find(type = "folder")
drive_find(type = "folder") %>% slice(1) %>% drive_reveal() %>% pull(path)


drive_find(type = "spreadsheet")
drive_find(type = "csv")
drive_find(type = "xlsx")
drive_find(type = "doc")
drive_find(type = "application/pdf")
drive_find(type = "folder")
drive_find(pattern = "sen")
drive_find(pattern = "sen", type = "xlsx")
drive_find(q = "name contains 'Devine'")
drive_find(q = "name contains 'Devine'",
           q = "modifiedTime > '2020-11-01'")


#///////////////////////////////


# drive_ls
# can also use drive_find parameters (recursive = FALSE by default; set to TRUE to search sub-folders of path)
drive_ls(path = "~/usaid")
drive_ls(path = "~/usaid/mcp")
drive_ls(path = "~/usaid/mcp/", type = "csv", recursive = TRUE)

# drive_mkdir
drive_mkdir(name = "test_folder", path = "~/usaid")
drive_mkdir(name = "test_folder_2", path = "~/usaid")

# upload file
# remember to include the trailing slash on the path to let it know that the end location is inside the folder
drive_upload(media = "starwars.csv", path = "~/usaid/test_folder/starwars.csv")
drive_ls(path = "~/usaid/test_folder")
drive_ls(path = "~/usaid/test_folder_2")

# copy file
# can reference file with an id using as_id(), or a dribble (which is a complete name, id, and drive_resource row)
drive_cp(file = drive_ls(path = "~/usaid/test_folder") %>% filter(name == "starwars.csv"), 
         path = "~/usaid/test_folder_2/starwars_copy.csv")
# drive_cp(file = as_id(drive_ls(path = "~/usaid/test_folder") %>% pull(id)), path = "~/usaid/test_folder_2/starwars_copy.csv")
drive_ls(path = "~/usaid/test_folder_2")

# check metadata
metadata <- drive_ls(path = "~/usaid/test_folder_2") %>% slice(1) %>% pull(drive_resource)
metadata %>% class()
metadata %>% length() # 1
metadata <- metadata[[1]]
metadata %>% class()
metadata %>% length() # 39
metadata %>% names()
metadata %>% map(.x = ., .f = ~ length(.x)) %>% bind_cols() %>% 
        pivot_longer(cols = everything(), names_to = "var", values_to = "value") %>%
        arrange(desc(value))
metadata <- map2(.x = metadata, .y = metadata %>% names(), .f = ~ tibble(!!sym(.y) := .x) %>% nest(data = everything())) %>%
        bind_rows() %>% mutate(var = metadata %>% names())
metadata
metadata %>% glimpse()

# get links to file
# view file
metadata %>% filter(var == "webViewLink") %>% unnest(cols = everything()) %>% pull(webViewLink)
# download file
metadata %>% filter(var == "webContentLink") %>% unnest(cols = everything()) %>% pull(webContentLink)

# download file
read_csv(file = "https://drive.google.com/uc?id=19O4_M2ji1fJcpDYHQySCQd01P_7INmxg&export=download")
read_csv(file = metadata %>% filter(var == "webContentLink") %>% unnest(cols = everything()) %>% pull(webContentLink))
drive_download(file = drive_ls(path = "~/usaid/test_folder_2") %>% filter(name == "starwars.csv"),
               path = "starwars_download.csv")

# share file
drive_reveal(file = drive_ls(path = "~/usaid/test_folder_2") %>% filter(name == "starwars.csv"),
             what = "permissions")
drive_reveal(file = drive_ls(path = "~/usaid/test_folder_2") %>% filter(name == "starwars.csv"),
             what = "permissions") %>% pull(permissions_resource)
drive_share(file = drive_ls(path = "~/usaid/test_folder_2") %>% filter(name == "starwars.csv"),
            role = "reader", type = "anyone")
drive_reveal(file = drive_ls(path = "~/usaid/test_folder_2") %>% filter(name == "starwars.csv"),
             what = "permissions")

# trash file
# can reference file with an id using as_id(), or a dribble (which is a complete name, id, and drive_resource row)
drive_trash(file = drive_ls(path = "~/usaid/test_folder_2") %>% filter(name == "starwars_copy.csv"))
drive_ls(path = "~/usaid/test_folder_2")
drive_find(trashed = TRUE)

# untrash file
drive_untrash(file = drive_find(trashed = TRUE) %>% filter(name == "starwars_copy.csv"))
drive_find(trashed = TRUE)
drive_ls(path = "~/usaid/test_folder_2")

# remove file - note remove is permanent, drive_trash is not - use with caution
# can reference file with an id using as_id(), or a dribble (which is a complete name, id, and drive_resource row)
# drive_rm(file = drive_ls(path = "~/usaid/test_folder_2") %>% filter(name == "starwars_copy.csv"))
drive_ls(path = "~/usaid/test_folder_2")


#///////////////////////////////


# trash test_folders
drive_ls(path = "~/usaid/")
drive_find(trashed = TRUE)
drive_trash(file = drive_ls(path = "~/usaid/") %>% filter(name %in% c("test_folder", "test_folder_2")))
drive_ls(path = "~/usaid/")
drive_find(trashed = TRUE)



