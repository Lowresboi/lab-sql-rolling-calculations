use sakila; 

-- Get number of monthly active customers
SELECT
    DATE_FORMAT(payment.payment_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer.customer_id) AS active_customers
FROM
    payment
JOIN rental ON payment.rental_id = rental.rental_id
JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY
    DATE_FORMAT(payment.payment_date, '%Y-%m');
    
-- Active users in the previous month ??
SELECT
    DATE_FORMAT(payment.payment_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer.customer_id) AS active_customers
FROM
    payment
JOIN rental ON payment.rental_id = rental.rental_id
JOIN customer ON payment.customer_id = customer.customer_id
WHERE
    DATE_FORMAT(payment.payment_date, '%Y-%m') = DATE_FORMAT(NOW() - INTERVAL 1 MONTH, '%Y-%m')
GROUP BY
    DATE_FORMAT(payment.payment_date, '%Y-%m');

-- Percentage change in the number of active customer
WITH MonthlyActiveCustomers AS (
    SELECT
        DATE_FORMAT(payment.payment_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer.customer_id) AS active_customers
    FROM
        payment
    JOIN rental ON payment.rental_id = rental.rental_id
    JOIN customer ON payment.customer_id = customer.customer_id
    GROUP BY
        DATE_FORMAT(payment.payment_date, '%Y-%m')
)

SELECT
    month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY month) AS previous_month_active_customers,
    CASE
        WHEN LAG(active_customers) OVER (ORDER BY month) = 0 THEN NULL
        ELSE ((active_customers - LAG(active_customers) OVER (ORDER BY month)) / LAG(active_customers) OVER (ORDER BY month)) * 100
    END AS percentage_change
FROM
    MonthlyActiveCustomers;
    
-- Retained customers every month ??
SELECT
    DATE_FORMAT(payment.payment_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer.customer_id) AS retained_customers
FROM
    payment
JOIN rental ON payment.rental_id = rental.rental_id
JOIN customer ON payment.customer_id = customer.customer_id
WHERE
    DATE_FORMAT(payment.payment_date, '%Y-%m') = DATE_FORMAT(NOW(), '%Y-%m')
    AND customer.customer_id IN (
        SELECT DISTINCT customer_id
        FROM payment
        WHERE DATE_FORMAT(payment_date, '%Y-%m') = DATE_FORMAT(NOW() - INTERVAL 1 MONTH, '%Y-%m')
    )
GROUP BY
    DATE_FORMAT(payment.payment_date, '%Y-%m');



