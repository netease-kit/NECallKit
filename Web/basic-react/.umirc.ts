import { defineConfig } from 'umi';
import { resolve } from 'path';

export default defineConfig({
  alias: {
    '@xkit-yx/call-kit-react-ui': resolve(__dirname, 'call-kit-ui/src'),
  },
  history: {
    type: 'hash', // 将路由切换为 hash 模式
  },
  // 其他配置...
  // publicPath: './',
});
