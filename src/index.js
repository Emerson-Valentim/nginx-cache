const app = require("express")()
const port = process.env.PORT

app.get('/', (req, res) => {
  console.log(`Incoming request from ${req.headers["X-server-origin"]} instance`)

  if (req.headers["x-invalidate"] === "yes") {
    res.setHeader("Cache-Control", "max-age=0")
  }

  if (req.headers["x-error"] === "yes") {
    res.status(500);
  }

  res.send(new Date().toISOString())
})

app.get('/health', (_, res) => {
  res.send("ok")
})

app.listen(port, () => {
  console.log(`I'm all ears on port ${port}`)
})