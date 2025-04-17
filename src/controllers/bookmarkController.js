import { Bookmark } from "../models/bookmark.model.js";

// create a new bookmark
export const createBookmark=async(req,res)=>{
    try {
        const {title,url,note,category,tags}=req.body;
        const bookmark=new Bookmark({
            title,
            url,
            note,
            category,
            tags,
            user: req.user._id,
        });
        const savedBookmark=await bookmark.save();
        res.status(201).json(savedBookmark)
    } catch (error) {
        res.status(500).json({ message: "Error creating bookmark", error: error.message });
    }
};
//get all bookmark for a user

export const getBookmarks=async(req,res)=>{
    try {
        const bookmarks=await Bookmark.find({user:req.user._id});
        res.status(200).json(bookmarks);
    } catch (error) {
        res.status(500).json({ message: "Error fetching bookmarks", error: error.message });
    }
}