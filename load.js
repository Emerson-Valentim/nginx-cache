const { setTimeout } = require("timers/promises")
const { Agent } = require("http")
const axios = require("axios")

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

    if (shouldWaitBasedInBatchSize(i, 200)) {
      await waitSeconds(0.5)
    }
  }

  console.log(new Set(results))
}

load()