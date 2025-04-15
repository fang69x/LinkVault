import express from 'express';
import fs from 'fs';
import { registerUser } from "../controllers/authController.js";
import { upload } from '../middleware/uploadMiddleware.js'; 

const uploadDir = './tmp/uploads';
if(!fs.existsSync(uploadDir)){
    fs.mkdirSync(uploadDir,{recursive:true});
}
const router=express.Router();

router.post("/register",upload.single('avatar'),registerUser);

export default router;