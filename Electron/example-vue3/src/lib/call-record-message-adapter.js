'use strict';

const {
  CALL_RECORD_SOURCES,
  V2NIM_MESSAGE_TYPE_CALL,
  countCallRecordSources,
  findExistingRecordIndex,
  getCallRecordDedupeKeys,
  parseCallMessageRecord,
  upsertCallRecord,
} = require('./call-records');

// B080 后续诊断：把 callRecord.adapter.* 调试日志直接落盘到 os.tmpdir，
// 与 adapter 调用方（main service 或 renderer）的 onDebugLog 钩子并行写入。
// 主要解决 Windows / renderer 进程下 console.log 不可见、宿主 logs 数组只在 UI
// 内部展示的盲区。fs/os 在 Node（main）以及 nodeIntegration 开启的 renderer
// 中都可用；浏览器环境（无 require）下下面 require 会失败，被 try/catch 兜住。
let __debugFileLoggerPathResolved = null;
function resolveDebugFileLoggerPath() {
  if (__debugFileLoggerPathResolved !== null) {
    return __debugFileLoggerPathResolved;
  }
  try {
    const os = require('node:os');
    const path = require('node:path');
    __debugFileLoggerPathResolved = path.join(
      os.tmpdir(),
      'necallkit-call-record-debug.log'
    );
  } catch (_) {
    __debugFileLoggerPathResolved = '';
  }
  return __debugFileLoggerPathResolved;
}
function appendAdapterDebugLogToFile(level, label, payload) {
  const filePath = resolveDebugFileLoggerPath();
  if (!filePath) {
    return;
  }
  try {
    const fs = require('node:fs');
    const ts = new Date().toISOString();
    let payloadText = '';
    try {
      payloadText =
        payload === undefined ? '' : ' ' + JSON.stringify(payload);
    } catch (_) {
      payloadText = ' [unserializable payload]';
    }
    fs.appendFileSync(
      filePath,
      `${ts} [${level}] ${label}${payloadText}\n`,
      'utf8'
    );
  } catch (_) {
    /* swallow: 调试落盘失败不影响主流程 */
  }
}

const DEFAULT_HISTORY_LIMIT = 20;

function isObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function normalizeNumber(value, fallback) {
  const numberValue = Number(value);
  return Number.isFinite(numberValue) ? numberValue : fallback;
}

function describeError(error) {
  if (error instanceof Error) {
    return {
      name: error.name,
      message: error.message,
      stack: error.stack,
    };
  }
  return {
    name: 'Error',
    message: String(error || ''),
  };
}

function resolveMessageService(options = {}) {
  if (options.messageService) {
    return options.messageService;
  }

  if (typeof options.getMessageService === 'function') {
    const service = options.getMessageService();
    if (service) {
      return service;
    }
  }

  const client = options.v2Client || options.client;
  if (client) {
    if (typeof client.getMessageService === 'function') {
      const service = client.getMessageService();
      if (service) {
        return service;
      }
    }
    if (client.messageService) {
      return client.messageService;
    }
  }

  const session = options.externalSession || options.session;
  if (session) {
    if (typeof session.getV2MessageService === 'function') {
      const service = session.getV2MessageService();
      if (service) {
        return service;
      }
    }
    if (typeof session.getMessageService === 'function') {
      const service = session.getMessageService();
      if (service) {
        return service;
      }
    }
  }

  return null;
}

function addServiceListener(service, eventName, handler) {
  if (!service || typeof service.on !== 'function') {
    throw new Error('V2 messageService must provide on(event, handler)');
  }
  service.on(eventName, handler);
  return () => {
    if (typeof service.off === 'function') {
      service.off(eventName, handler);
      return;
    }
    if (typeof service.removeListener === 'function') {
      service.removeListener(eventName, handler);
    }
  };
}

function normalizeMessageList(value) {
  if (Array.isArray(value)) {
    return value;
  }
  if (value && Array.isArray(value.messages)) {
    return value.messages;
  }
  return [];
}

function createHistoryOption(options = {}) {
  const limit = normalizeNumber(options.historyLimit, DEFAULT_HISTORY_LIMIT);
  return Object.assign(
    {
      messageTypes: [V2NIM_MESSAGE_TYPE_CALL],
      limit,
      direction: 0,
    },
    isObject(options.historyOption) ? options.historyOption : {}
  );
}

async function queryHistoryMessages(messageService, options = {}) {
  if (!messageService) {
    return [];
  }

  const option = createHistoryOption(options);
  if (typeof messageService.getMessageListEx === 'function') {
    return normalizeMessageList(await messageService.getMessageListEx(option));
  }
  if (typeof messageService.getMessageList === 'function') {
    return normalizeMessageList(await messageService.getMessageList(option));
  }
  if (typeof messageService.getCloudMessageList === 'function') {
    return normalizeMessageList(await messageService.getCloudMessageList(option));
  }
  return [];
}

function getLastMessageId(records) {
  const firstRecord = Array.isArray(records) ? records[0] : null;
  if (!firstRecord) {
    return '';
  }
  return (
    firstRecord.messageServerId ||
    firstRecord.messageClientId ||
    firstRecord.dedupeKey ||
    ''
  );
}

function createCallRecordMessageAdapter(options = {}) {
  let messageService = null;
  let records = Array.isArray(options.records) ? options.records.slice() : [];
  let started = false;
  let ready = false;
  let error = '';
  let historyError = '';
  let lastMessageId = getLastMessageId(records);
  let unsubscribers = [];

  function debug(level, label, payload) {
    if (typeof options.onDebugLog === 'function') {
      options.onDebugLog(level, label, payload);
    }
    appendAdapterDebugLogToFile(level, label, payload);
  }

  // 提取一条 record 的去重身份与关键 attachment 字段，用于结构化日志。
  // 让"两条话单到底差在哪里"的排查能在日志里一眼看到。
  function describeRecordIdentity(record) {
    if (!record || typeof record !== 'object') {
      return { dedupeKeys: [] };
    }
    return {
      source: record.source,
      channelId: record.channelId || '',
      messageClientId: record.messageClientId || '',
      messageServerId: record.messageServerId || '',
      callType: record.callType,
      callState: record.callState,
      direction: record.direction,
      peerAccountId: record.peerAccountId || '',
      timestampMs: record.timestampMs,
      dedupeKeys: getCallRecordDedupeKeys(record),
    };
  }

  function emitRecords(eventName, nextRecords) {
    records = nextRecords;
    lastMessageId = getLastMessageId(records);
    if (typeof options.onRecords === 'function') {
      options.onRecords(records.slice(), {
        eventName,
        state: getState(),
      });
    }
  }

  // B080 后续诊断：捕获 message 与 attachment 的原始形态（避免 node-nim 在两个
  // 事件里给出不同 attachment 结构而 channelId 被丢的情况看不到现场）。
  function describeRawAttachment(message) {
    if (!message || typeof message !== 'object') {
      return { messageKeys: [] };
    }
    const attachment = message.attachment;
    const summary = {
      messageKeys: Object.keys(message),
      attachmentType: attachment === null
        ? 'null'
        : Array.isArray(attachment)
          ? 'array'
          : typeof attachment,
    };
    if (typeof attachment === 'string') {
      summary.attachmentStringSample = attachment.slice(0, 200);
    } else if (attachment && typeof attachment === 'object') {
      summary.attachmentKeys = Object.keys(attachment);
      summary.attachmentChannelIdRaw = attachment.channelId;
      summary.attachmentTypeField = attachment.type;
      summary.attachmentStatusField = attachment.status;
      if (typeof attachment.raw === 'string') {
        summary.attachmentRawStringSample = attachment.raw.slice(0, 200);
      }
    }
    return summary;
  }

  function handleMessages(eventName, messages, source) {
    try {
      const messageList = Array.isArray(messages) ? messages : [messages];
      let currentRecords = records;

      for (let index = 0; index < messageList.length; index += 1) {
        const message = messageList[index];
        const rawAttachmentSummary = describeRawAttachment(message);
        const parsed = parseCallMessageRecord(message, {
          selfAccountId: options.selfAccountId,
          source,
          nowMs: Date.now(),
        });

        if (!parsed) {
          debug('debug', `callRecord.adapter.${eventName}.skip`, {
            source,
            reason: 'not_call_message_or_missing_attachment',
            messageType:
              message && (message.messageType !== undefined
                ? message.messageType
                : message && message.type),
            messageClientId: message && message.messageClientId,
            messageServerId: message && message.messageServerId,
            rawAttachment: rawAttachmentSummary,
          });
          continue;
        }

        const existingIndex = findExistingRecordIndex(currentRecords, parsed);

        debug('debug', `callRecord.adapter.${eventName}.parse`, {
          source,
          dedupeMatch:
            existingIndex >= 0
              ? {
                  reason: 'matched_existing',
                  index: existingIndex,
                  existing: describeRecordIdentity(currentRecords[existingIndex]),
                }
              : { reason: 'no_match' },
          incoming: describeRecordIdentity(parsed),
          rawAttachment: rawAttachmentSummary,
        });

        const nextRecords = upsertCallRecord(currentRecords, parsed, {
          limit: options.limit,
        });

        if (nextRecords !== currentRecords) {
          currentRecords = nextRecords;
        }
      }

      if (currentRecords !== records) {
        debug('info', `callRecord.adapter.${eventName}.snapshot`, {
          source,
          recordCount: currentRecords.length,
          sourceCounts: countCallRecordSources(currentRecords),
          channelIds: currentRecords
            .map((record) => record && record.channelId)
            .filter(Boolean),
        });
        emitRecords(eventName, currentRecords);
      }
    } catch (handleError) {
      error = describeError(handleError).message;
      debug('error', `callRecord.adapter.${eventName}`, describeError(handleError));
    }
  }

  async function loadHistory() {
    const historyLimit = normalizeNumber(options.historyLimit, DEFAULT_HISTORY_LIMIT);
    if (historyLimit <= 0) {
      return;
    }

    try {
      const historyMessages = await queryHistoryMessages(messageService, options);
      if (historyMessages.length === 0) {
        return;
      }
      handleMessages('history', historyMessages, CALL_RECORD_SOURCES.IM_HISTORY);
    } catch (loadError) {
      historyError = describeError(loadError).message;
      debug('error', 'callRecord.adapter.history', describeError(loadError));
    }
  }

  function getState() {
    return {
      started,
      ready,
      error,
      historyError,
      lastMessageId,
      recordCount: records.length,
      sourceCounts: countCallRecordSources(records),
    };
  }

  return {
    async start() {
      if (started) {
        return getState();
      }

      try {
        messageService = resolveMessageService(options);
        if (!messageService) {
          throw new Error('V2 messageService is unavailable for call records');
        }

        // B080：desktop 默认话单同时监听本端 sendMessage 与 receive/history。
        // sendMessage 覆盖 desktop/core 自发消息；receive/history 保留 IM 同步
        // 与历史回放语义，不在 adapter 里按 completed 状态做特殊拦截。
        unsubscribers = [
          addServiceListener(messageService, 'sendMessage', (message) =>
            handleMessages('sendMessage', message, CALL_RECORD_SOURCES.IM_SEND)
          ),
          addServiceListener(messageService, 'receiveMessages', (messages) =>
            handleMessages(
              'receiveMessages',
              messages,
              CALL_RECORD_SOURCES.IM_CALL_MESSAGE
            )
          ),
          addServiceListener(messageService, 'receiveMessagesModified', (messages) =>
            handleMessages(
              'receiveMessagesModified',
              messages,
              CALL_RECORD_SOURCES.IM_CALL_MESSAGE
            )
          ),
        ];

        started = true;
        ready = true;
        error = '';
        debug('info', 'callRecord.adapter.start', {
          historyLimit: normalizeNumber(options.historyLimit, DEFAULT_HISTORY_LIMIT),
        });
        await loadHistory();
      } catch (startError) {
        ready = false;
        started = false;
        error = describeError(startError).message;
        debug('error', 'callRecord.adapter.start', describeError(startError));
      }

      return getState();
    },
    stop() {
      unsubscribers.forEach((unsubscribe) => {
        try {
          unsubscribe();
        } catch (stopError) {
          debug('error', 'callRecord.adapter.stop.listener', describeError(stopError));
        }
      });
      unsubscribers = [];
      started = false;
      ready = false;
      messageService = null;
      debug('info', 'callRecord.adapter.stop', {});
      return getState();
    },
    destroy() {
      return this.stop();
    },
    getRecords() {
      return records.slice();
    },
    getState,
  };
}

module.exports = {
  DEFAULT_HISTORY_LIMIT,
  createCallRecordMessageAdapter,
  queryHistoryMessages,
  resolveMessageService,
};
