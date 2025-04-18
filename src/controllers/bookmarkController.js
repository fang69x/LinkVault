import { Bookmark } from "../models/bookmark.model.js";

//Handling specific errors
const handleErrors = (error, res) => {
    if (error.name === 'ValidationError') {
      return res.status(400).json({ message: "Validation Error", error: error.message });
    }
    if (error.code === 11000) {
      return res.status(409).json({ message: "Duplicate URL detected for this user" });
    }
    return res.status(500).json({ message: "Server Error", error: error.message });
  };


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
        handleErrors(error,res);
    }
};

//get all bookmark for a user

export const getBookmarks=async(req,res)=>{
    try {
        const bookmarks=await Bookmark.find({user:req.user._id}).sort({createdAt:-1});
        res.status(200).json(bookmarks);
    } catch (error) {
        handleErrors(error,res);
    }
}

// get single bookmark
export const getBookmarkById=async(req,res)=>{
    try {
        const bookmark=await Bookmark.findOne({_id:req.params.id,
            user:req.user.id
        });
        if (!bookmark) {
            return res.status(404).json({ message: "Bookmark not found" });
          }
          res.status(200).json(bookmark);
    } catch (error) {
        handleErrors(error,res);
    }
}
//update bookmark
export const updateBookmark=async(req,res)=>{
    try {
       const {title,url,note,category,tags}=req.body;
       //find and update
       const updatedBookmark=await Bookmark.findByIdAndUpdate({
        _id:req.params.id,
        user:req.user.id,
       },
    {
        title,url,note,category,tags
    },
    {
        new:true
    }
    );
    if(!updatedBookmark){
        return res.status(404).json({ message: "Bookmark not found or unauthorized" });
    }
    res.status(200).json({
        updateBookmark,
    })
    } catch (error) {
        handleErrors(error,res);
    }
}
//delete a bookmark
export const deleteBookmark=async(req,res)=>{
    try {
        const deletedBookmark=await Bookmark.findByIdAndDelete({
            _id:req.params.id,
            user:req.user.id
        });
        if(!deletedBookmark){
            return res.status(404).json({ message: "Bookmark not found or unauthorized" });
        }
        res.status(200).json({
            message:"Bookmark deleted successfully"
        });
    } catch (error) {
        handleErrors(error,res);
    }
}