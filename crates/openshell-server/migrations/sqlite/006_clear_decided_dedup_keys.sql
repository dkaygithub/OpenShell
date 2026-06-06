-- Decided draft chunks must not hold dedup keys. The submit-time upsert
-- matches on (object_type, scope, dedup_key) regardless of row status, so a
-- decided row that still holds its key silently absorbs new observations
-- into a chunk the reviewer already acted on — and, because the index is
-- unique, blocks inserting a fresh pending row for the same endpoint.
-- Decision paths now clear the key, but rows decided before that rule
-- existed still carry theirs: scrub them.
UPDATE objects SET dedup_key = NULL
WHERE object_type = 'draft_policy_chunk'
  AND dedup_key IS NOT NULL
  AND status != 'pending';
