const { setTimeout } = require("timers/promises")
const { Agent } = require("http")
const axios = require("axios")

const BATCH_SIZE = 200;
const WAIT_TIME_IN_SECONDS = 0.5

function waitSeconds(seconds) {
  return setTimeout(seconds * 1000)
}

function shouldWaitBasedInBatchSize(current, size) {
  return !(current % size)
}

async function load() {
  const results = []

  const agent = new Agent({
    maxSockets: 500,
  })

  for (let i = 0; i < 50 * 100; i++) {
    const result = await axios.get('http://localhost:8080', {
      headers: {
        'user-agent': `Request ${i}`,
        'x-invalidate': 'no'
      },
      agent
    })

    results.push(result.data)

    if (shouldWaitBasedInBatchSize(i, BATCH_SIZE)) {
      await waitSeconds(WAIT_TIME_IN_SECONDS)
    }
  }

  console.log(new Set(results))
}

load()