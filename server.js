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

app.listen(port, '0.0.0.0', () => {
  console.log(`Server is running on port ${port}`);
  console.log(`Serving files from ${__dirname}`);
});