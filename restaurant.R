# Group Project
# Author: Han Nguyen 
# Version: 1.0.0 
# Date created: 10/18/2023
# Date last modified: 10/18/2023

# Set working directory ----
setwd("~/Dickinson/Fall 2023/INBM 300/Group Project")

# Install packages ----
# install.packages("dplyr")
# install.packages("tidyr")
# install.packages("lubridate")
# install.packages("Metrics")
# install.packages("ROSE")
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(Metrics)
library(ROSE)

# (1) Load data ----
order <- read.csv("orders050917.csv")

# (2) Data summary ----
head(order)
summary(order)
glimpse(order)

# (3) Check missing values ----
# Check if saleItemName has missing values -> yes, but non-standard missing values
unique(order[,'saleItemName'])
order1 <- order %>%
  mutate(saleItemName = replace(saleItemName, saleItemName ==  "#NAME?", NA)) %>%
  mutate(saleItemName = replace(saleItemName, saleItemName ==  "==================", NA)) %>%
  mutate(saleItemName = replace(saleItemName, saleItemName ==  "DON'T MAKE ALL THE ORDER", NA)) %>%
  filter(!is.na(saleItemName))

# Check if price has missing values -> no
unique(order1[,'price'])

# Check if quantity has missing values -> no but have values being 0 -> order_cancellation
unique(order1[,'quantity'])

# Check orderType column -> no missing values
unique(order1[,'orderCreatedOn'])

# Check categoryName column -> no missing values
unique(order1[,'categoryName'])
  # these values are suspicious: "CategoryForDeletedItems", "System Generated", "Kitchen Order"
  # Values can be used to identify free/discounted items: "Free On House", "50% OFF", "Free Tax Item", "Today Special"

# Check menuGroupName column -> no missing values
unique(order1[,'menuGroupName'])

# Check menuHours column -> missing values "NULL" because of "Open Food" as a menu group
unique(order1[,'menuHours'])


order2 <- order1
order2$menuHours[order2$menuHours=="NULL" & order2$menuGroupName == "Open Food"] <- "Open Food"

# Check guestNum column -> no missing values
unique(order2[,'guestNum'])

# Check orderClosedOn column 
unique(order2[,'orderClosedOn'])

order3 <- order2 %>% filter(orderClosedOn != "NULL")

# Check orderDurationInMinutes column -> values being 0
unique(order3[,'orderDurationInMinutes'])
order3$orderDurationInMinutes <- as.numeric(order3$orderDurationInMinutes)

# Check tableId column -> missing values "NULL" mostly because of TOGO, Online_pickup, and pickup
unique(order3[,'tableId'])
order3 %>% filter(tableId == "NULL") %>% 
  group_by(orderType) %>% 
  summarize(ct = n())

# (4) Transform data ----
order4 <- order3

order4 <- order4 %>% separate(orderCreatedOn, c("orderCreatedOnDate", "orderCreatedOnTime"), sep = " ", remove = F) %>%
  separate(orderCreatedOnDate, c("orderCreatedOnMonth", "orderCreatedOnDay", "orderCreatedOnYear"), sep = "/") %>%
  separate(orderCreatedOnTime, c("orderCreatedOnHour", "orderCreatedOnMinute"))

order4 <- order4 %>% separate(orderClosedOn, c("orderClosedOnDate", "orderClosedOnTime"), sep = " ", remove = F) %>%
  separate(orderClosedOnDate, c("orderClosedOnMonth", "orderClosedOnDay", "orderClosedOnYear"), sep = "/") %>%
  separate(orderClosedOnTime, c("orderClosedOnHour", "orderClosedOnMinute"))

# Convert data to numeric
for(i in 8:12){
  order4[,i] <- as.numeric(order4[,i])
}

for(i in 19:23){
  order4[,i] <- as.numeric(order4[,i])
}

# Create sales column
order4$sales <- order4$quantity*order4$price


# Create order5 dataset without special programs orders and weird category names
order5 <- order4 %>% 
  filter(!(categoryName =="CategoryForDeletedItems"))

# There are 4 observations with System Generated category. They are Gift Cards -> Still keep them
order5$categoryName[order5$categoryName == "System Generated"] <- "Gift Cards"
order5$menuGroupName[order5$categoryName == "Gift Cards"] <- "Gift Cards"

order5$orderDayTime <- ifelse(order5$orderCreatedOnHour < 11, "Morning",
                              ifelse(order5$orderCreatedOnHour < 15, "Afternoon",
                                     ifelse(order5$orderCreatedOnHour < 19, "Evening", "Night")))

# Create dataset with free/discounted items 
orders_free_discounted <- order5 %>% filter(quantity!=0) %>%
  group_by(orderId) %>%
  mutate(
    have_free_discounted_item = ifelse(any(categoryName %in% c("Free On House", 
                                                               "50% OFF", 
                                                               "Free Tax Item", 
                                                               "Today Special")), 1, 0)) %>%
  ungroup() %>%
  group_by(orderId) %>%
  summarise(tot_sales = sum(price*quantity),
            guestNum = mean(guestNum),
            num_items = sum(quantity),
            orderDurationInMinutes = mean(orderDurationInMinutes),
            have_free_discounted_item = first(have_free_discounted_item),
            orderCreatedOn = first(orderCreatedOn),
            orderClosedOn = first(orderClosedOn),
            orderDayTime = first(orderDayTime),
            log_tot_sales = log(tot_sales))

order5 <- order5 %>% 
  filter(!(categoryName %in% c("Free On House", "50% OFF", "Free Tax Item", "Today Special")))

# Create order5 dataset without canceled orders
order_cancel_obs <- order5[order5$quantity==0,]

order_cancel_obs %>% group_by(categoryName) %>% summarise(ct = n()) %>% arrange(desc(ct))

# Create order_cancel dataset 
order_cancel <- order5
order_cancel$canceled <- ifelse(order_cancel$quantity == 0, 1, 0)

# Calculate the cancellation rates
cancellation_rates <- with(order_cancel, tapply(canceled, categoryName, function(x) sum(x == 1) / length(x)))
top_categories <- names(sort(cancellation_rates, decreasing = TRUE)[1:10])
order_cancel <- order_cancel %>% filter(categoryName %in% top_categories)

order5 <- anti_join(order5, order_cancel_obs)

# (6) Question 1: identify items with low sales, items with most revenues, and menu optimization ----
summary(order5)
  # Mean of sales is $13.12.

# Create item_tab dataset to view metrics for each item (566 distinct items in total)
item_tab <- order5 %>% filter(price != 0) %>% 
  group_by(saleItemName) %>% 
  summarise(ct = n(), 
            mean_sales = mean(sales), 
            tot_sales = sum(sales), 
            avg_price = mean(price)) %>% 
  arrange(ct)

summary(item_tab)

count(item_tab[item_tab$ct<41,])
  # 141 items ordered less than 41 times

count(item_tab[item_tab$ct<41 & item_tab$mean_sales<11.945,])
  # 81 items ordered less than 41 times and have average sales smaller than 11.945.

# Create order6 dataset without underperformed items (485 distinct items in total)
order6 <- item_tab %>% filter(item_tab$ct>=41 | item_tab$mean_sales>=11.945) %>% arrange(desc(tot_sales))
head(order6, 10)
  # top 10 items bringing in most revenues
write.csv(order6, "Table3A.csv", row.names = F)

# Create item_categ dataset to view the category associated with each item (624 items in total)
item_categ <- order5 %>% 
  group_by(saleItemName, categoryName) %>% 
  summarize(tot_sales = sum(sales)) %>%
  ungroup() %>% arrange(desc(tot_sales))

# Create category dataset to view the total revenue of each category 
category <- order5 %>% 
  group_by(categoryName) %>% 
  summarize(ct = n(), tot_sales = sum(sales), mean_sales = mean(sales)) %>%
  arrange(desc(tot_sales))

write.csv(category, "Table4A.csv", row.names = F)

# Create order7 dataset to get the category associated with each item that not underperformed
order7 <- inner_join(order6, item_categ, by = c("saleItemName" = "saleItemName"))

# Create order8 dataset to start creating an optimized menu by cleaning order7 dataset and remove free or discounted items (490 items in total)
order8 <- order7 %>% select(-c(tot_sales.y)) %>% 
  rename(tot_sales = tot_sales.x) 

# Export data to optimize menu 
write.csv(order8, "Items for Menu.csv", row.names = F)

# (7) Question 2: analyze dining options ----
# Create order_type_tab dataset to view the distribution of order types
order_type_tab <- order5 %>% group_by(orderType) %>% 
  summarize(ct = n(), tot_sales = sum(sales)) %>% 
  arrange(desc(ct))

write.csv(order_type_tab, "Table5A.csv", row.names = F)

# Create menu_tab dataset to view the distribution of menu types
menu_tab <- order5 %>% group_by(menuGroupName) %>% 
  summarize(ct = n(), tot_sales = sum(sales), mean_sales = mean(sales)) %>% 
  arrange(desc(ct))

write.csv(menu_tab, "Table6A.csv", row.names = F)

# (8) Question 3: trend of performance ----
options(scipen = 999)

# Analyze weekday data
weekday_order <- order5 %>% mutate(orderCreatedOn = mdy_hm(orderCreatedOn)) %>%
  mutate(orderWeekDay = wday(orderCreatedOn, label = T)) %>% 
  group_by(orderWeekDay) %>% 
  summarize(ct = n(), tot_sales = sum(sales)) %>% 
  arrange(desc(tot_sales))

sales_weekday <- ggplot(weekday_order, aes(x = orderWeekDay, y = tot_sales, fill = tot_sales)) +
  geom_bar(stat = "identity") +
  labs(x = "Weekday", y = "Total Sales", title = "Total Sales Over Time") 

orders_weekday <- ggplot(weekday_order, aes(x = orderWeekDay, y = ct, fill = ct)) +
  geom_bar(stat = "identity") +
  labs(x = "Weekday", y = "Total Orders", title = "Total Orders Over Time") 

# Analyze monthly data
monthly_order <- order5 %>% group_by(orderCreatedOnMonth) %>% 
  summarize(ct = n(), tot_sales = sum(sales)) %>% 
  arrange(desc(tot_sales))

sales_month <- ggplot(monthly_order, aes(x = orderCreatedOnMonth, y = tot_sales, fill = tot_sales)) +
  geom_bar(stat = "identity") +
  labs(x = "Month", y = "Total Sales", title = "Total Sales Over Time") +
  scale_x_continuous(breaks = unique(monthly_order$orderCreatedOnMonth), labels = unique(monthly_order$orderCreatedOnMonth))

orders_month <- ggplot(monthly_order, aes(x = orderCreatedOnMonth, y = ct, fill = ct)) +
  geom_bar(stat = "identity") +
  labs(x = "Month", y = "Total Orders", title = "Total Orders Over Time") +
  scale_x_continuous(breaks = unique(monthly_order$orderCreatedOnMonth), labels = unique(monthly_order$orderCreatedOnMonth))

# Analyze daily data
daily_order <- order5 %>% group_by(orderCreatedOnDay) %>% 
  summarize(ct = n(), tot_sales = sum(sales)) %>% 
  arrange(desc(tot_sales))

sales_day <- ggplot(daily_order, aes(x = orderCreatedOnDay, y = tot_sales, fill = tot_sales)) +
  geom_bar(stat = "identity") +
  labs(x = "Day", y = "Total Sales", title = "Total Sales Over Time") +
  scale_x_continuous(breaks = unique(daily_order$orderCreatedOnDay), labels = unique(daily_order$orderCreatedOnDay))

orders_day <- ggplot(daily_order, aes(x = orderCreatedOnDay, y = ct, fill = ct)) +
  geom_bar(stat = "identity") +
  labs(x = "Day", y = "Total Orders", title = "Total Orders Over Time")  +
  scale_x_continuous(breaks = unique(daily_order$orderCreatedOnDay), labels = unique(daily_order$orderCreatedOnDay))

# Analyze hourly data
time_order <- order5 %>% group_by(orderCreatedOnHour) %>% 
  summarize(ct = n(), tot_sales = sum(sales)) %>% 
  arrange(tot_sales)

sales_hour <- ggplot(time_order, aes(x = orderCreatedOnHour, y = tot_sales, color = tot_sales)) +
  geom_line() +
  labs(x = "Hour", y = "Total Sales", title = "Total Sales Over Time") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_continuous(breaks = unique(time_order$orderCreatedOnHour), labels = unique(time_order$orderCreatedOnHour))

orders_hour <- ggplot(time_order, aes(x = orderCreatedOnHour, y = ct, color = ct)) +
  geom_line() +
  labs(x = "Hour", y = "Total Orders", title = "Total Orders Over Time") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_continuous(breaks = unique(time_order$orderCreatedOnHour), labels = unique(time_order$orderCreatedOnHour))

# (9) Model Building 1: predict time customers spend at the restaurant ----
order_tab <- order5 %>% group_by(orderId) %>%
  summarise(tot_items = sum(quantity), 
            tot_revenues = sum(sales), 
            guestNum = mean(guestNum),
            orderDuration = mean(orderDurationInMinutes),
            orderDayTime = first(orderDayTime),
            log_orderDuration = log(orderDuration)) %>%
  arrange(desc(orderDuration))

summary(order_tab$orderDuration)

qt99 <- quantile(order_tab$orderDuration, 0.99)

order_tab <- order_tab %>%
  filter(orderDuration < qt99 & orderDuration != 0 & guestNum <= 20 & guestNum != 0 & tot_items < 150 & tot_items != 0)

set.seed(100)

order_tab_trainSet <- order_tab %>% sample_frac(0.8) 

order_tab_testSet <- anti_join(order_tab, order_tab_trainSet)

ggplot(order_tab_trainSet, aes(tot_items, orderDuration) ) +
  geom_point() +
  stat_smooth()+ 
  labs(x = "Number of total items", y = "Order Duration (minutes)", title = "Scatterplot between number of total items and Number of time spent") +
  theme_minimal()

ggplot(order_tab_trainSet, aes(guestNum, orderDuration)) +
  geom_point() +
  stat_smooth()+ 
  labs(x = "Number of guests", y = "Order Duration (minutes)", title = "Scatterplot between number of guests and Number of time spent") +
  theme_minimal()

ggplot(order_tab_trainSet, aes(x=orderDuration)) +
  geom_histogram() +
  labs(x = "order Duration (minutes)", y = "Count", title = "Histogram of order duration")

# Polynomial Regression
lm.fits <- lm(log_orderDuration ~ guestNum + tot_items + I(guestNum^2) + I(tot_items^2) + orderDayTime, data = order_tab_trainSet)

summary(lm.fits)

predictions <- lm.fits %>% predict(order_tab_testSet)

rmse(exp(predictions), exp(order_tab_testSet$log_orderDuration))

# (9) Model Building 2: predict total sales with discount/special order ----
orders_free_discounted <- orders_free_discounted %>%
  filter(tot_sales!=0 & tot_sales < 600 & num_items != 0 & num_items < 130 & guestNum != 0 & guestNum <= 20)

ggplot(orders_free_discounted, aes(x=tot_sales)) +
  geom_histogram() +
  labs(x = "Total Sales", y = "Count", title = "Histogram of total sales")

ggplot(orders_free_discounted, aes(num_items, tot_sales) ) +
  geom_point() +
  stat_smooth()+ 
  labs(x = "Number of total items", y = "Total Sales", title = "Scatterplot between number of total items and total sales") +
  theme_minimal()

ggplot(orders_free_discounted, aes(guestNum, tot_sales)) +
  geom_point() +
  stat_smooth()+ 
  labs(x = "Number of guests", y = "Total Sales", title = "Scatterplot between number of guests and total sales") +
  theme_minimal()

set.seed(200)

orders_free_discounted_trainSet <- orders_free_discounted %>% sample_frac(0.8) 

orders_free_discounted_testSet <- anti_join(orders_free_discounted, orders_free_discounted_trainSet)

lm.fits2 <- lm(log_tot_sales ~ have_free_discounted_item + guestNum + num_items + orderDayTime + 
                 I(guestNum^2) + I(num_items^2), 
               data = orders_free_discounted_trainSet)

summary(lm.fits2)

predictions2 <- lm.fits2 %>% predict(orders_free_discounted_testSet)

rmse(exp(predictions2), exp(orders_free_discounted_testSet$log_tot_sales))


# (10) Model Building 3: predict order cancellation ----
set.seed(300)

order_cancel <- order_cancel %>% filter(orderType!="PICKUP")

order_cancel_trainSet <- order_cancel %>% sample_frac(0.8) 

order_cancel_testSet <- anti_join(order_cancel, order_cancel_trainSet)

table(order_cancel_trainSet$canceled)

fits <- ovun.sample(factor(canceled) ~ orderDurationInMinutes + price + orderDayTime + categoryName + orderType, 
            data = order_cancel_trainSet, method = "under", seed = 789)

undersampled_data <- fits$data

table(undersampled_data$canceled)

glm.fits <- glm(factor(canceled) ~ orderDurationInMinutes + price + orderDayTime + categoryName + orderType, 
                data = undersampled_data, 
                family = binomial)

summary(glm.fits)

exp(coef(glm.fits))

exp(coef(glm.fits))/(1+exp(coef(glm.fits)))

order_cancel_testSet$canceledProbs <- predict(glm.fits, newdata = order_cancel_testSet, type = "response")

order_cancel_testSet$canceledPreds <- ifelse(order_cancel_testSet$canceledProbs >= 0.5, 1, 0)

table(order_cancel_testSet$canceled, order_cancel_testSet$canceledPreds)

order_cancel_testSet$canceledPreds <- ifelse(order_cancel_testSet$canceledProbs >= 0.8, 1, 0)

table(order_cancel_testSet$canceled, order_cancel_testSet$canceledPreds)
