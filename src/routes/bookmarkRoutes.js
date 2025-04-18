import express from "express";
import { createBookmark, 
    getBookmarks, 
    getBookmarkById, 
    updateBookmark, 
    deleteBookmark, } from "../controllers/bookmarkController.js";
import { authenticateUser } from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/", authenticateUser, createBookmark);
router.get("/", authenticateUser, getBookmarks);
router.get("/:id", authenticateUser,getBookmarkById);
router.put("/:id", authenticateUser,updateBookmark);
router.delete("/:id", authenticateUser,deleteBookmark);
export default router;
