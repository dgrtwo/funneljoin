context("first-firstafter joining")
library(dplyr)

test_that("after_join works with mode = left and type = first-firstafter", {
test_that("after_join works with mode = inner and type = first-firstafter", {

  res <- after_join(landed, registered, by_user = "user_id", by_time = c("timestamp" = "timestamp"), mode = "inner", type = "first-firstafter")

  expect_is(res, "tbl_df")
  expect_equal(names(res), c("user_id", "timestamp.x", "timestamp.y"))
  expect_true(all(res$timestamp.y >= res$timestamp.x))
  expect_equal(length(res$user_id), dplyr::n_distinct(res$user_id))
  expect_true(4 %in% res$user_id)
  expect_true(1 %in% res$user_id)
  expect_true(all(!is.na(res$timestamp.x)))
  expect_true(all(!is.na(res$timestamp.y)))
  expect_true(all(!is.na(res$user_id)))
})

  res <- after_join(landed, registered, by_user = "user_id", by_time = c("timestamp" = "timestamp"), mode = "left", type = "first-firstafter")

  expect_is(res, "tbl_df")
  expect_equal(names(res), c("user_id", "timestamp.x", "timestamp.y"))
  expect_true(all(res$timestamp.y >= res$timestamp.x |
                    is.na(res$timestamp.y)))
  expect_equal(length(res$user_id), n_distinct(res$user_id))
  expect_gt(nrow(landed), nrow(res))
  expect_true(4 %in% res$user_id)
  expect_true(1 %in% res$user_id)
  expect_true(all(!is.na(res$timestamp.x)))
  expect_true(any(is.na(res$timestamp.y)))
  expect_true(all(!is.na(res$user_id)))
})

test_that("after_join works with mode = right and type = first-firstafter", {

  res <- after_join(landed, registered, by_user = "user_id", by_time = c("timestamp" = "timestamp"), mode = "right", type = "first-firstafter")

  expect_is(res, "tbl_df")
  expect_equal(names(res), c("user_id", "timestamp.x", "timestamp.y"))
  expect_true(all(res$timestamp.y >= res$timestamp.x |
                    is.na(res$timestamp.x)))
  expect_equal(n_distinct(registered$user_id), n_distinct(res$user_id))
  expect_equal(nrow(res), nrow(registered))
  expect_true(4 %in% res$user_id)
  expect_true(1 %in% res$user_id)
  expect_true(!2 %in% res$user_id)
  expect_true(all(!is.na(res$timestamp.y)))
  expect_true(any(is.na(res$timestamp.x)))
  expect_true(all(!is.na(res$user_id)))
})

test_that("after_join works with mode = anti and type = first-firstafter", {

  res <- after_join(landed, registered, by_user = "user_id", by_time = c("timestamp" = "timestamp"), mode = "anti", type = "first-firstafter")

  expect_is(res, "tbl_df")
  expect_equal(names(res), c("user_id", "timestamp"))
  expect_true(2 %in% res$user_id)
  expect_true(!3 %in% res$user_id)
  expect_true(all(!is.na(res$timestamp)))
  expect_true(all(!is.na(res$user_id)))
  expect_true(as.Date("2018-07-01") %in% res$timestamp)
})

test_that("after_join works with mode = semi and type = first-firstafter", {

  res <- after_join(landed, registered, by_user = "user_id", by_time = c("timestamp" = "timestamp"), mode = "semi", type = "first-firstafter")

  expect_is(res, "tbl_df")
  expect_equal(names(res), c("user_id", "timestamp"))
  expect_true(!2 %in% res$user_id)
  expect_true(3 %in% res$user_id)
  expect_true(all(!is.na(res$timestamp)))
  expect_true(all(!is.na(res$user_id)))
  expect_true(as.Date("2018-07-10") %in% res$timestamp)
  expect_equal(filter(res, user_id == 6)$timestamp,
               as.Date("2018-07-07"))

})

test_that("after_join works with mode = full and type = first-firstafter", {

  res <- after_join(landed, registered, by_user = "user_id", by_time = c("timestamp" = "timestamp"), mode = "full", type = "first-firstafter")

  expect_is(res, "tbl_df")
  expect_equal(names(res), c("user_id", "timestamp.x", "timestamp.y"))
  expect_true(nrow(res) >= 8)
  expect_true(all(res$timestamp.y >= res$timestamp.x |
                    is.na(res$timestamp.x) |
                    is.na(res$timestamp.y)))
  expect_gt(nrow(res), dplyr::n_distinct(landed$user_id))
  expect_gt(nrow(res), dplyr::n_distinct(registered$user_id))
  expect_true(any(is.na(res$timestamp.x)))
  expect_true(any(is.na(res$timestamp.y)))
  expect_true(all(!is.na(res$user_id)))
})

course_data <- tibble::tribble(
 ~ "user_id", ~ "course_id", ~ "started_at", ~ "completed_at",
 1, 58, "2018-07-01", "2018-07-04",
 1, 60, "2018-08-04", NA,
 2, 58, "2019-05-01", NA,
 2, 60, "2019-04-01", "2019-04-04",
 3, 58, "2019-06-01", "2019-06-02",
 3, 60, "2019-03-01", "2019-04-02"
)
test_that("after_join works when columns have same name but not joining on them", {

  res <- after_left_join(course_data %>%
                      filter(course_id == 58),
                    course_data %>%
                      filter(course_id == 60),
                    by_user = "user_id",
                    by_time = c("completed_at" = "started_at"),
                    type = "first-firstafter")

  expect_is(res, "tbl_df")
  expect_equal(names(res), c("user_id", "course_id.x", "started_at.x",
                             "completed_at.x", "course_id.y", "started_at.y", "completed_at.y"))
  expect_true(nrow(res) >= 3)
  expect_equal(unique(res$course_id.x), 58)
  expect_true(all(res$started_at.y >= res$completed_at.x |
                    is.na(res$started_at.y)))
})


