import { logDebug, createLoggerDecorator } from '@xkit-yx/utils'
import pkg from '../package.json'

const APP_NAME = 'NECall'
const logger = logDebug({
  level: 'debug',
  appName: APP_NAME,
  version: pkg.version,
})

export { logger, createLoggerDecorator }
