#### ANALYZING CAHNNEL PORTFOLIO MANAGEMENT ####

SELECT 
    website_sessions.utm_content,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as session_to_order
FROM
    website_sessions
    left join
    orders on website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
group by 1;

### Analyzing Channel Portfolios ####
SELECT 
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'bsearch' THEN website_session_id
            ELSE NULL
        END) AS bsearch_session,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END) AS gsearch_session
FROM
    website_sessions
WHERE
    created_at > '2012-08-22'
        AND created_at < '2012-11-29'
GROUP BY YEARWEEK(created_at);

### comparing channel characteristics ###
SELECT 
    utm_source,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS mobile_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS percentage_rate
FROM
    website_sessions
where created_at between '2012-08-22' and '2012-11-30'
and utm_campaign = 'nonbrand'
GROUP BY 1;

SELECT 
    utm_campaign,
    utm_source
FROM
    website_sessions
WHERE
    utm_campaign = 'nonbrand'
GROUP BY 1,2;

### Cross Channel Bid Optimization ###
SELECT 
    website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-08-22' AND '2012-09-18'
        AND utm_campaign = 'nonbrand'
GROUP BY 1 , 2;

### Analyzing Channel Portfolio Trends ###
SELECT 
    DATE(created_at) AS week_start,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS gsearch_desktop_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS bsearch_desktop_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS bsearch_dekstop_rate,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS gsearch_mobile_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS bsearch_mobile_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS bsearch_mobile_rate
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-11-04' AND '2012-12-22'
        AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);

select http_referer from website_sessions
group by 1;

SELECT 
    CASE
        WHEN http_referer IS NULL THEN 'direct_type_in'
        WHEN
            http_referer = 'https://www.gsearch.com'
                AND utm_source IS NULL
        THEN
            'gsearch_organic'
        WHEN
            http_referer = 'https://www.bsearch.com'
                AND utm_source IS NULL
        THEN
            'bsearch_organic'
        ELSE 'others'
    END AS category_search,
    COUNT(DISTINCT website_session_id) AS total_sessions
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 100000 AND 115000
GROUP BY 1
ORDER BY 2 DESC;

SELECT 
    YEAR(created_at) AS year_start,
    MONTH(created_at) AS month_start,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'paid_nonbrand' THEN website_session_id
            ELSE NULL
        END) AS non_brand,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'paid_brand' THEN website_session_id
            ELSE NULL
        END) AS brand,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'paid_brand' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN channel_group = 'paid_nonbrand' THEN website_session_id
            ELSE NULL
        END) AS brand_percentage,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'direct_type_in' THEN website_session_id
            ELSE NULL
        END) AS direct,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'direct_type_in' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN channel_group = 'paid_nonbrand' THEN website_session_id
            ELSE NULL
        END) AS direct_nonbrand_percentage,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'organic_search' THEN website_session_id
            ELSE NULL
        END) AS organic,
    COUNT(DISTINCT CASE
            WHEN channel_group = 'organic_search' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN channel_group = 'paid_nonbrand' THEN website_session_id
            ELSE NULL
        END) AS organic_nonbrand_percentage
FROM
    (SELECT 
        website_session_id,
            created_at,
            CASE
                WHEN
                    http_referer IS NULL
                        AND utm_source IS NULL
                THEN
                    'direct_type_in'
                WHEN utm_campaign = 'brand' THEN 'paid_brand'
                WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
                WHEN
                    http_referer IN ('https://www.bsearch.com' , 'https://www.gsearch.com')
                        AND utm_source IS NULL
                THEN
                    'organic_search'
            END AS channel_group
    FROM
        website_sessions
    WHERE
        created_at < '2012-12-23') AS category_search
GROUP BY 2;

SELECT 
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END) AS nonbrand_gsearch_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS conv_rate_nonbrand_gsearch_session
FROM
    website_sessions
WHERE
    created_at BETWEEN '2014-03-01' AND '2015-03-01'
        AND utm_campaign = 'nonbrand'
GROUP BY 1 , 2;

SELECT 
    http_referer, utm_source, utm_campaign
FROM
    website_sessions
WHERE
    created_at BETWEEN '2014-03-03' AND '2015-03-03'
GROUP BY 1 , 2 , 3;

SELECT 
    MONTH(created_at),
    COUNT(DISTINCT website_session_id),
    COUNT(DISTINCT CASE
            WHEN
                utm_source IS NOT NULL
                    AND http_referer IS NOT NULL and device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS mobile_paid_search
FROM
    website_sessions
WHERE
    utm_campaign = 'nonbrand'
        AND created_at BETWEEN '2014-01-01' AND '2015-01-01'
GROUP BY 1;
    
    


    
