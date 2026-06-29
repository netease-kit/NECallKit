'use strict';

const CALL_RECORD_SOURCE_PROVIDER_LOCAL = 'provider-local';
const CALL_RECORD_SOURCE_IM_CALL_MESSAGE = 'im-call-message';
const CALL_RECORD_SOURCE_IM_HISTORY = 'im-history';
const CALL_RECORD_SOURCE_IM_SEND = 'im-send';

const CALL_RECORD_SOURCES = Object.freeze({
  PROVIDER_LOCAL: CALL_RECORD_SOURCE_PROVIDER_LOCAL,
  IM_CALL_MESSAGE: CALL_RECORD_SOURCE_IM_CALL_MESSAGE,
  IM_HISTORY: CALL_RECORD_SOURCE_IM_HISTORY,
  IM_SEND: CALL_RECORD_SOURCE_IM_SEND,
});

const CALL_RECORD_DIRECTION_INCOMING = 'incoming';
const CALL_RECORD_DIRECTION_OUTGOING = 'outgoing';

const CALL_RECORD_DIRECTIONS = Object.freeze({
  INCOMING: CALL_RECORD_DIRECTION_INCOMING,
  OUTGOING: CALL_RECORD_DIRECTION_OUTGOING,
});

const V2NIM_MESSAGE_TYPE_CALL = 12;
const DEFAULT_CALL_RECORD_LIMIT = 50;
const COMPLETED_RECORD_COALESCE_WINDOW_MS = 2000;

const SOURCE_PRIORITY = Object.freeze({
  [CALL_RECORD_SOURCE_PROVIDER_LOCAL]: 0,
  [CALL_RECORD_SOURCE_IM_HISTORY]: 1,
  [CALL_RECORD_SOURCE_IM_CALL_MESSAGE]: 2,
  [CALL_RECORD_SOURCE_IM_SEND]: 3,
});

function isObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function normalizeText(value) {
  if (value === null || value === undefined) {
    return '';
  }
  return String(value).trim();
}

function normalizeId(value) {
  if (value === null || value === undefined) {
    return '';
  }
  if (typeof value === 'bigint') {
    return value.toString();
  }
  const text = String(value).trim();
  return text === '0' ? '' : text;
}

function normalizeNumber(value, fallback) {
  if (value === null || value === undefined || value === '') {
    return fallback;
  }
  if (typeof value === 'bigint') {
    return Number(value);
  }
  const numberValue = Number(value);
  return Number.isFinite(numberValue) ? numberValue : fallback;
}

function normalizeTimestampMs(value, fallback) {
  const timestamp = normalizeNumber(value, fallback);
  return Number.isFinite(timestamp) && timestamp > 0 ? timestamp : fallback;
}

function parseJsonObject(value) {
  if (typeof value !== 'string') {
    return null;
  }
  const trimmed = value.trim();
  if (!trimmed) {
    return null;
  }
  try {
    const parsed = JSON.parse(trimmed);
    return isObject(parsed) ? parsed : null;
  } catch (_error) {
    return null;
  }
}

function normalizeSource(source, fallback = CALL_RECORD_SOURCE_IM_CALL_MESSAGE) {
  const normalized = normalizeText(source);
  return Object.prototype.hasOwnProperty.call(SOURCE_PRIORITY, normalized)
    ? normalized
    : fallback;
}

function normalizeDirection(direction, fallback = CALL_RECORD_DIRECTION_INCOMING) {
  const normalized = normalizeText(direction).toLowerCase();
  if (normalized === CALL_RECORD_DIRECTION_OUTGOING || normalized === 'out') {
    return CALL_RECORD_DIRECTION_OUTGOING;
  }
  if (normalized === CALL_RECORD_DIRECTION_INCOMING || normalized === 'in') {
    return CALL_RECORD_DIRECTION_INCOMING;
  }
  return fallback;
}

function getMessageType(message) {
  return normalizeNumber(
    message && message.messageType !== undefined ? message.messageType : message && message.type,
    NaN
  );
}

function isCallMessage(message) {
  return isObject(message) && getMessageType(message) === V2NIM_MESSAGE_TYPE_CALL;
}

function normalizeCallAttachment(attachment) {
  if (!attachment) {
    return null;
  }
  if (typeof attachment === 'string') {
    return parseJsonObject(attachment);
  }
  if (!isObject(attachment)) {
    return null;
  }

  const rawAttachment = parseJsonObject(attachment.raw);
  return Object.assign({}, rawAttachment || {}, attachment);
}

function resolveSelfAccountId(message, options = {}) {
  const explicitSelf = normalizeText(options.selfAccountId);
  if (explicitSelf) {
    return explicitSelf;
  }
  const messageSelf = normalizeText(message && message.selfAccountId);
  if (messageSelf) {
    return messageSelf;
  }
  if (message && message.isSelf === true) {
    return normalizeText(message.senderId);
  }
  return normalizeText(message && message.receiverId);
}

function inferPeerFromConversationId(conversationId, selfAccountId) {
  const normalizedConversationId = normalizeText(conversationId);
  if (!normalizedConversationId) {
    return '';
  }
  const self = normalizeText(selfAccountId);
  const parts = normalizedConversationId
    .split(/[|:/]/)
    .map((part) => part.trim())
    .filter(Boolean)
    .filter((part) => part.toLowerCase() !== 'p2p');
  if (self) {
    const peer = parts.find((part) => part !== self);
    if (peer) {
      return peer;
    }
  }
  return parts.at(-1) || '';
}

function resolvePeerAccountId(message, selfAccountId) {
  const senderId = normalizeText(message && message.senderId);
  const receiverId = normalizeText(message && message.receiverId);
  const self = normalizeText(selfAccountId);

  if (self && senderId === self && receiverId) {
    return receiverId;
  }
  if (self && receiverId === self && senderId) {
    return senderId;
  }
  if (message && message.isSelf === true && receiverId) {
    return receiverId;
  }
  if (message && message.isSelf === false && senderId) {
    return senderId;
  }

  return inferPeerFromConversationId(message && message.conversationId, self);
}

function resolveDirection(message, selfAccountId) {
  const senderId = normalizeText(message && message.senderId);
  const receiverId = normalizeText(message && message.receiverId);
  const self = normalizeText(selfAccountId);
  if (message && message.isSelf === true) {
    return CALL_RECORD_DIRECTION_OUTGOING;
  }
  if (message && message.isSelf === false) {
    return CALL_RECORD_DIRECTION_INCOMING;
  }
  if (self && senderId === self) {
    return CALL_RECORD_DIRECTION_OUTGOING;
  }
  if (self && receiverId === self) {
    return CALL_RECORD_DIRECTION_INCOMING;
  }
  return CALL_RECORD_DIRECTION_INCOMING;
}

function resolveDispatchStatus(source, message, options = {}) {
  if (options.dispatchStatus) {
    return normalizeText(options.dispatchStatus);
  }
  if (source === CALL_RECORD_SOURCE_IM_SEND) {
    return 'sent';
  }
  if (source === CALL_RECORD_SOURCE_IM_HISTORY) {
    return 'history';
  }
  if (message && message.modifyTime) {
    return 'modified';
  }
  return 'synced';
}

function createRawMessageSummary(message, attachment) {
  const durations = Array.isArray(attachment && attachment.durations)
    ? attachment.durations
    : [];
  return {
    messageType: getMessageType(message),
    senderId: normalizeText(message && message.senderId),
    receiverId: normalizeText(message && message.receiverId),
    isSelf: message && typeof message.isSelf === 'boolean' ? message.isSelf : undefined,
    createTime: normalizeNumber(message && message.createTime, undefined),
    modifyTime: normalizeNumber(message && message.modifyTime, undefined),
    attachment: {
      type: normalizeNumber(attachment && attachment.type, undefined),
      status: normalizeNumber(attachment && attachment.status, undefined),
      channelId: normalizeText(attachment && attachment.channelId),
      durationCount: durations.length,
      durationHasCaller: durations.some(
        (item) => isObject(item) && item.caller !== undefined && item.caller !== null
      ),
    },
  };
}

function compactRecord(record) {
  return Object.fromEntries(
    Object.entries(record).filter(
      ([, value]) =>
        value !== undefined &&
        value !== '' &&
        (!Array.isArray(value) || value.length > 0)
    )
  );
}

function normalizeDedupeKeyList(value) {
  if (!Array.isArray(value)) {
    return [];
  }
  const keys = [];
  for (const item of value) {
    const key = normalizeText(item);
    if (key && !keys.includes(key)) {
      keys.push(key);
    }
  }
  return keys;
}

// 话单去重身份：优先 attachment.channelId，其次 messageServerId / messageClientId
// 作为次档兜底。注意 channelId 只适合同源 receive/modified/history 合并；
// 客户端自发 completed 与服务端系统 completed 可能使用不同 channelId，不能跨源合并。
// 故意不再使用 conversationId + timestampMs 的 fallback —— createTime 会被服务端
// 改写、多端同步副本之间也未必一致，时间戳无法作为身份依据。详见 B080 分析。
function getCallRecordDedupeKeys(record) {
  const entry = record || {};
  const channelId = normalizeText(entry.channelId);
  const messageServerId = normalizeId(entry.messageServerId);
  const messageClientId = normalizeId(entry.messageClientId);
  const keys = [];

  if (channelId) {
    keys.push(`call:${channelId}`);
  }
  if (messageServerId) {
    keys.push(`server:${messageServerId}`);
  }
  if (messageClientId) {
    keys.push(`client:${messageClientId}`);
  }

  for (const key of normalizeDedupeKeyList(entry.coalescedDedupeKeys)) {
    if (!keys.includes(key)) {
      keys.push(key);
    }
  }

  return keys;
}

function getPrimaryCallRecordDedupeKey(record) {
  return getCallRecordDedupeKeys(record)[0] || '';
}

function isImSyncSource(source) {
  const normalized = normalizeSource(source);
  return (
    normalized === CALL_RECORD_SOURCE_IM_CALL_MESSAGE ||
    normalized === CALL_RECORD_SOURCE_IM_HISTORY
  );
}

function isHexRtcChannelId(value) {
  return /^[0-9a-f]{32}$/i.test(normalizeText(value));
}

function isNumericChannelId(value) {
  return /^\d+$/.test(normalizeText(value));
}

function getRawAttachmentSummary(record) {
  return isObject(record && record.raw) && isObject(record.raw.attachment)
    ? record.raw.attachment
    : {};
}

function getCompletedRecordOrigin(record) {
  const channelId = normalizeText(record && record.channelId);
  const attachment = getRawAttachmentSummary(record);
  if (attachment.durationHasCaller === true || isNumericChannelId(channelId)) {
    return 'system';
  }
  if (isHexRtcChannelId(channelId)) {
    return 'client';
  }
  return 'unknown';
}

function getCompletedRecordOriginRank(record) {
  const origin = getCompletedRecordOrigin(record);
  if (origin === 'system') {
    return 2;
  }
  if (origin === 'client') {
    return 1;
  }
  return 0;
}

function isCompletedIncomingImRecord(record) {
  return (
    isObject(record) &&
    isImSyncSource(record.source) &&
    normalizeDirection(record.direction) === CALL_RECORD_DIRECTION_INCOMING &&
    normalizeNumber(record.callState, undefined) === 1 &&
    normalizeText(record.peerAccountId) !== '' &&
    normalizeNumber(record.callType, undefined) !== undefined
  );
}

function hasSameCompletedRecordScope(left, right) {
  const leftConversationId = normalizeText(left && left.conversationId);
  const rightConversationId = normalizeText(right && right.conversationId);
  if (
    leftConversationId &&
    rightConversationId &&
    leftConversationId !== rightConversationId
  ) {
    return false;
  }

  return (
    normalizeText(left && left.selfAccountId) === normalizeText(right && right.selfAccountId) &&
    normalizeText(left && left.peerAccountId) === normalizeText(right && right.peerAccountId) &&
    normalizeNumber(left && left.callType, undefined) ===
      normalizeNumber(right && right.callType, undefined)
  );
}

function isWithinCompletedRecordWindow(left, right) {
  const leftTime = normalizeTimestampMs(left && left.timestampMs, 0);
  const rightTime = normalizeTimestampMs(right && right.timestampMs, 0);
  return Math.abs(leftTime - rightTime) <= COMPLETED_RECORD_COALESCE_WINDOW_MS;
}

function isCompletedIncomingDuplicatePair(left, right) {
  if (!isCompletedIncomingImRecord(left) || !isCompletedIncomingImRecord(right)) {
    return false;
  }
  if (!hasSameCompletedRecordScope(left, right) || !isWithinCompletedRecordWindow(left, right)) {
    return false;
  }

  const leftOrigin = getCompletedRecordOrigin(left);
  const rightOrigin = getCompletedRecordOrigin(right);
  return (
    (leftOrigin === 'client' && rightOrigin === 'system') ||
    (leftOrigin === 'system' && rightOrigin === 'client')
  );
}

function createCallRecordId(record) {
  const key = getPrimaryCallRecordDedupeKey(record);
  if (key) {
    return `call-record:${key}`;
  }
  const source = normalizeSource(record && record.source, CALL_RECORD_SOURCE_PROVIDER_LOCAL);
  const localId = normalizeId(record && (record.localRecordId || record.id));
  if (localId) {
    return `call-record:${source}:${localId}`;
  }
  return `call-record:${source}:${Date.now()}`;
}

function parseCallMessageRecord(message, options = {}) {
  if (!isCallMessage(message)) {
    return null;
  }

  const attachment = normalizeCallAttachment(message.attachment);
  if (!attachment) {
    return null;
  }

  const source = normalizeSource(options.source);
  const fallbackTime = normalizeTimestampMs(options.nowMs, Date.now());
  const selfAccountId = resolveSelfAccountId(message, options);
  const peerAccountId = resolvePeerAccountId(message, selfAccountId);
  const callType = normalizeNumber(
    attachment.type !== undefined ? attachment.type : attachment.callType,
    undefined
  );
  const callState = normalizeNumber(
    attachment.status !== undefined ? attachment.status : attachment.callState,
    undefined
  );
  // channelId 是 NIM V2 call attachment 内字段，用作同源 receive/modified/history
  // 合并的最强 key；客户端自发 completed 与服务端 completed 不能假设同 channelId。
  const channelId = normalizeText(attachment.channelId);
  const entry = compactRecord({
    source,
    selfAccountId,
    peerAccountId,
    direction: resolveDirection(message, selfAccountId),
    callType,
    callState,
    channelId,
    timestampMs: normalizeTimestampMs(
      message.createTime !== undefined ? message.createTime : message.timestampMs,
      fallbackTime
    ),
    messageClientId: normalizeId(message.messageClientId),
    messageServerId: normalizeId(message.messageServerId),
    conversationId: normalizeText(message.conversationId),
    dispatchStatus: resolveDispatchStatus(source, message, options),
    raw: createRawMessageSummary(message, attachment),
    completedDuplicateMerged:
      options.completedDuplicateMerged === true ? true : undefined,
  });

  return Object.assign(entry, {
    id: createCallRecordId(entry),
    dedupeKey: getPrimaryCallRecordDedupeKey(entry),
  });
}

function normalizeProviderLocalRecord(record, options = {}) {
  const payload = isObject(record) ? record : {};
  const nowMs = normalizeTimestampMs(options.nowMs, Date.now());
  const localRecordId = normalizeId(
    payload.localRecordId || payload.id || options.localRecordId || nowMs
  );
  const entry = compactRecord({
    source: CALL_RECORD_SOURCE_PROVIDER_LOCAL,
    selfAccountId: normalizeText(options.selfAccountId || payload.selfAccountId),
    peerAccountId: normalizeText(payload.peerAccountId || payload.accId),
    accId: normalizeText(payload.accId || payload.peerAccountId),
    direction: normalizeDirection(payload.direction, CALL_RECORD_DIRECTION_OUTGOING),
    callType: normalizeNumber(payload.callType, undefined),
    callState: normalizeNumber(payload.callState, undefined),
    channelId: normalizeText(payload.channelId),
    timestampMs: normalizeTimestampMs(payload.timestampMs, nowMs),
    conversationId: normalizeText(payload.conversationId),
    dispatchStatus: normalizeText(payload.dispatchStatus || payload.note || 'provider-local'),
    localRecordId,
    callId: payload.callId,
    note: payload.note,
  });

  return Object.assign(entry, {
    id: createCallRecordId(entry),
    dedupeKey: '',
  });
}

function normalizeCallRecordEntry(entry) {
  if (!isObject(entry)) {
    return null;
  }
  if (entry.source === CALL_RECORD_SOURCE_PROVIDER_LOCAL) {
    return normalizeProviderLocalRecord(entry, entry);
  }
  const normalized = compactRecord({
    source: normalizeSource(entry.source),
    selfAccountId: normalizeText(entry.selfAccountId),
    peerAccountId: normalizeText(entry.peerAccountId),
    direction: normalizeDirection(entry.direction),
    callType: normalizeNumber(entry.callType, undefined),
    callState: normalizeNumber(entry.callState, undefined),
    channelId: normalizeText(entry.channelId),
    timestampMs: normalizeTimestampMs(entry.timestampMs, Date.now()),
    messageClientId: normalizeId(entry.messageClientId),
    messageServerId: normalizeId(entry.messageServerId),
    conversationId: normalizeText(entry.conversationId),
    dispatchStatus: normalizeText(entry.dispatchStatus),
    raw: entry.raw,
    completedDuplicateMerged: entry.completedDuplicateMerged === true ? true : undefined,
    coalescedDedupeKeys: normalizeDedupeKeyList(entry.coalescedDedupeKeys),
  });
  return Object.assign(normalized, {
    id: createCallRecordId(normalized),
    dedupeKey: getPrimaryCallRecordDedupeKey(normalized),
  });
}

function mergeSource(existingSource, incomingSource) {
  const existing = normalizeSource(existingSource);
  const incoming = normalizeSource(incomingSource);
  return (SOURCE_PRIORITY[incoming] || 0) >= (SOURCE_PRIORITY[existing] || 0)
    ? incoming
    : existing;
}

function mergeCallRecord(existingRecord, incomingRecord) {
  if (isCompletedIncomingDuplicatePair(existingRecord, incomingRecord)) {
    const existingRank = getCompletedRecordOriginRank(existingRecord);
    const incomingRank = getCompletedRecordOriginRank(incomingRecord);
    const preferredRecord =
      incomingRank >= existingRank ? incomingRecord : existingRecord;
    const fallbackRecord =
      preferredRecord === incomingRecord ? existingRecord : incomingRecord;
    const coalescedDedupeKeys = [
      ...getCallRecordDedupeKeys(existingRecord),
      ...getCallRecordDedupeKeys(incomingRecord),
    ].filter((key, index, keys) => key && keys.indexOf(key) === index);
    const mergedCompletedRecord = Object.assign({}, fallbackRecord, preferredRecord, {
      source: mergeSource(existingRecord.source, incomingRecord.source),
      channelId:
        normalizeText(preferredRecord.channelId) || normalizeText(fallbackRecord.channelId),
      messageClientId:
        normalizeId(preferredRecord.messageClientId) ||
        normalizeId(fallbackRecord.messageClientId),
      messageServerId:
        normalizeId(preferredRecord.messageServerId) ||
        normalizeId(fallbackRecord.messageServerId),
      completedDuplicateMerged: true,
      coalescedDedupeKeys,
    });
    mergedCompletedRecord.id = createCallRecordId(mergedCompletedRecord);
    mergedCompletedRecord.dedupeKey = getPrimaryCallRecordDedupeKey(mergedCompletedRecord);
    return compactRecord(mergedCompletedRecord);
  }

  const merged = Object.assign({}, existingRecord, incomingRecord, {
    source: mergeSource(existingRecord.source, incomingRecord.source),
    // channelId 是一次通话的强身份，一旦其中一方拿到就永远保留；incoming 缺失时
    // 不能被 undefined 覆盖。
    channelId:
      normalizeText(incomingRecord.channelId) || normalizeText(existingRecord.channelId),
    messageClientId:
      normalizeId(incomingRecord.messageClientId) || normalizeId(existingRecord.messageClientId),
    messageServerId:
      normalizeId(incomingRecord.messageServerId) || normalizeId(existingRecord.messageServerId),
  });

  merged.id = createCallRecordId(merged);
  merged.dedupeKey = getPrimaryCallRecordDedupeKey(merged);
  return compactRecord(merged);
}

function findExistingRecordIndex(records, incomingRecord) {
  const incomingKeys = new Set(getCallRecordDedupeKeys(incomingRecord));
  if (incomingKeys.size > 0) {
    const exactIndex = records.findIndex((record) =>
      getCallRecordDedupeKeys(record).some((key) => incomingKeys.has(key))
    );
    if (exactIndex >= 0) {
      return exactIndex;
    }
  }

  return records.findIndex((record) =>
    isCompletedIncomingDuplicatePair(record, incomingRecord)
  );
}

function sortCallRecords(records) {
  return records.slice().sort((left, right) => {
    const leftTime = normalizeTimestampMs(left && left.timestampMs, 0);
    const rightTime = normalizeTimestampMs(right && right.timestampMs, 0);
    return rightTime - leftTime;
  });
}

function trimCallRecords(records, limit = DEFAULT_CALL_RECORD_LIMIT) {
  const normalizedLimit = normalizeNumber(limit, DEFAULT_CALL_RECORD_LIMIT);
  if (!Number.isFinite(normalizedLimit) || normalizedLimit <= 0) {
    return records.slice();
  }
  return records.slice(0, normalizedLimit);
}

function upsertCallRecord(records, incomingEntry, options = {}) {
  const currentRecords = Array.isArray(records) ? records.slice() : [];
  const incomingRecord = normalizeCallRecordEntry(incomingEntry);
  if (!incomingRecord) {
    return currentRecords;
  }

  if (incomingRecord.source === CALL_RECORD_SOURCE_PROVIDER_LOCAL) {
    return trimCallRecords([incomingRecord, ...currentRecords], options.limit);
  }

  const existingIndex = findExistingRecordIndex(currentRecords, incomingRecord);
  const nextRecords = currentRecords.slice();
  if (existingIndex >= 0) {
    nextRecords[existingIndex] = mergeCallRecord(nextRecords[existingIndex], incomingRecord);
  } else {
    nextRecords.unshift(incomingRecord);
  }

  return trimCallRecords(sortCallRecords(nextRecords), options.limit);
}

function upsertCallMessageRecords(records, messages, options = {}) {
  const messageList = Array.isArray(messages) ? messages : [messages];
  return messageList.reduce((currentRecords, message) => {
    const entry = parseCallMessageRecord(message, options);
    return entry ? upsertCallRecord(currentRecords, entry, options) : currentRecords;
  }, Array.isArray(records) ? records : []);
}

function countCallRecordSources(records) {
  return (Array.isArray(records) ? records : []).reduce((counts, record) => {
    const source = normalizeSource(record && record.source, CALL_RECORD_SOURCE_PROVIDER_LOCAL);
    counts[source] = (counts[source] || 0) + 1;
    return counts;
  }, {});
}

module.exports = {
  CALL_RECORD_DIRECTIONS,
  CALL_RECORD_SOURCES,
  DEFAULT_CALL_RECORD_LIMIT,
  V2NIM_MESSAGE_TYPE_CALL,
  countCallRecordSources,
  getCallRecordDedupeKeys,
  getPrimaryCallRecordDedupeKey,
  findExistingRecordIndex,
  isCallMessage,
  normalizeCallAttachment,
  normalizeCallRecordEntry,
  normalizeProviderLocalRecord,
  parseCallMessageRecord,
  sortCallRecords,
  upsertCallMessageRecords,
  upsertCallRecord,
};
