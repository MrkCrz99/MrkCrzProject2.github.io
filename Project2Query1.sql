SELECT * 
From Project1..Credit_card_rewards

SELECT * 
From Project1..Credit_card_transaction_flow

SELECT DISTINCT Category 
From Project1..Credit_card_transaction_flow

SELECT Name, Transaction_Amount, Category2
From Project1..Credit_card_transaction_flow
WHERE Name = 'Heather' AND Surname = 'Jones'
GROUP BY Name, Transaction_Amount, Category2




ALTER TABLE Project1..Credit_card_transaction_flow
ADD Category2 VARCHAR(50);

UPDATE Project1..Credit_card_transaction_flow
SET Category2 = 
    CASE 
        WHEN Category = 'Market' THEN 'Dining_and_groceries'
        WHEN Category = 'Clothing' OR Category = 'Electronics' OR Category = 'Cosmetic' THEN 'Other'
        WHEN Category = 'Restaurant' THEN 'Dining_and_groceries'
        ELSE Category -- Leave unchanged for Travel
    END;




CREATE TABLE Project1..Individual_Transactions_By_Category_Month (
    Name VARCHAR(100),
    Surname VARCHAR(100),
    Category VARCHAR(100),
    Transaction_Month INT,
    Total_Transaction_Amount DECIMAL(18, 2));

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


SELECT *
FROM Project1..Individual_Transactions_By_Category_Month
WHERE NAME= 'Aaron' AND Surname = 'Armstrong'


SELECT
        CONCAT(Name, ' ',Surname) AS Full_Name, Total_Transaction_Amount, Category
FROM Project1..Individual_Transactions_By_Category_Month;


--This query calculates all total rewards from each credit cards earned from all transactions made by each individual.
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


--This query separates all transactions made by category.
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


--This query selects the top two credit cards with the highest total rewards earned earned by each individual 
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


--This query separates the top two credit cards with the highes total rewards earned by category
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
