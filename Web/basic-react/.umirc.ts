import { defineConfig } from 'umi';

export default defineConfig({
  history: {
    type: 'hash', // 将路由切换为 hash 模式
  },
  // 其他配置...
  // publicPath: './',
});