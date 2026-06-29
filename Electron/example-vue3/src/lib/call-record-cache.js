'use strict';

const {
  CALL_RECORD_SOURCES,
  normalizeCallRecordEntry,
  sortCallRecords,
  upsertCallRecord,
} = require('./call-records');

const DEFAULT_VISIBLE_CALL_RECORD_LIMIT = 10;
const DEFAULT_IM_RECORD_SOURCES = new Set([
  CALL_RECORD_SOURCES.IM_CALL_MESSAGE,
  CALL_RECORD_SOURCES.IM_HISTORY,
  CALL_RECORD_SOURCES.IM_SEND,
]);

function normalizeAccountId(value) {
  return String(value || '').trim() || 'anonymous';
}

function createCallRecordCacheKey(baseKey, accountId) {
  const safeAccountId = normalizeAccountId(accountId).replace(/[^a-zA-Z0-9_.-]+/g, '_');
  return `${baseKey || 'necallkit.call-records'}.${safeAccountId}`;
}

function normalizeDefaultCallRecords(records, options = {}) {
  const limit =
    Number.isFinite(Number(options.limit)) && Number(options.limit) > 0
      ? Number(options.limit)
      : DEFAULT_VISIBLE_CALL_RECORD_LIMIT;
  const normalizedRecords = (Array.isArray(records) ? records : [])
    .map((record) => normalizeCallRecordEntry(record))
    .filter((record) => record && DEFAULT_IM_RECORD_SOURCES.has(record.source))
    .reduce(
      (currentRecords, record) =>
        upsertCallRecord(currentRecords, record, { limit }),
      []
    );

  return sortCallRecords(normalizedRecords).slice(0, limit);
}

function readStoredCallRecords(storage, key, options = {}) {
  if (!storage || typeof storage.getItem !== 'function' || !key) {
    return [];
  }

  try {
    const raw = storage.getItem(key);
    if (!raw) {
      return [];
    }
    return normalizeDefaultCallRecords(JSON.parse(raw), options);
  } catch (_error) {
    return [];
  }
}

function writeStoredCallRecords(storage, key, records, options = {}) {
  if (!storage || typeof storage.setItem !== 'function' || !key) {
    return;
  }

  try {
    storage.setItem(
      key,
      JSON.stringify(normalizeDefaultCallRecords(records, options))
    );
  } catch (_error) {}
}

module.exports = {
  DEFAULT_VISIBLE_CALL_RECORD_LIMIT,
  createCallRecordCacheKey,
  normalizeDefaultCallRecords,
  readStoredCallRecords,
  writeStoredCallRecords,
};
