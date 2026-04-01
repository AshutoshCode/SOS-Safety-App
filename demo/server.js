const http = require('http');
const fs = require('fs');
const path = require('path');

const server = http.createServer((req, res) => {
    if (req.url === '/' || req.url === '/index.html') {
        const filePath = path.join(__dirname, 'index.html');
        fs.readFile(filePath, 'utf-8', (err, data) => {
            if (err) {
                res.writeHead(500);
                res.end('Server error');
                return;
            }
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(data);
        });
    } else {
        res.writeHead(404);
        res.end('Not found');
    }
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`📱 Demo running at http://localhost:${PORT}`);
    console.log(`\n🚀 Features:`);
    console.log(`   • Phone login (any number)`);
    console.log(`   • SOS button (long press 1s)`);
    console.log(`   • Live alert tracking`);
    console.log(`   • Location simulation`);
    console.log(`   • Contact notifications\n`);
});
