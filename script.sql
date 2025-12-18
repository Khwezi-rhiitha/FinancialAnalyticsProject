-- Project description --
/*The SQL queries focuses on customer demographics, credit behavior, risk exposure, 
and card product performance. These analyses support informed decision-making in 
credit risk management and customer segmentation.*/

-- 1.View data from tables
/*select * from dbo.transactions_data;*/
select * from dbo.cards_data;
select * from dbo.users_data;

-- 2.Combines data important data from the two tables
select 
	u.id as user_id, 
	u.current_age, 
	u.gender,
	u.yearly_income, 
	u.credit_score,
	c.card_brand,
	c.card_type,
	c.credit_limit,
	c.acct_open_date
from cards_data c
left join users_data u 
	on c.client_id = u.id

-- 3.Total Credit limit per user across all thier accounts.
/* A credit limit is the maximum amount of money the bank allows a customer to borrow on a card.
   The bank trusts the customer, The customer has a good credit history, The customer has stable income
   The customer is considered low to medium risk*/
SELECT
	u.id AS user_id,
	SUM(c.credit_limit) AS total_credit_limit
FROM users_data u
LEFT JOIN cards_data c
	ON u.id = c.client_id
GROUP BY u.id
ORDER BY total_credit_limit DESC;

-- 4.Average Credit limit by Card Type.
/* This query calculates the average credit limit for each card type*/
SELECT
    card_type,
    AVG(credit_limit) AS avg_credit_limit
FROM cards_data
GROUP BY card_type;

-- 5.Relationship between customer Credit Score and Credit Limit
SELECT
    u.credit_score,
    AVG(c.credit_limit) AS avg_credit_limit
FROM users_data u
LEFT JOIN cards_data c
    ON u.id = c.client_id
GROUP BY u.credit_score
ORDER BY u.credit_score;

-- 6.Average credit limit per customer
/* See individual customer behavior, Identify specific high-risk users
   Perform customer-level analysis*/
SELECT
    u.id,
    u.credit_score,
    AVG(c.credit_limit) AS avg_credit_limit
FROM users_data u
LEFT JOIN cards_data c
    ON u.id = c.client_id
GROUP BY u.id, u.credit_score;

-- 7.Customers with muliple cards
SELECT
    u.id AS user_id,
    COUNT(c.id) AS number_of_cards
FROM users_data u
LEFT JOIN cards_data c
    ON u.id = c.client_id
GROUP BY u.id
HAVING COUNT(c.id) > 1;

-- 8.Credit limit by gender
SELECT
    u.gender,
    SUM(c.credit_limit) AS total_credit_limit
FROM users_data u
LEFT JOIN cards_data c
    ON u.id = c.client_id
GROUP BY u.gender;

-- 9.Income vs Debt Analysis. Identifies customes who might be in debt.
/* The debt-to-income ratio represents the percentage of a customer’s income 
   that is used to pay the existing debt*/
SELECT
    u.id AS user_id,
    u.yearly_income,
    u.total_debt,
    (u.total_debt / NULLIF(u.yearly_income, 0)) * 100 AS debt_to_income_ratio
FROM users_data u;

-- 10.Credit Score Category
/* Groups users into standard credit score categories such as Poor, Fair, Good, and Excellent*/
SELECT
    CASE
        WHEN credit_score < 580 THEN 'Poor'
        WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
        WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
        WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
        ELSE 'Excellent'
    END AS credit_score_band,
    COUNT(*) AS total_users
FROM users_data
GROUP BY
    CASE
        WHEN credit_score < 580 THEN 'Poor'
        WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
        WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
        WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
        ELSE 'Excellent'
    END;

-- 11.Analyse how many cards have chips and how do not.
SELECT
    has_chip,
    COUNT(*) AS total_cards
FROM cards_data
GROUP BY has_chip;

-- 12.Average years since pin was changed
SELECT
	id,
    AVG(YEAR(GETDATE()) - year_pin_last_changed) AS avg_years_since_pin_change
FROM cards_data
GROUP BY id

-- 13.Identifies customers with low credit scores but high credit limits
SELECT
    u.id AS user_id,
    u.credit_score,
    c.credit_limit
FROM users_data u
JOIN cards_data c
    ON u.id = c.client_id
WHERE u.credit_score < 600
  AND c.credit_limit > 10000;

-- 14.Identifies cards issued per annum
SELECT
    YEAR(acct_open_date) AS year_issued,
    COUNT(*) AS total_cards
FROM cards_data
GROUP BY YEAR(acct_open_date)
ORDER BY year_issued;

-- 15.Cards close to expirary date
SELECT
    id AS card_id,
    client_id,
    card_brand,
    card_type,
    expires
FROM cards_data
WHERE expires BETWEEN GETDATE() AND DATEADD(MONTH, 6, GETDATE());

