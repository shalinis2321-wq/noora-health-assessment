-- 1. Detect possible duplicate inbound messages (same content, same user, 10 seconds)
SELECT
  t1.uuid AS msg_uuid_1,
  t2.uuid AS msg_uuid_2,
  t1.masked_from_addr,
  t1.content,
  t1.inserted_at AS inserted_at_1,
  t2.inserted_at AS inserted_at_2,
  ABS(EXTRACT(EPOCH FROM (t1.inserted_at - t2.inserted_at))) AS time_diff_seconds
FROM transformed_messages t1
JOIN transformed_messages t2
  ON t1.masked_from_addr = t2.masked_from_addr
 AND t1.content = t2.content
 AND t1.uuid < t2.uuid
WHERE ABS(EXTRACT(EPOCH FROM (t1.inserted_at - t2.inserted_at))) <= 10;


-- 2. Statuses that don't have corresponding messages
SELECT COUNT(*) AS statuses_without_message
FROM raw_statuses s
LEFT JOIN raw_messages m
  ON s.message_uuid = m.uuid
WHERE m.uuid IS NULL;


-- 3. Status timestamps going backwards (inconsistent ordering)
SELECT message_uuid
FROM (
    SELECT
        message_uuid,
        "timestamp",
        LAG("timestamp") OVER (
            PARTITION BY message_uuid
            ORDER BY "timestamp"
        ) AS prev_ts
    FROM raw_statuses
) t
WHERE prev_ts IS NOT NULL
  AND "timestamp" < prev_ts;


-- 4. Null UUIDs or invalid direction values
SELECT
  COUNT(*) FILTER (WHERE uuid IS NULL) AS null_uuid_count,
  COUNT(*) FILTER (WHERE direction NOT IN ('inbound','outbound')) AS bad_direction_count
FROM raw_messages;
