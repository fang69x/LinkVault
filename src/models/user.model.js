import mongoose from "mongoose";
const userSchema= new mongoose.Schema({
    name:{
     type:String,
     required:true,
    },
    email:{
        type:String,
     required:true,
     unique:true,

    },
    password:{
        type:String,
        required:true,
    },
    avatar:{
      public_id:String,
      url:String
    },

},{
    timestamps:true
});

export default mongoose.model("User",userSchema);