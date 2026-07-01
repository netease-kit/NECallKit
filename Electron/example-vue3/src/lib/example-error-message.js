'use strict';

const LOGIN_ACCOUNT_ERROR_MESSAGE = '账号错误或不存在';
const LOGIN_TOKEN_ERROR_MESSAGE = 'token 错误或无效';

const ACCOUNT_ERROR_CODES = new Set(['102404', '404']);
const TOKEN_ERROR_CODES = new Set(['102302', '302']);

function isObjectLike(value) {
  return value !== null && (typeof value === 'object' || typeof value === 'function');
}

function normalizeCode(value) {
  if (value === undefined || value === null || value === '') {
    return '';
  }
  if (typeof value === 'number' && Number.isFinite(value)) {
    return String(value);
  }
  if (typeof value === 'string') {
    return value.trim();
  }
  return '';
}

function readField(value, keys) {
  if (!isObjectLike(value)) {
    return undefined;
  }

  for (const key of keys) {
    if (key in value && value[key] !== undefined && value[key] !== null) {
      return value[key];
    }
  }

  return undefined;
}

function tryParseJsonObject(value) {
  const text = typeof value === 'string' ? value.trim() : '';
  if (!text || (text[0] !== '{' && text[0] !== '[')) {
    return null;
  }

  try {
    const parsed = JSON.parse(text);
    return isObjectLike(parsed) ? parsed : null;
  } catch (_error) {
    return null;
  }
}

function collectErrorCandidates(value, candidates = [], seen = new Set()) {
  if (value === undefined || value === null) {
    return candidates;
  }

  if (!isObjectLike(value)) {
    candidates.push(value);
    const parsed = tryParseJsonObject(value);
    if (parsed) {
      collectErrorCandidates(parsed, candidates, seen);
    }
    return candidates;
  }

  if (seen.has(value)) {
    return candidates;
  }
  seen.add(value);
  candidates.push(value);

  for (const key of ['cause', 'error', 'innerError', 'data', 'detail', 'response']) {
    collectErrorCandidates(value[key], candidates, seen);
  }

  const message = value.message;
  if (message && typeof message !== 'string') {
    collectErrorCandidates(message, candidates, seen);
  } else {
    const parsed = tryParseJsonObject(message);
    if (parsed) {
      collectErrorCandidates(parsed, candidates, seen);
    }
  }

  return candidates;
}

function readErrorCode(value) {
  return normalizeCode(
    readField(value, ['code', 'errorCode', 'errCode', 'status', 'statusCode', 'resCode'])
  );
}

function normalizeText(value) {
  if (value === undefined || value === null) {
    return '';
  }
  if (typeof value === 'string') {
    return value.trim();
  }
  if (typeof value === 'number' && Number.isFinite(value)) {
    return String(value);
  }
  return '';
}

function readErrorText(value) {
  if (value instanceof Error) {
    return normalizeText(value.message);
  }
  if (!isObjectLike(value)) {
    return normalizeText(value);
  }

  return normalizeText(
    readField(value, [
      'desc',
      'message',
      'msg',
      'reason',
      'reasonDesc',
      'detail',
      'description',
      'errorDescription',
      'statusText',
    ])
  );
}

function matchesTokenText(text) {
  return (
    /token|passtoken|auth|认证|鉴权/i.test(text) &&
    /invalid|wrong|error|expired|unauthorized|failed|无效|错误|过期|失败/i.test(text)
  );
}

function matchesAccountText(text) {
  return (
    /account|accid|user|uid|账号|用户/i.test(text) &&
    /not\s*exist|not\s*found|invalid|missing|unknown|不存在|无效|错误/i.test(text)
  );
}

function resolveLoginErrorMessage(error) {
  const candidates = collectErrorCandidates(error);
  const codes = candidates.map(readErrorCode).filter(Boolean);

  if (codes.some((code) => TOKEN_ERROR_CODES.has(code))) {
    return LOGIN_TOKEN_ERROR_MESSAGE;
  }
  if (codes.some((code) => ACCOUNT_ERROR_CODES.has(code))) {
    return LOGIN_ACCOUNT_ERROR_MESSAGE;
  }

  const text = candidates.map(readErrorText).filter(Boolean).join(' ');
  if (matchesTokenText(text)) {
    return LOGIN_TOKEN_ERROR_MESSAGE;
  }
  if (matchesAccountText(text)) {
    return LOGIN_ACCOUNT_ERROR_MESSAGE;
  }

  return '';
}

function stringifyObject(value) {
  try {
    const text = JSON.stringify(value);
    return text === undefined ? String(value) : text;
  } catch (_error) {
    return String(value);
  }
}

function formatGenericErrorMessage(error, options = {}) {
  if (error instanceof Error) {
    const message =
      normalizeText(error.message) ||
      (isObjectLike(error.message) ? stringifyObject(error.message) : '');
    if (options.includeErrorName && error.name) {
      return message ? `${error.name}: ${message}` : error.name;
    }
    return message || error.name;
  }

  if (typeof error === 'string') {
    return error;
  }

  if (isObjectLike(error)) {
    const code = readErrorCode(error);
    const text = readErrorText(error);
    if (code || text) {
      return [code ? `code ${code}` : '', text].filter(Boolean).join(': ');
    }
    return stringifyObject(error);
  }

  return String(error);
}

function formatLoginErrorMessage(error, options = {}) {
  return resolveLoginErrorMessage(error) || formatGenericErrorMessage(error, options);
}

module.exports = {
  LOGIN_ACCOUNT_ERROR_MESSAGE,
  LOGIN_TOKEN_ERROR_MESSAGE,
  formatGenericErrorMessage,
  formatLoginErrorMessage,
  resolveLoginErrorMessage,
};
