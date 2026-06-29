'use strict';

const { createApp } = require('vue');
const { createExampleApp } = require('./app');

const App = createExampleApp();

createApp(App).mount('#app');
