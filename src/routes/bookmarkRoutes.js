import express from "express";
import { createBookmark, getBookmarks } from "../controllers/bookmarkController.js";
import { authenticateUser } from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/", authenticateUser, createBookmark);
router.get("/", authenticateUser, getBookmarks);

export default router;
