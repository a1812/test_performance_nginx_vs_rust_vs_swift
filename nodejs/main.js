const http = require('http');

const server = http.createServer((req, res) => {
    // Устанавливаем заголовки для корректного отображения JSON
    res.setHeader('Content-Type', 'application/json');

    const data = {
        id: 1,
        name: "Иван",
        role: "Admin",
        date: new Date()
    };

    // Отправляем JSON-строку
    res.end(JSON.stringify(data));
});

const PORT = 3002;
server.listen(PORT, () => {
    console.log(`Сервер запущен на http://0.0.0.0:${PORT}`);
});
