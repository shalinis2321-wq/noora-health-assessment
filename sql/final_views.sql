-- 1. Weekly total & active users
CREATE OR REPLACE VIEW vw_weekly_total_active_users AS
WITH per_message_users AS (
    SELECT
        *,
        CASE
            WHEN direction = 'inbound' THEN masked_from_addr
            ELSE masked_addressees 
        END AS user_id
    FROM transformed_messages
),
by_week AS (
    SELECT
        date_trunc('week', inserted_at)::date AS week_start,
        user_id,
        MAX(CASE WHEN direction = 'inbound' THEN 1 ELSE 0 END) AS is_active
    FROM per_message_users
    GROUP BY 1, 2
)
SELECT
    week_start,
    COUNT(DISTINCT user_id) AS total_users,
    COUNT(DISTINCT CASE WHEN is_active = 1 THEN user_id END) AS active_users
FROM by_week
GROUP BY week_start
ORDER BY week_start;



-- 2. Fraction of non-failed outbound messages that were read
CREATE OR REPLACE VIEW vw_fraction_non_failed_msgs_outbound AS
WITH outbound AS (
    SELECT *
    FROM transformed_messages
    WHERE direction = 'outbound'
),
non_failed AS (
    SELECT *
    FROM outbound
    WHERE NOT EXISTS (
        SELECT 1
        FROM jsonb_array_elements(status_history) AS x
        WHERE x->>'status' = 'failed'
    )
),
agg AS (
    SELECT
        COUNT(*) AS total_non_failed,
        COUNT(*) FILTER (
            WHERE EXISTS (
                SELECT 1
                FROM jsonb_array_elements(status_history) AS x
                WHERE x->>'status' = 'read'
            )
        ) AS read_non_failed
    FROM non_failed
)
SELECT
    total_non_failed,
    read_non_failed,
    read_non_failed::decimal / NULLIF(total_non_failed, 0) AS fraction_read
FROM agg;



-- 3. Sent to read time for non-failed outbound messages
CREATE OR REPLACE VIEW vw_sent_read_time AS
SELECT
    uuid,
    EXTRACT(EPOCH FROM (read_at - sent_at)) / 60.0 AS minutes_to_read
FROM transformed_messages
WHERE direction = 'outbound'
  AND sent_at IS NOT NULL
  AND read_at IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM jsonb_array_elements(status_history) AS x
        WHERE x->>'status' = 'failed'
  );



-- 4. Outbound status for the last 7 days of available data
CREATE OR REPLACE VIEW vw_outbound_status_last_week AS
WITH bounds AS (
    SELECT
        date_trunc('day', MAX(inserted_at))::date AS max_date
    FROM transformed_messages
)
SELECT
    COALESCE(last_status, 'unknown') AS last_status,
    COUNT(*) AS message_count
FROM transformed_messages t
CROSS JOIN bounds b
WHERE t.direction = 'outbound'
  AND t.inserted_at >= (b.max_date - INTERVAL '7 days')
  AND t.inserted_at <  (b.max_date + INTERVAL '1 day')
GROUP BY COALESCE(last_status, 'unknown')
ORDER BY message_count DESC;
