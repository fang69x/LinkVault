import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/user.model.js";
import { uploadToCloudinary} from "../services/uploadService.js";
import fs from 'fs';

// Register user
export const registerUser=async(req,res)=>{
    try {
        //take name , email , password from the body of the request
        const { name, email, password } = req.body;
        //now check if it already exist
        const existingUser=await User.findOne({email}); // finding by email as it is unique
        if(existingUser)
        {
// Remove uploaded file if user already there
if (req.file && fs.existsSync(req.file.path)) {
    fs.unlinkSync(req.file.path);
}
return res.status(400).json({
    message: "User already exists, Please use another email"
});
        }

        // hash the password before putting to database
        const hashedPassword=await bcrypt.hash(password,10);
        // handle avatar file
        let avatarData={};
        if(req.file){
            avatarData=await uploadToCloudinary(req.file.path);
        }
        // now after all these create a user with email and the hashed password and avatar
        const newUser=new User({
           name:name,
           email,
           password:hashedPassword,
           avatar:avatarData
        });
        // now save the new user to the database
        await newUser.save();
        //Generate the JWT token

        const token=jwt.sign(
            {
            userId:newUser._id,
        },
        process.env.JWT_SECRET,
        {
            expiresIn:"1h",

        }
    );
    res.status(201).json({
        message: "User registered successfully",
        token,
        user: {
            id: newUser._id,
            name: newUser.name,
            email: newUser.email,
            avatar: newUser.avatar?.url || null
        }
    });
} catch (error) {
    // Clean up file if registration fails
    if (req.file && fs.existsSync(req.file.path)) {
        fs.unlinkSync(req.file.path);
    }
    
    res.status(500).json({
        message: "Error registering user",
        error: error.message
    });
}
};