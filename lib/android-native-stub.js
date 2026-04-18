'use strict';
// Intercepts failed .node native addon loads on Android/Termux.
// Required via NODE_OPTIONS so Claude Code doesn't crash when audio-capture
// or similar glibc-linked addons fail to dlopen on Bionic.
const Module = require('module');
const _load = Module._load;
const STUBS = ['audio-capture', 'audio-record', 'node-microphone', 'naudiodon', 'portaudio'];

Module._load = function (request, parent, isMain) {
  try {
    return _load.call(this, request, parent, isMain);
  } catch (err) {
    if (err.code === 'ERR_DLOPEN_FAILED' || err.code === 'MODULE_NOT_FOUND') {
      if (STUBS.some((p) => (request || '').toLowerCase().includes(p))) {
        return { record: () => ({ stop: () => {}, on: () => {} }), startRecording: () => {}, stopRecording: () => {} };
      }
    }
    throw err;
  }
};
