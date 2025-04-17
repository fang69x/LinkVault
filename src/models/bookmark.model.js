import mongoose from "mongoose";
const bookmarkSchema= new mongoose.Schema({
    title:{
        type:String ,
        required:true,
    },
    URL:{
        type:String ,
        required:true,
    },
    note:{
      type:String,
      required:false,
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
bookmarkSchema.index({ 
    title: 'text', 
    tags: 'text', 
    category: 'text', 
    note: 'text' 
});

export const Bookmark=mongoose.model("Bookmark",bookmarkSchema)
