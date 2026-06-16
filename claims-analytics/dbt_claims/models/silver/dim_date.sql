WITH date_spine AS (

    SELECT
        DATEADD(day, seq4(), '1970-01-01') AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 36525))  -- ~100 years

),

enhanced AS (

    SELECT
        date_day AS date_key,                        -- YYYY-MM-DD
        TO_CHAR(date_day, 'YYYYMMDD')::INT AS date_id, -- surrogate key

        -- Basic components
        YEAR(date_day) AS year,
        MONTH(date_day) AS month,
        DAY(date_day) AS day,
        QUARTER(date_day) AS quarter,
        WEEK(date_day) AS week_of_year,

        -- Names
        TO_CHAR(date_day, 'Month') AS month_name,
        TO_CHAR(date_day, 'Mon') AS month_abbrev,
        TO_CHAR(date_day, 'Day') AS day_name,
        TO_CHAR(date_day, 'Dy') AS day_abbrev,

        -- Flags
        CASE WHEN DAYOFWEEK(date_day) IN (1,7) THEN 1 ELSE 0 END AS is_weekend,
        CASE WHEN MONTH(date_day) IN (6,7,8) THEN 1 ELSE 0 END AS is_summer,
        CASE WHEN MONTH(date_day) IN (12,1,2) THEN 1 ELSE 0 END AS is_winter,

        -- Insurance analytics fields
        DATE_TRUNC('week', date_day) AS week_start,
        DATE_TRUNC('month', date_day) AS month_start,
        DATE_TRUNC('quarter', date_day) AS quarter_start,
        DATE_TRUNC('year', date_day) AS year_start,

        -- Useful derived fields
        DAYOFWEEK(date_day) AS day_of_week,
        DAYOFYEAR(date_day) AS day_of_year,
        LAST_DAY(date_day) AS month_end,
        DATEADD(day, -1, DATE_TRUNC('month', DATEADD(month, 1, date_day))) AS month_end_alt

    FROM date_spine
)

SELECT *
FROM enhanced
ORDER BY date_key