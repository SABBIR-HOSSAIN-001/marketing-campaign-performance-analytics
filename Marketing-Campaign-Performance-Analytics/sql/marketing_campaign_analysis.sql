CREATE TABLE marketing_campaigns (
    spend_date DATE,
    campaign_id VARCHAR(50),
    channel VARCHAR(50),
    impressions BIGINT,
    clicks BIGINT,
    leads BIGINT,
    conversions BIGINT,
    spend NUMERIC(14,2),
    revenue NUMERIC(14,2),
    month VARCHAR(7)
);

---Imported Data Verify

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT campaign_id) AS unique_campaigns,
    MIN(spend_date) AS first_date,
    MAX(spend_date) AS last_date,
    SUM(spend) AS total_spend,
    SUM(revenue) AS total_revenue
FROM marketing_campaigns;


SELECT *
FROM marketing_campaigns
LIMIT 10;

---Channel Performance Analysis

SELECT
    channel,
    SUM(spend) AS total_spend,
    SUM(revenue) AS total_revenue,
    SUM(clicks) AS total_clicks,
    SUM(leads) AS total_leads,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(revenue) / NULLIF(SUM(spend), 0), 2) AS roas,
    ROUND(SUM(spend) / NULLIF(SUM(conversions), 0), 2) AS cac,
    ROUND(
        (SUM(revenue) - SUM(spend)) / NULLIF(SUM(spend), 0) * 100,
        2
    ) AS roi_pct
FROM marketing_campaigns
GROUP BY channel
ORDER BY roas DESC;

--Monthly Performance Analysis

SELECT
    DATE_TRUNC('month', spend_date)::DATE AS month,
    SUM(spend) AS total_spend,
    SUM(revenue) AS total_revenue,
    SUM(clicks) AS total_clicks,
    SUM(leads) AS total_leads,
    SUM(conversions) AS total_conversions,
    ROUND(
        SUM(revenue) / NULLIF(SUM(spend), 0),
        2
    ) AS roas,
    ROUND(
        (SUM(revenue) - SUM(spend))
        / NULLIF(SUM(spend), 0) * 100,
        2
    ) AS roi_pct
FROM marketing_campaigns
GROUP BY DATE_TRUNC('month', spend_date)
ORDER BY month;

---Campaign-Level Performance Ranking

SELECT
    campaign_id,
    channel,
    SUM(spend) AS total_spend,
    SUM(revenue) AS total_revenue,
    SUM(conversions) AS total_conversions,
    ROUND(
        SUM(revenue) / NULLIF(SUM(spend), 0),
        2
    ) AS roas,
    ROUND(
        SUM(spend) / NULLIF(SUM(conversions), 0),
        2
    ) AS cac,
    ROUND(
        (SUM(revenue) - SUM(spend))
        / NULLIF(SUM(spend), 0) * 100,
        2
    ) AS roi_pct
FROM marketing_campaigns
GROUP BY campaign_id, channel
ORDER BY roas DESC
LIMIT 10;

--Create a Reusable view

CREATE OR REPLACE VIEW vw_marketing_channel_performance AS
SELECT
    channel,
    SUM(spend) AS total_spend,
    SUM(revenue) AS total_revenue,
    SUM(revenue) - SUM(spend) AS total_profit,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(leads) AS total_leads,
    SUM(conversions) AS total_conversions,

    ROUND(
        SUM(clicks)::NUMERIC
        / NULLIF(SUM(impressions), 0) * 100, 2
    ) AS ctr_pct,

    ROUND(
        SUM(spend) / NULLIF(SUM(clicks), 0), 2
    ) AS cpc,

    ROUND(
        SUM(spend) / NULLIF(SUM(leads), 0), 2
    ) AS cpl,

    ROUND(
        SUM(spend) / NULLIF(SUM(conversions), 0), 2
    ) AS cac,

    ROUND(
        SUM(revenue) / NULLIF(SUM(spend), 0), 2
    ) AS roas,

    ROUND(
        (SUM(revenue) - SUM(spend))
        / NULLIF(SUM(spend), 0) * 100, 2
    ) AS roi_pct

FROM marketing_campaigns
GROUP BY channel;


SELECT *
FROM vw_marketing_channel_performance
ORDER BY roas DESC;


---Create Monthly Performance View

CREATE OR REPLACE VIEW vw_marketing_monthly_performance AS
SELECT
    DATE_TRUNC('month', spend_date)::DATE AS month,
    SUM(spend) AS total_spend,
    SUM(revenue) AS total_revenue,
    SUM(revenue) - SUM(spend) AS total_profit,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(leads) AS total_leads,
    SUM(conversions) AS total_conversions,

    ROUND(
        SUM(clicks)::NUMERIC
        / NULLIF(SUM(impressions), 0) * 100, 2
    ) AS ctr_pct,

    ROUND(
        SUM(spend) / NULLIF(SUM(clicks), 0), 2
    ) AS cpc,

    ROUND(
        SUM(spend) / NULLIF(SUM(leads), 0), 2
    ) AS cpl,

    ROUND(
        SUM(spend) / NULLIF(SUM(conversions), 0), 2
    ) AS cac,

    ROUND(
        SUM(revenue) / NULLIF(SUM(spend), 0), 2
    ) AS roas,

    ROUND(
        (SUM(revenue) - SUM(spend))
        / NULLIF(SUM(spend), 0) * 100, 2
    ) AS roi_pct

FROM marketing_campaigns
GROUP BY DATE_TRUNC('month', spend_date)::DATE;


SELECT *
FROM vw_marketing_monthly_performance
ORDER BY month;

---Create Campaign Performance View

CREATE OR REPLACE VIEW vw_marketing_campaign_performance AS
SELECT
    campaign_id,
    channel,
    SUM(spend) AS total_spend,
    SUM(revenue) AS total_revenue,
    SUM(revenue) - SUM(spend) AS total_profit,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(leads) AS total_leads,
    SUM(conversions) AS total_conversions,

    ROUND(
        SUM(revenue) / NULLIF(SUM(spend), 0), 2
    ) AS roas,

    ROUND(
        SUM(spend) / NULLIF(SUM(conversions), 0), 2
    ) AS cac,

    ROUND(
        (SUM(revenue) - SUM(spend))
        / NULLIF(SUM(spend), 0) * 100, 2
    ) AS roi_pct

FROM marketing_campaigns
GROUP BY campaign_id, channel;


SELECT *
FROM vw_marketing_campaign_performance
ORDER BY roas DESC
LIMIT 10;























