import mongoose from "mongoose";
const bookmarkSchema= new mongoose.Schema({
    title:{
        type:String ,
        required:true,
    },
    url:{
        type:String ,
        required:true,
        match: /^(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([/\w .-]*)*\/?$/
    },
    note:{
      type:String,
    },
    category:{
        type:String,
        required:true,
        index: true
      },
      tags:{
        type:[String],
        default:[]
      },
    user:{
        type:mongoose.Schema.Types.ObjectId,
        ref:'User',
        required:true,
    }
},{
    timestamps:true,
});
// each user can have the same url only once  
bookmarkSchema.index({
    user:1,
    url:1
},{
    unique:true
});
// text index with custom weights(for priority in searching)
bookmarkSchema.index({ 
    title: 'text', 
    tags: 'text', 
    category: 'text', 
    note: 'text' 
},{
    weights:{title:3,tags:2,category:2,note:1}
});

// index for exact tag matching

bookmarkSchema.index({tags:1});
export const Bookmark=mongoose.model("Bookmark",bookmarkSchema)
