import multer from 'multer';
import path from 'path';
import fs from 'fs';

const uploadDir = './tmp/uploads';
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        cb(null, `${Date.now()}-${file.originalname}`);
    }
});

export const upload = multer({
    storage: storage,
    limits: { fileSize: 1024 * 1024 * 5 } // 5MB
});
