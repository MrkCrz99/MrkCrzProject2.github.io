-- Select all records from the Credit_card_rewards table for an overview of rewards data
SELECT *
FROM Project1..Credit_card_rewards;

-- Select all records from the Credit_card_transaction_flow table to analyze transaction flow data
SELECT * 
FROM Project1..Credit_card_transaction_flow;

-- Select distinct categories from the Credit_card_transaction_flow table to identify unique transaction categories
SELECT DISTINCT Category 
FROM Project1..Credit_card_transaction_flow;

-- Select the name, transaction amount, and new category field (Category2) for transactions by 'Heather Jones'
-- This provides a grouped summary of Heather Jones' transactions by category
SELECT Name, Transaction_Amount, Category2
FROM Project1..Credit_card_transaction_flow
WHERE Name = 'Heather' AND Surname = 'Jones'
GROUP BY Name, Transaction_Amount, Category2;

-- Add a new column 'Category2' to the Credit_card_transaction_flow table to categorize transactions
ALTER TABLE Project1..Credit_card_transaction_flow
ADD Category2 VARCHAR(50);

-- Update the new Category2 column based on the original Category values for simplified categorization
UPDATE Project1..Credit_card_transaction_flow
SET Category2 = 
    CASE 
        WHEN Category = 'Market' THEN 'Dining_and_groceries'
        WHEN Category = 'Clothing' OR Category = 'Electronics' OR Category = 'Cosmetic' THEN 'Other'
        WHEN Category = 'Restaurant' THEN 'Dining_and_groceries'
        ELSE Category -- Leave unchanged for Travel
    END;

-- Create a new table to store individual transaction summaries by category and month
CREATE TABLE Project1..Individual_Transactions_By_Category_Month (
    Name VARCHAR(100),
    Surname VARCHAR(100),
    Category VARCHAR(100),
    Transaction_Month INT,
    Total_Transaction_Amount DECIMAL(18, 2)
);

-- Insert summarized transaction data into the new table, grouped by name, surname, category, and month
INSERT INTO Project1..Individual_Transactions_By_Category_Month (Name, Surname, Category, Transaction_Month, Total_Transaction_Amount)
SELECT
    Name,
    Surname,
    Category2 AS Category,
    DATEPART(MONTH, Date) AS Transaction_Month,
    SUM(Transaction_Amount) AS Total_Transaction_Amount
FROM 
    Project1..Credit_card_transaction_flow
GROUP BY
    Name,
    Surname,
    Category2,
    DATEPART(MONTH, Date);

-- Select all records for a specific individual ('Aaron Armstrong') from the summarized transaction table
SELECT *
FROM Project1..Individual_Transactions_By_Category_Month
WHERE Name = 'Aaron' AND Surname = 'Armstrong';

-- Select the full name, total transaction amount, and category from the summarized transaction table
SELECT
    CONCAT(Name, ' ', Surname) AS Full_Name, Total_Transaction_Amount, Category
FROM Project1..Individual_Transactions_By_Category_Month;

-- Calculate total rewards earned from all credit cards by each individual
-- This includes promotional rewards and cashback rewards based on transaction categories and amounts
SELECT
    CONCAT(itr.Name, ' ', itr.Surname) AS Full_Name,
    ccr.Credit_Card,
    SUM(
        CASE
            WHEN itr.Total_Transaction_Amount >= ccr.Target 
                 AND itr.Transaction_month <= ccr.Deadline_Months 
            THEN ccr.Promo
            ELSE 0
        END
    ) AS Total_Promo_Rewards,
    SUM(
        CASE
            WHEN itr.Category = 'Travel' THEN itr.Total_Transaction_Amount * ccr.Travel
            WHEN itr.Category = 'Dining_and_groceries' THEN itr.Total_Transaction_Amount * ccr.Dining_and_groceries
            WHEN itr.Category = 'Other' THEN itr.Total_Transaction_Amount * ccr.Other
            ELSE 0
        END
    ) AS Total_Cashback_Rewards,
    SUM(
        CASE
            WHEN itr.Total_Transaction_Amount >= ccr.Target 
                 AND itr.Transaction_month <= ccr.Deadline_Months 
            THEN ccr.Promo
            ELSE 0
        END
    ) +
    SUM(
        CASE
            WHEN itr.Category = 'Travel' THEN itr.Total_Transaction_Amount * ccr.Travel
            WHEN itr.Category = 'Dining_and_groceries' THEN itr.Total_Transaction_Amount * ccr.Dining_and_groceries
            WHEN itr.Category = 'Other' THEN itr.Total_Transaction_Amount * ccr.Other
            ELSE 0
        END
    ) - ccr.Annual_fee AS Total_Rewards_Earned
FROM 
    Project1..Individual_Transactions_By_Category_Month itr
CROSS JOIN 
    Project1..Credit_card_rewards ccr
JOIN (
    SELECT
        itr.Name,
        itr.Surname,
        SUM(
            CASE
                WHEN itr.Transaction_month <= ccr.Deadline_Months
                THEN itr.Total_Transaction_Amount
                ELSE 0
            END
        ) AS Total_Transaction_Amount
    FROM 
        Project1..Individual_Transactions_By_Category_Month itr
    CROSS JOIN 
        Project1..Credit_card_rewards ccr
    GROUP BY
        itr.Name,
        itr.Surname
) AS sub ON itr.Name = sub.Name AND itr.Surname = sub.Surname
GROUP BY
    CONCAT(itr.Name, ' ', itr.Surname),
    ccr.Credit_Card,
    ccr.Annual_fee
ORDER BY 
    1, 2;

-- Separate all transactions made by category and calculate rewards
-- This includes total promotional rewards and cashback rewards by category
SELECT
    CONCAT(itr.Name, ' ', itr.Surname) AS Full_Name,
    ccr.Credit_Card,
    itr.Category,
    SUM(
        CASE
            WHEN itr.Total_Transaction_Amount >= ccr.Target 
                 AND itr.Transaction_month <= ccr.Deadline_Months 
            THEN ccr.Promo
            ELSE 0
        END
    ) AS Total_Promo_Rewards,
    SUM(
        CASE
            WHEN itr.Category = 'Travel' THEN itr.Total_Transaction_Amount * ccr.Travel
            WHEN itr.Category = 'Dining_and_groceries' THEN itr.Total_Transaction_Amount * ccr.Dining_and_groceries
            WHEN itr.Category = 'Other' THEN itr.Total_Transaction_Amount * ccr.Other
            ELSE 0
        END
    ) AS Total_Cashback_Rewards,
    SUM(
        CASE
            WHEN itr.Total_Transaction_Amount >= ccr.Target 
                 AND itr.Transaction_month <= ccr.Deadline_Months 
            THEN ccr.Promo
            ELSE 0
        END
    ) +
    SUM(
        CASE
            WHEN itr.Category = 'Travel' THEN itr.Total_Transaction_Amount * ccr.Travel
            WHEN itr.Category = 'Dining_and_groceries' THEN itr.Total_Transaction_Amount * ccr.Dining_and_groceries
            WHEN itr.Category = 'Other' THEN itr.Total_Transaction_Amount * ccr.Other
            ELSE 0
        END
    ) - ccr.Annual_fee AS Total_Rewards_Earned
FROM 
    Project1..Individual_Transactions_By_Category_Month itr
CROSS JOIN 
    Project1..Credit_card_rewards ccr
JOIN (
    SELECT
        itr.Name,
        itr.Surname,
        SUM(
            CASE
                WHEN itr.Transaction_month <= ccr.Deadline_Months
                THEN itr.Total_Transaction_Amount
                ELSE 0
            END
        ) AS Total_Transaction_Amount
    FROM 
        Project1..Individual_Transactions_By_Category_Month itr
    CROSS JOIN 
        Project1..Credit_card_rewards ccr
    GROUP BY
        itr.Name,
        itr.Surname
) AS sub ON itr.Name = sub.Name AND itr.Surname = sub.Surname
GROUP BY
    CONCAT(itr.Name, ' ', itr.Surname),
    ccr.Credit_Card,
    ccr.Annual_fee,
    itr.Category
ORDER BY 
    1, 2;

-- Select the top two credit cards with the highest total rewards earned by each individual
WITH RankedRewards AS (
    SELECT
        CONCAT(itr.Name, ' ', itr.Surname) AS Full_Name,
        ccr.Credit_Card,
        SUM(
            CASE
                WHEN itr.Total_Transaction_Amount >= ccr.Target 
                     AND itr.Transaction_month <= ccr.Deadline_Months 
                THEN ccr.Promo
                ELSE 0
            END
        ) AS Total_Promo_Rewards,
        SUM(
            CASE
                WHEN itr.Category = 'Travel' THEN itr.Total_Transaction_Amount * ccr.Travel
                WHEN itr.Category = 'Dining_and_groceries' THEN itr.Total_Transaction_Amount * ccr.Dining_and_groceries
                WHEN itr.Category = 'Other' THEN itr.Total_Transaction_Amount * ccr.Other
                ELSE 0
            END
        ) AS Total_Cashback_Rewards,
        SUM(
            CASE
                WHEN itr.Total_Transaction_Amount >= ccr.Target 
                     AND itr.Transaction_month <= ccr.Deadline_Months 
                THEN ccr.Promo
                ELSE 0
            END
        ) +
        SUM(
            CASE
                WHEN itr.Category = 'Travel' THEN itr.Total_Transaction_Amount * ccr.Travel
                WHEN itr.Category = 'Dining_and_groceries' THEN itr.Total_Transaction_Amount * ccr.Dining_and_groceries
                WHEN itr.Category = 'Other' THEN itr.Total_Transaction_Amount * ccr.Other
                ELSE 0
            END
        ) - ccr.Annual_fee AS Total_Rewards_Earned,
        ROW_NUMBER() OVER (PARTITION BY CONCAT(itr.Name, ' ', itr.Surname) ORDER BY SUM(
            CASE
                WHEN itr.Total_Transaction_Amount >= ccr.Target 
                     AND itr.Transaction_month <= ccr.Deadline_Months 
                THEN ccr.Promo
                ELSE 0
            END
        ) +
        SUM(
            CASE
                WHEN itr.Category = 'Travel' THEN itr.Total_Transaction_Amount * ccr.Travel
                WHEN itr.Category = 'Dining_and_groceries' THEN itr.Total_Transaction_Amount * ccr.Dining_and_groceries
                WHEN itr.Category = 'Other' THEN itr.Total_Transaction_Amount * ccr.Other
                ELSE 0
            END
        ) - ccr.Annual_fee DESC) AS CardRank
    FROM 
        Project1..Individual_Transactions_By_Category_Month itr
    CROSS JOIN 
        Project1..Credit_card_rewards ccr
    JOIN (
        SELECT
            itr.Name,
            itr.Surname,
            SUM(
                CASE
                    WHEN itr.Transaction_month <= ccr.Deadline_Months
                    THEN itr.Total_Transaction_Amount
                    ELSE 0
                END
            ) AS Total_Transaction_Amount
        FROM 
            Project1..Individual_Transactions_By_Category_Month itr
        CROSS JOIN 
            Project1..Credit_card_rewards ccr
        GROUP BY
            itr.Name,
            itr.Surname
    ) AS sub ON itr.Name = sub.Name AND itr.Surname = sub.Surname
    GROUP BY
        CONCAT(itr.Name, ' ', itr.Surname),
        ccr.Credit_Card,
        ccr.Annual_fee
)
SELECT
    Full_Name,
    Credit_Card,
    Total_Promo_Rewards,
    Total_Cashback_Rewards,
    Total_Rewards_Earned
FROM 
    RankedRewards
WHERE
    CardRank <= 2
ORDER BY 
    Full_Name, CardRank;

-- Separate the top two credit cards with the highest total rewards earned by category
WITH RankedRewards AS (
    SELECT
        CONCAT(itr.Name, ' ', itr.Surname) AS Full_Name,
        ccr.Credit_Card,
        itr.Category, -- Add the category here
        SUM(
            CASE
                WHEN itr.Total_Transaction_Amount >= ccr.Target 
                     AND itr.Transaction_month <= ccr.Deadline_Months 
                THEN ccr.Promo
                ELSE 0
            END
        ) AS Total_Promo_Rewards,
        SUM(
            CASE
                WHEN itr.Category = 'Travel' THEN itr.Total_Transaction_Amount * ccr.Travel
                WHEN itr.Category = 'Dining_and_groceries' THEN itr.Total_Transaction_Amount * ccr.Dining_and_groceries
                WHEN itr.Category = 'Other' THEN itr.Total_Transaction_Amount * ccr.Other
                ELSE 0
            END
        ) AS Total_Cashback_Rewards,
        SUM(
            CASE
                WHEN itr.Total_Transaction_Amount >= ccr.Target 
                     AND itr.Transaction_month <= ccr.Deadline_Months 
                THEN ccr.Promo
                ELSE 0
            END
        ) +
        SUM(
            CASE
                WHEN itr.Category = 'Travel' THEN itr.Total_Transaction_Amount * ccr.Travel
                WHEN itr.Category = 'Dining_and_groceries' THEN itr.Total_Transaction_Amount * ccr.Dining_and_groceries
                WHEN itr.Category = 'Other' THEN itr.Total_Transaction_Amount * ccr.Other
                ELSE 0
            END
        ) - ccr.Annual_fee AS Total_Rewards_Earned,
        ROW_NUMBER() OVER (PARTITION BY CONCAT(itr.Name, ' ', itr.Surname) ORDER BY SUM(
            CASE
                WHEN itr.Total_Transaction_Amount >= ccr.Target 
                     AND itr.Transaction_month <= ccr.Deadline_Months 
                THEN ccr.Promo
                ELSE 0
            END
        ) +
        SUM(
            CASE
                WHEN itr.Category = 'Travel' THEN itr.Total_Transaction_Amount * ccr.Travel
                WHEN itr.Category = 'Dining_and_groceries' THEN itr.Total_Transaction_Amount * ccr.Dining_and_groceries
                WHEN itr.Category = 'Other' THEN itr.Total_Transaction_Amount * ccr.Other
                ELSE 0
            END
        ) - ccr.Annual_fee DESC) AS CardRank
    FROM 
        Project1..Individual_Transactions_By_Category_Month itr
    CROSS JOIN 
        Project1..Credit_card_rewards ccr
    JOIN (
        SELECT
            itr.Name,
            itr.Surname,
            SUM(
                CASE
                    WHEN itr.Transaction_month <= ccr.Deadline_Months
                    THEN itr.Total_Transaction_Amount
                    ELSE 0
                END
            ) AS Total_Transaction_Amount
        FROM 
            Project1..Individual_Transactions_By_Category_Month itr
        CROSS JOIN 
            Project1..Credit_card_rewards ccr
        GROUP BY
            itr.Name,
            itr.Surname
    ) AS sub ON itr.Name = sub.Name AND itr.Surname = sub.Surname
    GROUP BY
        CONCAT(itr.Name, ' ', itr.Surname),
        ccr.Credit_Card,
        ccr.Annual_fee,
        itr.Category -- Add the category here
)
SELECT
    Full_Name,
    Credit_Card,
    Category, -- Add the category here
    Total_Promo_Rewards,
    Total_Cashback_Rewards,
    Total_Rewards_Earned
FROM 
    RankedRewards
WHERE
    CardRank <= 2
ORDER BY 
    Full_Name, CardRank;
