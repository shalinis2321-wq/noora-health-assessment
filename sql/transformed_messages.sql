DROP TABLE IF EXISTS transformed_messages;

CREATE TABLE transformed_messages AS
WITH messages_dedup AS (
    SELECT
        m.*,
        ROW_NUMBER() OVER (
            PARTITION BY m.uuid
            ORDER BY m.inserted_at DESC NULLS LAST, m.updated_at DESC NULLS LAST
        ) AS rn
    FROM raw_messages m
),
status_agg AS (
    SELECT
        s.message_uuid,
        jsonb_agg(
            jsonb_build_object(
                'status', s.status,
                'timestamp', s."timestamp",
                'inserted_at', s.inserted_at,
                'updated_at', s.updated_at
            )
            ORDER BY s."timestamp"
        ) AS status_history,
        MAX(CASE WHEN s.status = 'sent' THEN s."timestamp" END) AS sent_at,
        MAX(CASE WHEN s.status = 'read' THEN s."timestamp" END) AS read_at,
        MAX(s."timestamp") AS last_status_timestamp_from_statuses
    FROM raw_statuses s
    GROUP BY s.message_uuid
)
SELECT
    m.*,
    sa.status_history,
    sa.sent_at,
    sa.read_at,
    sa.last_status_timestamp_from_statuses
FROM messages_dedup m
LEFT JOIN status_agg sa
    ON sa.message_uuid = m.uuid
WHERE m.rn = 1;
