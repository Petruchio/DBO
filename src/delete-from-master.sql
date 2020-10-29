---> step_1

SELECT 7 * 10 ^ 7 + num::bigint * 10 ^ 3 AS step
FROM generate_series(1,150000) num

---> step_2

DELETE FROM master
WHERE id <  %{step}
AND   id >= 70000000
