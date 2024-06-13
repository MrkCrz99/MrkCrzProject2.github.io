# MrkCrzProject2.github.io

Title: Credit Card Rewards Analysis

Introduction:
In this comprehensive data analysis project, I explored credit card transaction data to uncover valuable insights into rewards earned by individuals. Through the use of SQL queries and Power BI visualizations, my goal was to showcase not only my analytical skills but also my ability to derive actionable insights from complex datasets.

Notice: To simplify data processing, spending requirements across credit cards were condensed into three main categories. Additionally, varying percentage rates within the same category were averaged, assuming a uniform dollar-to-points conversion rate for all reward points.

Project Overview:
This project involved an in-depth analysis of credit card transaction data stored within a SQL Server database. Through SQL queries, I performed data aggregation, filtering, and calculations to compute crucial metrics such as total rewards earned by individuals based on their transaction history and specific credit card rewards program parameters.

Key Findings:
Total Rewards Calculation: I calculated the average total rewards earned per credit card, considering both cashback rewards and promotional bonuses based on transaction volumes and credit card rewards program specifications. Power BI visualizations presented these insights in an interactive and intuitive manner, enabling stakeholders to explore and comprehend the data effectively.
Spending Patterns: Visualization of transaction amounts by category revealed travel as the leading spending category, shedding light on consumer spending behavior. Moreover, visualizations depicting total cashback rewards earned by category and credit card facilitated informed decision-making, empowering individuals to optimize rewards based on their spending patterns.

Challenges:
Query Optimization: One of the main challenges faced was optimizing SQL queries for performance, especially when dealing with large datasets. This involved refining query logic and indexing strategies to improve query execution times.
Integration with Power BI: Integrating SQL queries with Power BI required a solid understanding of both tools and how they interacted with each other. This involved overcoming compatibility issues and ensuring seamless data flow between SQL Server and Power BI.

SQL Queries:
1. Data Exploration and Schema Understanding:
I examined the structure of the Credit_card_rewards and Credit_card_transaction_flow tables to understand their attributes and relationships.
2. Initial Data Exploration:
I explored distinct categories present in the Credit_card_transaction_flow table to understand the nature of transactions.
3. Data Transformation:
I introduced a new column Category2 in the Credit_card_transaction_flow table to standardize categories for better analysis.
4. Data Transformation and Aggregation:
I created a new table Individual_Transactions_By_Category_Month to aggregate transaction data by individuals, categories, and months.
5. Data Analysis:
I analyzed individual transaction data to understand the spending patterns of specific individuals like 'Aaron Armstrong' and 'Heather Jones'.
6.Data Analysis and Reward Calculation:
I calculated total rewards earned by individuals based on their transaction amounts and credit card reward programs, considering both promo rewards and cashback rewards.
7. Data Analysis and Reward Calculation by Category:
I extended the previous analysis to calculate rewards earned by individuals for each category separately, providing insights into which categories contribute more to their rewards.
8. Top Credit Cards Analysis:
I identified the top two credit cards with the highest total rewards earned by each individual, considering both promo rewards and cashback rewards.
9. Top Credit Cards Analysis by Category:
I further analyzed the top two credit cards with the highest total rewards earned by each individual, considering rewards earned separately for each category.

These steps represent a comprehensive process of data exploration, transformation, analysis, and visualization, providing valuable insights into individual spending behaviors and credit card reward effectiveness.

Cool Techniques:
Dynamic Conditional Logic: Using CASE statements in SQL queries allowed for dynamic conditional logic, enabling calculations based on various criteria such as transaction amounts, deadlines, and reward program rules.
Interactive Dashboards: Power BI's visualization capabilities facilitated the creation of interactive dashboards that provided a holistic view of the data, allowing stakeholders to drill down into specific metrics and uncover actionable insights.

Future Considerations:
Enriching Analysis: For further research, I would explore additional data sources to enrich the analysis further. For example, integrating demographic data or external economic indicators could provide deeper insights into consumer behavior and spending patterns.
Advanced Analytics: Implementing advanced analytics techniques such as predictive modeling or machine learning algorithms could unlock predictive insights, enabling proactive decision-making and personalized customer experiences.

Conclusion:
This data analysis project provided valuable insights into credit card transaction data, showcasing my ability to extract meaningful insights and present them in a visually compelling manner. By leveraging SQL queries and Power BI visualizations, I demonstrated proficiency in data analysis and visualization, making this project a valuable addition to my resume portfolio.

Sources
Comprehensive Credit Card Transactions Dataset (https://www.kaggle.com/datasets/rajatsurana979/comprehensive-credit-card-transactions-dataset?select=credit_card_transaction_flow.csv)

All credit card data was individually collected from the following sites:
US News (https://money.usnews.com/credit-cards/rewards)
Forbes (https://www.forbes.com/advisor/credit-cards/best/rewards/)
