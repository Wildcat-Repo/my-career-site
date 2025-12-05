const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use((req, res, next) => {
  res.set('Content-Security-Policy', "default-src 'self'");
  next();
});

app.use(express.static('site/'));

// 404 handler - must be after static files
app.use((req, res) => {
  res.status(404).sendFile(__dirname + '/site/404.html');
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
  console.log(`Serving files from ${__dirname}`);
});