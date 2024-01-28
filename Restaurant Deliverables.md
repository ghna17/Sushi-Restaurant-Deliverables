# Restaurant Deliverables
## Phase 1: Discovery
In this group project we have been given the order history for a California-based Japanese restaurant whose data includes 344,465 ordered menu items from over 40,000 placed orders throughout two years 2016 and 2017. Our data team has been tasked with the challenge of figuring out ways to optimize the restaurant's business practices increasing the revenue and profitability? Given this we have come up with 3 supporting questions that we must ask to help us during the data wrangling process.

The initial questions were as follows: 
- IQ1: Are there menu items with low sales that could be replaced or improved? Which menu items are bringing in the most revenue? How would you suggest optimizing the menus?
- IQ2: How does business performance vary by time of day, day of the week, or season? Can you identify peak hours and slow periods to optimize staffing and inventory management?
- IQ3: How do dining options differentiate in revenue produced and resources allocated? 

The data necessary for the project was divided into two categories. The first is data that represents the qualitative aspects of the company’s menu data. This data includes things such as the order type (this includes options such as “Dine in”, “Delivery”, “Pick up”, or “To Go” items), the menu group name (whether the item is part of the “Lunch” menu, “All-Day” menu, “Dinner” menu etc.), the category name (things such as “Appetizers”, “Live Seafood” etc.) and the specific name for the sale item. This would allow us to organize the data to not only see what items are most popular but also help us hypothesize times during te day or the year in which an item is most popular. 

The second category of data included the quantitative information specifically regarding the sale item. The quantitative values given include the item price and its quantity being ordered. Using these two pieces of data will allow us to see the total sales and revenue of each item, thus permitting us to structure the data to find the most popular items on the menu. Moreover, there are also order duration values, which can be used to predict the time for one order based on the number of items and number of guests.

During the project there are a few things that we expect to find and identify to deem the data wrangling process as a success. Vice versa, there are also a few criteria that would deem the data wrangling process a failure, as it pertains to optimizing the available menu items to increase revenue. The criteria are provided below:
- **Success criteria**: 
  - Identification of popular menu items and underperformed ordered menu items 
  - An increase in daily revenue 
  - Decrease in losses related to order cancellation 
  - Determining the revenue gained from each dining options 
- **Failure criteria**:  
  - Not being able to answer our research questions that are designed to provide insights on how to improve the business
  - Decrease in daily revenue 
  - Misidentifying popular menu items and not increasing revenue

Given these criteria and the data we plan to accumulate, we developed 3 initial hypotheses.
- **Hypothesis 1 ($$H_1$$)**:
$$H_0$$: Orders with promoted/discounted items do not significantly impact total sales.
$$H_A$$: Orders with promoted/discounted items significantly impact total sales.
- **Hypothesis 2 ($$H_2$$)**:
$$H_0$$: Identifying peak hours has no effect on inventory management, operational costs, or revenue.
$$H_A$$: Identifying peak hours optimizes inventory management, reducing costs and increasing revenue.
- **Hypothesis 3 ($$H_3$$)**:
$$H_0$$: Historical data cannot predict order cancellations or mitigate their impact.
$$H_A$$: A predictive model using historical data can estimate order cancellation probability and mitigate their impact.

## Phase 2: Data Preparation
After scanning each variable in the original dataset, we recognize that there are strange values in some of the variables that we treat as missing values or special values for further analysis. The bullet points listed below are steps taken in order if there are any. Therefore, the unique values of each variable will also depend on the step before that.
- In the name of sale items, there are three values that we treated them as missing values: "#NAME?", "==================", and "DON'T MAKE ALL THE ORDER". There are 321 observations in total, and we remove them. 
- In the quantity variable, there are 7,672 observations have 0 quantity of the items sold. These are the items that got cancelled so we will create a variable called “Canceled” and have it equal to 1 for these 7,672 observations.
- With the menu hours variable, there are 26 missing values coded as “NULL”, and they are associated with items under Open Food menu. Therefore, we replaced them with “Open Food”.
- In the variable indicating the time the order was closed, there are also missing values coded as “NULL”. Since we want to analyze the time the orders completed, we removed those 4,342 observations.
- In the order duration variable, there are no missing values but strange observations with 0 values. We think that these 2,997 observations were not carefully tracked or data entry error. Since there are still valuable insights such as sales of order, item names, and information related to the items, we decided to keep these observations.
- In the table ID variable, there are 15,161 missing values coded as “NULL”. We found out that these observations are mostly associated with the type of orders being To-Go, Online Pick-up, and Pick-up. Therefore, we keep them in our analysis dataset.
- In the category name of the items, there are some suspicious names such as “CategoryForDeletedItems", "System Generated", and "Kitchen Order". 
  - We decided to remove 10,591 observations categorized as “CategoryForDeletedItems". 
  - There are 4 observations categorized as "System Generated", and they have the sale item’s name as “Gift Card” so we will keep them and change the category name to “Gift Cards”. 
  - There are 4,126 orders categorized as "Kitchen Order", and we think that they are meals ordered from the employees. Therefore, we still keep them as these orders also used the resources in the inventory.
- We created two more columns called “sales” and “orderTime”. “sales” column is the total sales generated by an item of an order. “orderDayTime” column stores values as “Morning” (before 11 AM), “Afternoon” (from 11 AM to 15 PM), “Evening” (from 15 PM to 19 PM), and “Night” (after 19 PM).
- We then found that some values can be used to analyze how well special offers and discount programs perform in the restaurant by using 20,023 observations with category names being "Free On House", "50% OFF", "Free Tax Item", and "Today Special".

After wrangling the data, the dataset is left with 304,204 observations. As this dataset has date and time variables, we extract single pieces of data such as months, days, years, hours, and minutes from the two variables indicating the time the order started and ended. According to Table 1A, there is an outlier for the order duration with value being 10,276 minutes, which is about 171 hours for an order. Even though it is an outlier, we haven’t removed it yet as the values for other variables look normal. 

**Question 1: Are there menu items with low sales that could be replaced or improved? Which menu items are bringing in the most revenue? How would you suggest optimizing the menus?**
We first removed observations with price being 0 for this question because they don’t bring in any revenue to analyze. By grouping the sale item names, we created a table calculating the number of orders, the average revenues, and the total revenues of each item. According to Table 2A, we used 41, the first quartile value of the number of orders in the current dataset, as a benchmark to identify 141 underperformed items with the number of orders less than that. In those 141 items, there are 81 items that have average sale less than $11.945, which is the median sale of each item. Those items are often categorized as combination choice, side order, or drinks and wine. We decided to remove them to start the menu optimization process.

Removing those items leaves us with a table of 485 items that are qualified, and Table 3A shows the top 10 items bringing in the most revenue. The Lunch Combo (2) is a successful item in this restaurant with the largest total revenue (~ $300 thousand), and we found that the revenue is driven by the count of orders with the decent average sale price ( $15 per combo). There are five items classified as Icho Signature Plate, Seafood, and Sashimi producing revenue ranging from $100 thousand to $200 thousand, and most of them have the high sale prices except for the Dinner Combo (2), with only $17 per combo but with the second highest number of orders. The last 4 items in this top 10 with slightly higher prices than the two Combos and seem to be the favorite items for the customers who are willing to pay to eat these at this restaurant. Together, these 10 items over 524 distinct items make up about a quarter of the total revenues the business gained during those two years. 

Next, we group the data by the food category. There are 32 distinct categories, and the top 10 food categories bringing in most revenues are displayed in Table 4A. Icho Signature Plate doesn’t have the highest number of orders but a relatively high sale price ($40.94), which makes it become the top 1 category in total revenues. The business is good at diversifying their menu items and gains the sales from most of them with the right prices. The average sale price of Combination/L and Combination/D category in this case is relatively small so it doesn’t serve a meaningful purpose as it combines a lot of different items with a wide range of prices.

**Question 2: How does business performance vary by time of day, day of the week, or season? Can you identify peak hours and slow periods to optimize staffing and inventory management?**
With the data exploration in Question 1, we know that Lunch Combo has the greatest number of orders, so we predicted having the peak hours during lunch. However, Figure 1 suggests the opposite thing, as dinner time from 6:00 PM to 8:00 PM is the peak hour. Lunch time from 12:00 PM to 1:00 PM is then the second peak. Our hypothesis is that the All-day menu contributes a significant amount to dinner time. The restaurant runs from around 10 AM to 11 PM.
 
> ![https://drive.google.com/file/d/1Ek-wQguFtogVvWU-ofPl7jlJ7PyF4V3X/view?usp=drive_link]
> Figure 1. Hourly Trend of Total Sales

Streamlining the number of orders and total sales helps us to understand that Saturday is the busiest day, with 54.5 thousand orders and $716 thousand in sales. The trend in sales and number of orders are consistent on the other days, and the numbers they can generate are not too bad. However, as Monday has the lowest sales and number of orders, the business may want to cut down on staff, inventory, and hours so they can spend on other sides of the business.

> ![https://drive.google.com/file/d/1m9-jvXR7eaq9kZcOiPZwf0atJG_hQVI7/view?usp=drive_link]
> Figure 2. Total Orders throughout Weekdays

> ![https://drive.google.com/file/d/1tuCBzc_BU-ug-DM0tVJ39kYi4W1YQESY/view?usp=drive_link]
> Figure 3. Total Sales throughout Weekdays
	
Visualizing the data within days of a month, customers regularly came to the restaurant throughout the beginning to the middle of the month. However, there is a decreasing trend in both the number of orders and sales starting from 22 to 28, then it quickly increases back to when it starts to drop at the end of the month. Day 31 underrepresents the data as not every month has 31 days, so definitely there is a drop.
 
> ![https://drive.google.com/file/d/1sGWpl2morw8cInUbQifWAQABkB_uO33g/view?usp=drive_link]
> Figure 4. Daily Total Order

 > ![https://drive.google.com/file/d/1EfJrbzjTazdV8a8uiFb4o7WliMfr0i-r/view?usp=drive_link]
> Figure 5. Daily Total Sales

The trend in monthly data is the most interesting piece of data analysis as there are some contradictions. The numbers of orders continuously increase from 19.9 thousand orders in January to 29.8 thousand orders in July, then there is a sudden decrease to 24.5 thousand orders in August. The same thing happens to the revenues of the business. We suggested that the reason is after the summer, it is the back-to-school time, so people don’t keep up with the habit of eating out as much as usual. However, the number of sales and orders recovers and remains mostly higher than the data in August. Even though July has the highest number of orders, the generated revenue of $381 thousand from those orders is not as great as in December, which is $402 thousand. The customers seem to be more willing to pay for food with higher prices at the end of the year.
 
> ![https://drive.google.com/file/d/1j-LnMGR_j-f4qhsUB8pVWfPJSXIYNURv/view?usp=drive_link]
> Figure 6. Monthly Total Orders
 
> ![https://drive.google.com/file/d/1Rgil3gy6Sq2_mpDjdDC9g-KcqPOc8NDd/view?usp=drive_link]
> Figure 7. Monthly Total Sales

**Question 3: How do dining options differentiate in revenue produced and resources allocated?**
In terms of type of orders in this restaurant, there are a total of 6 types: Dine-in, To-go, Online Pick-up, Pick-up, Delivery, and Gift Card. Pick-up order is the type that we are not so sure since it can be whether customers came into the restaurant, order, and pick up, or they called the restaurant to order and pick up later. We will stick with the latter interpretation. We grouped the order type and created the total revenue for each type. From Table 5A, Dine-in option generates the highest revenue ($3.7 million), while delivery generates the lowest ($178). Regarding our suggestion, based on the data, the business should continue to focus on Dine-in and To-go dining options. However, if they also want to increase the sales through delivery channels as the delivery apps are more well-known, they can promote their restaurant through different promotions and with our new optimized menu to give the online customers in the app a quick look at what the popular items are.

We also analyzed the data by grouping it into 5 different menu options: All Day, Lunch, Dinner, Open Food, and Gift Cards. As mentioned above, business performance peaks at dinner time, but Dinner menu creates the least total revenue (around $313.8 thousand) and number of orders (51,802) among the common three menu options according to Table 6A. On the other hand, All Day menu produces $3.2 million in revenue along with a high number of orders. This is good because the average revenue it can create is greatly high, and this also answers why dinner time is the peak hour. As the Open Food menu has the second highest average sale of $76 after Gift cards but only 20 orders for two years, the business may want to advertise it more to earn higher revenues in the future.

## Phase 3: Model Planning
**Model Planning Question 1: How can you predict the duration to complete each order (or meal)? What are the business implications?**
Predicting order duration can be done by taking a specific order (or meal) and gathering the duration it takes to complete that slip for all the times it has been ordered by a customer. We add those times, and then get the average time by dividing it by the number of times it has been ordered. (total duration in minutes/number of times ordered). We can then use that and find the average time it takes before an order is cancelled and compare. This directly piggybacks from the previous question, where we are trying to find the rate of cancellation. The business implications that come with order cancellations are removing items that are frequently cancelled if they are not being ordered much to begin with. Another would be improving customer service and experience to prevent order cancellations, addressing common reasons for cancellations. Lastly, resource allocation is a big business implication, predicting which items will be cancelled the most and allocating based on that probability. 
> log⁡(orderDuration)=$$β_0$$+$$β_1$$ guestNum+$$β_2$$ tot_items+$$β_3$$$$guestNum^2$$+$$β_4$$ tot_$$items^2$$+$$β_5$$orderDayTime

**Model Planning Question 2: How would discounts in menu pricing impact sales and order frequency? Are there specific menu items that benefit more from these promotions?**
To answer this question, we would design a model that compares the sales, order frequency, and revenue from menu items that have been both promotional items and regular menu items. By doing this, we can see if an item is statistically more profitable for the store when on promotion. Our model would then provide insight into when an item is no longer more profitable as a promotional item. This ongoing ability will help decision makers know when to make an item a cheaper or promoted one. This model should also be able to provide insight into similar items and how they could behave during a promotional event. Once a trail is perused, the model could statistically determine if it was successful. This model will be successful in optimizing the menu and generating higher revenue for applicable menu items.
> log⁡(tot_sales)= $$β_0$$+$$β_1$$ have_free_discounted_item+$$β_2$$ tot_items+$$β_3$$ guestNum+$$β_4$$tot_$$items^2$$+$$β_5$$ $$guestNum^2$$+$$β_6$$orderDayTime

**Model Planning Question 3: What is the rate of order cancellation? Can you build a model to predict the probability of an order being canceled by the customers? What are the business implications?**
To predict the rate of order cancellation, we classify each item to see if the item is cancelled or not and run a logistic regression. Our goal would be to determine which food categories have a higher rate of cancelation. We can determine if an order is canceled more than other orders, but that would not provide significant business insight. For example, if a popular order has lots of cancelations, that does not necessarily mean that the order is proportionally canceled more than less popular dishes. To benefit the restaurant, we will compare total cancelations with total orders. Through this process, we will be able to determine if certain dishes are proportionately canceled more than others. With those cancelled orders, we can either take that item off the menu entirely, create confirmation calls, because these orders are typically call-in and pick-up. These calls will ensure the restaurant gets the payment and will not refund customers if they cancel at the last minute. 
> logit(canceled)= $$β_0$$+$$β_1$$ orderDurationInMinutes+$$β_2$$ price+$$β_3$$ orderDayTime+ $$β_4 categoryName$$+$$β_5$$ orderType

## Phase 4: Model Building
**Model 1: Predict time spent based on number of guests and number of total items**
We begin modelling for this question by grouping the data by the order IDs and getting the related information such as total items of each order, total revenues, total guest number, and then the order duration. We discovered that there are a lot of outliers in this data frame that have a total duration ranging from 350 to 10,276 minutes, which is more than 6 hours or even in many days. Therefore, with the mean of order duration being 50 minutes, and the 99th quartile being 313 minutes, we decided to remove orders lasting more than 313 minutes for the purpose of training a good model. 

We then visualize the scatterplots of the order duration with two variables we use in the model: the total items and guest number of the order in Figures 8A and 9A, respectively. Both figures show that the relationships between each variable and the order duration are non-linear according to the blue lines, the best fit line, with a lot of variations (or noises) around the bottom-left corner of the graphs. In general, there are positive correlations between the total items and the two variables of interest, meaning that the higher the number of items or the number of guests, the longer the order will be. We specify the log-linear relationship in this case because the order duration is right-skewed according to Figure 10A. Therefore, our regression model is as follows:
> log⁡(orderDuration)=$$β_0$$+$$β_1$$ guestNum+$$β_2$$ tot_items+$$β_3$$$$guestNum^2$$+$$β_4$$ tot_$$items^2$$+$$β_5$$orderDayTime

We run this regression model on the training set containing 80% of the observations, and test the model on the testing set, the remaining 20% observations.

**Model 2: How does the presence of at least one free or discounted item in an order and other factors impact the total sales?**
We set up the data frame with the unit being an order by grouping the data by the order IDs and getting the related data such as the total sales, guest numbers, number of items, order duration in minutes, and order created and closed time. We then created a column telling whether there is any free or discounted item in each order under the categories "Free On House", "50% OFF", "Free Tax Item", and "Today Special". Based on Figures 11A and 12A, there is a positive relationship between total sales and number of total items of an order and number of guests. However, as the number of guests or number of items increases more and more, there is a decrease in the sales increase. Therefore, we included their squared terms. We transformed the total sales into the log of total sales as the data is right skewed according to Figure 13A. The final model we came up with to answer the question is:
> log⁡(tot_sales)= $$β_0$$+$$β_1$$ have_free_discounted_item+$$β_2$$ tot_items+$$β_3$$ guestNum+$$β_4$$tot_$$items^2$$+$$β_5$$ $$guestNum^2$$+$$β_6$$orderDayTime

The regression model predicts the total sales of one order by whether the order has at least one free or discounted item or not, the total number of items purchased in the order, and the number of guests. The coefficients represent the estimated impact of each independent variable on the total sales. To verify the model’s prediction success rate, we will run this regression model on the training set (80% of the original data) and use this model to predict the test set (the remaining 20% observations).

**Model 3: Predict the order item’s cancellation rate**
The motivation to build a model predicting an order item’s cancellation rate is from our goal to optimize the menu and inventory management using this restaurant’s data. Even though the number of items cancelled throughout the time is small (only 1.6%), we still want to avoid the case of cancellation. We are curious about whether the time during the day the customers put an order also likely impact the chance of cancellation, so we included variable “orderDayTime”. 
Since there are around 30 categories, we filter the data with the top 10 categories that have the highest cancellation rates. The cancellation rate of each category is calculated by using the number of times the items belonging to that category were cancelled divided by the number of times the items belonging to that category were ordered. The top 10 categories are "Open Food", "Live Seafood", "Sashimi”,  "Kitchen Order", "Shabu Side Order", "Wine", "Sushi", "Soup & Hot Pot", "Single Dish”, "Hand Roll". Then, we splitted the data into training (80%) and testing (20%) sets and check the distribution of “canceled” in the training set.

> | Item got canceled | Item didn’t get canceled |
> | ------ | ------ |
> | 2,079 | 57,510 |
> Table 1. Distribution of "Canceled" variable of the original training set

Therefore, we performed an under-sampling method to balance the distribution in order to create a model with better fit. After under-sampling the training set, the new distribution of “canceled” is:
> | Item got canceled | Item didn’t get canceled |
> | ------ | ------ |
> | 2,079 | 2,081 |
> Table 2. Distribution of "Canceled" variable after under-sampling

With this, our logistic regression is as below:
> logit(canceled)= $$β_0$$+$$β_1$$ orderDurationInMinutes+$$β_2$$ price+$$β_3$$ orderDayTime+ $$β_4 categoryName$$+$$β_5$$ orderType

From this equation, we aim to predict the likelihood of an order item being canceled through the binary variable “canceled” indicating 1 if the item is cancelled and 0 otherwise based on order duration, price of the item, order daytime, category names, and order types. The coefficients (β) indicate the log odds of an order being canceled regarding included predictors. 
## Phase 5: Result Communication
**Model 1: Predict time spent based on number of guests and number of total items**
After running the log-linear regression model on the training set to predict the order duration based on the predictors like number of guests, number of items, etc., Table 3 shows the significant regression output of the model at 1% significance level. From Table 3, one more guest is associated with an increase of 20.5% in the order duration time. However, a weak diminishing effect starts at the turning point of above 9 guests, which means that for orders already have above 9 guests, one more guest is likely to result in a decrease in order duration. One more item is associated with an increase of 2.3% in the order duration time. However, a weak diminishing effect starts at the turning point of above 71 items. Compared to the afternoon, orders in the morning are associated with a 36.5% increase in the time spent. Similarly, evening and night orders are associated with increases of 14.5% and 11.9%, respectively. From this, the restaurant should pay more attention to what factors have cost the morning orders more time compared to other time throughout the day.

> ![https://drive.google.com/file/d/1_3A95gm4KuG256uIkPi12nQDx0OR0ZbX/view?usp=drive_link]
> Table 3. Model 1's Regression Output

The model has an R-squared value of 28.09%, which means that the model can explain 28.09% of the Order Duration. While this indicates that the model’s predicted power is not too low, more factors should be examined to be included in the model. When we use the model to predict the order duration of the testing set combining the unseen data, we calculated the Root Mean Squared Error (RMSE) to assess the accuracy of the model. Since RMSE value is the average difference between the predicted values and actual values, we can estimate how well our model performs. RMSE value in this model is 41.66 minutes, which is less than the mean of order duration in minutes of the test set (65.4 minutes). Therefore, the model predicts data quite well. As the mean value is not the only and most precise benchmark, we plan to conduct more comparisons with other metrics to gain more insights for a more careful assessment. 

In the world of restaurants, the efficiency of staff is an important to determine business success. Every moment, from food preparation to serving, creates a delicate symphony impacting the overall dining experience. The implications of accurately assessing the time spent catering to a specific number of guests can't be overstated. The addition of even a single guest can trigger a considerable 21% surge in the order duration, a statistic with nuanced fluctuations contingent upon the time of day or the restaurant's bustling activity levels. This rise in order duration isn't merely a statistical variation; it's a pivotal factor relating with customer satisfaction. As the clock ticks longer for each order, the potential for customer dissatisfaction escalates. A longer wait time could impact customer satisfaction with even the most exquisite culinary offerings. In an era where every review holds weight in shaping business reputation, customer satisfaction becomes the highest priority. Negative feedback resulting from longer wait times can spread across various platforms, impacting stakeholders and harming the restaurant's standing in the industry.

Balancing the scales of timely service without compromising on quality becomes a crucial pursuit for restaurants seeking to safeguard their reputation, appease stakeholders, and foster a loyal customer base. Consequently, this challenge isn't just about managing time but about creating an experience where culinary excellence converges seamlessly with prompt, attentive service, ultimately representing the reputation and prosperity of the restaurant.

**Model 2: How does the presence of at least one free or discounted item in an order and other factors impact the total sales?**
By setting up the potential predictors and running the regression on the training data set, we gain the regression model’s outputs as in Table 4. All of the coefficients except the coefficient for Morning orders compared to Afternoon orders are significant at 1% level. From Table 4, we notice that an order that has at least 1 free/discounted item is associated with an increase of 8% in the total sales compared to an order that doesn't have free/discounted items. One more guest or one more item is also associated with an increase in the total sales; however, there are still diminishing effects in which the total sales start to decline. Specifically, the turning point for the number of items in this model will be above 67 items, while the turning point for the number of guests will be above 11 guests. Compared to the afternoon, orders in the morning are associated with a 20.1% significant increase in the total sales at 5% significance level. Similarly, evening and night orders are associated with increases of 7.7% and 11.4%, respectively. 

> ![https://drive.google.com/file/d/1_3Sr6KJdkJ5GbL6DkYKv5WERAFcev594/view?usp=drive_link]
> Table 4. Model 2's Regression Output

This model produces a relatively high R-squared value of 72.48%, which means that the model is able to explain 72.48% of the total sales. We also use RMSE value to assess the model after predicting the testing data with this model. RMSE in this case is $52.08, which is much smaller than the mean of the total sales of the testing set ($91.63). Therefore, we conclude that the model predicted the unseen data well.

Almost a 20% increase in sales when orders have at least one discounted or free item means that promoted items encourage customers to make purchases they may not have made otherwise. These free or discounted items are also used to attract new customers and to keep existing ones with fresh ideas and combinations of meals. A loyalty program can even be implemented for those who have supported the business for a certain amount of time. A complimentary soup, salad, or appetizer for existing and loyal customers is a great idea for marketing and to keep a consistent consumer base. This can also help the business clear inventory; instead of throwing away food items that would not be used before becoming rotten or spoiled, the restaurant can give them away for free and leave a good impression on customers. One of the business implications that needs to be assessed carefully is the items that are being chosen to be discounted. Some items have more success than others at certain times of the day, and some can also be pricier than others. The business needs to take care of this matter very carefully, because discounting items that are usually priced heavier can erode profitability. Another possibility that could affect the business negatively is the excess use of discounts; if others see the restaurant abusing discounts, they might think the ingredients and food are cheap, and that can devalue the brand. 

**Model 3: Predict the order item’s cancellation rate**
With the logistic regression model specification, the original coefficients are the log odds of the item that got cancelled based on the predictors we mentioned in Phases 3 and 4. For easier interpretation, we converted the log odds to their corresponding odds and probability of item cancellation. Table 5 recorded the coefficients of the model in 3 different formats with most of the coefficients being significant at 1% level. The most interesting and highly significant result gained from this model is that morning orders have a higher probability of 0.859 percentage points of cancellation compared to afternoon orders. For a one-dollar increase in the item's price or one-minute increase in the order's duration, the expected increase in probability of item getting cancelled is 0.5 percentage points. Compared to Hand Roll, Sashimi and Shabu Side Order categories are associated with higher increases in the probability of cancellation of  0.63 and 0.68 percentage points, respectively. For other 6 food types, the results are not significant so we didn’t have their coefficients written in the Table. 
 
> ![https://drive.google.com/file/d/17TSo4-zd8faooC3GhGuXcOahk8TVWt0R/view?usp=drive_link]
> Table 5. Model 3's Regression Output

Since this is not a linear regression like the other two models, the assessment method is different. We first predicted the probability of getting cancelled of each item in the testing set with the built model and classify whether an item will get cancelled or not with a threshold of 0.5 or 50%. From this, the confusion matrix is illustrated in Table 6.

> ![https://drive.google.com/file/d/1qn6WScC3YU1HOVkd8BlZWdd5I3GIj7v8/view?usp=drive_link]
> Table 6. Confusion Matrix of "Cancelled" variable when using 0.5 as a threshold 

The following three metrics are used to assess the accuracy of this logistic regression model: Accuracy, True Positive Rate (TPR), and False Positive Rate (FPR). From the confusion matrix in Table 6, the Accuracy value is 76.9%, which means that out of 14,897 items, the model predicts almost 80% of those correctly. Meanwhile, the TPR value of 37.7% suggests the hit rate by answering how many percents of items are correctly predicted to be cancelled out of the items are, in fact, cancelled. The FPR value is calculated to be 21.28%, which is the opposite to the TPR. It answers the question how many percents of items are misclassified as cancelled when actually they are not cancelled. We then explored the values of these three metrics with a threshold of 0.8 to decide on which threshold is the best option. Table 7 displays the confusion matrix in that case.

> ![https://drive.google.com/file/d/1wK8w189vWpvF-4vZO4JXNAt5h2yC2212/view?usp=drive_link]
> Table 7. Confusion Matrix of "Cancelled" variable when using 0.8 as a threshold 

From Table 7, we calculated the values for three metrics and got the Accuracy value to be 96.48%, TPR to be 16.98%, and FPR to be only 0.89%. When increasing the threshold value, the accuracy value increases significantly to almost 100%, while TPR and FPR values decrease significantly. This indicates that the model generally predicts better than when we use 0.5 as a threshold based on the Accuracy value and FPR value, but when it comes to predicting the cancelled items among the actual cancelled items, the model doesn’t perform as well as the other model. Therefore, more communication between our team and business owner as well as stakeholders are required to select the most suitable metric and try to optimize it through threshold selection. However, given one of our success criteria stating that there should be a decrease in losses related to order cancellation after our models, we will prioritize the TPR value as it helps indicate the hit rate. Therefore, 0.5 threshold would be chosen in our pilot program discussed in phase 6.

An analysis of order cancellation can help the restaurant better understand and address any issue and dissatisfaction its customers have. When high, cancellation rates can indicate that customers are not satisfied with the service that they are receiving. Analysis of cancelation rates may yield that certain meals are canceled more than others. Additional analysis can determine if there is a statistic that predicts a higher cancellation rate. The restaurant can then work to limit that statistic. For example, the restaurant now knows that an increase in price and order duration is correlated with higher cancellation rates. In addition, the restaurant should consider that morning orders have a 0.859 percentage points higher probability of being cancelled when compared to the afternoon orders. On solution is to work to limit order duration by optimizing efficiency in the kitchen and tailoring a morning menu with faster meals.

## Phase 6: Operationalization
After creating multiple regressions models to predict order duration, discounted items’ impact on total sales and order cancellation rate, we are able to provide great insights in order for the Japanese Restaurant to optimize its business operations to increase revenue and profit. Key findings from this project include these:
- One more guest is associated with an increase of 20.5% in the order duration time. 
- For orders that already have above 9 guests, one more guest is likely to result in a decrease in order duration.
- Compared to the afternoon, orders in the morning are associated with a 36.5% increase in the time spent, evening orders have a 14.5% increase in time spent and night orders are associated with an increase of 11.9%
- An order that has at least 1 free/discounted item is associated with an increase of 8% in the total sales compared to an order that doesn't have free/discounted items.
- For a one-dollar increase in the item's price or one-minute increase in the order's duration, the expected increase in probability of item getting cancelled is 0.5 percentage points.

This project informed the restaurant owners of peak hours during the day in which total sales are maximized, popular discounted and full priced menu items, optimal guest numbers for productivity in order durations and projected rates of cancellation based on food pricing and order duration. In addition to these things, it allowed our group to provide the following recommendations to the company:
- Implement restaurant management software for tasks such as inventory management, table reservations, order taking, and billing to increase staff efficiency.
- Setting limits to the number of guests in a party to ensure efficiency in order duration.
- Discounting/combo-ing menu items whose total sales are significantly below the average.
- Doing discount of the day promotions on non-expensive items to incentivize customers.
- Optimizing inventory management and morning menu items to allow for only the most popular menu items to be served in the morning.

It is suggested that the restaurant starts by implementing these recommendations initially for 1 year and preferably with one restaurant location first in order to see the results of these recommendations on a controlled scale. After implementing these recommendations on a smaller scale, theoretically the restaurant should see increases in revenue and efficiency. Results that would deem this pilot project as a failure would include a decrease in daily revenue, an increase in order cancellations, and the cost of business operations increasing. However, moving forward we would provide any needed clarification in our models and recommendations and re-analyze our models with the latest data found in our pilot program assuming its results coincided with our failure criteria. If the pilot program yields successful results, we would then actualize our recommendations previously given on a greater scale progressively and continue to analyze the new data to find ways to keep increasing revenue, customer satisfaction and business operations. 
