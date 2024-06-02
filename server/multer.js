const express = require('express');
const multer = require('multer');
const app = express();
const port = 3000;

// Настройка multer для сохранения файлов
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'assets/') // Указываете путь, куда будут сохраняться файлы
  },
  filename: function (req, file, cb) {
    cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname))
  }
})

const upload = multer({ storage: storage })

// Маршрут для регистрации с загрузкой файла
app.post('/register', upload.single('profileImage'), async (req, res) => {
  // Здесь логика добавления пользователя в базу данных
  // req.file.path содержит путь к сохраненному файлу
  const imagePath = req.file.path; // Сохраните этот путь в базе данных

  // Отправьте ответ клиенту
  res.json({ message: 'User registered successfully', imagePath: imagePath });
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});