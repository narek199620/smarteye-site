-- SmartEye booking concurrency protection (REVIEW ONLY; not deployed)
-- Before applying: take a backup, run preflight, and verify the intended
-- treatment of cancelled visits (cx=1) and completed tasks (st=done).
-- Existing book_survey/visit_move reject any task with matching date/time
-- where coalesce(st,'') <> 'done'. This index mirrors that existing rule.
--
-- PREFLIGHT: must return zero rows before creating the index.
-- SELECT data->>'date' AS day, data->>'time' AS slot, count(*) AS n
-- FROM public.tasks
-- WHERE data->>'date' IS NOT NULL AND data->>'time' IS NOT NULL
--   AND coalesce(data->>'st','') <> 'done'
-- GROUP BY 1,2 HAVING count(*) > 1;
--
-- Important: verify whether non-booking tasks also share date/time and
-- whether cancelled visits should free their slots. If so, refine BOTH
-- application checks and this predicate before applying.
--
-- Run separately during a maintenance window; CONCURRENTLY cannot run
-- inside a transaction and may leave an invalid index if it fails.
CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS tasks_active_slot_unique_idx
ON public.tasks ((data->>'date'), (data->>'time'))
WHERE data->>'date' IS NOT NULL
  AND data->>'time' IS NOT NULL
  AND coalesce(data->>'st','') <> 'done';

-- Application follow-up required: catch SQLSTATE 23505 in book_survey and
-- visit_move and return the existing {ok:false,taken:true} response.
-- Test: simultaneous inserts, simultaneous moves, moving to occupied slot,
-- completed task slot reuse, cancelled visits, and unrelated tasks.
