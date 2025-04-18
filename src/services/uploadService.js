import cloudinary from "../utils/cloudinary.js";
import fs from 'fs';



//upload to Cloudinary
export const uploadToCloudinary=async(filePath)=>{
try {
    const result=await cloudinary.uploader.upload(filePath,{
        folder:'linkVault-avatar',// A specific folder in Cloudinary
        width: 250,
        height: 250,
        crop: 'fill', // Automatically crop and resize the image
        gravity: 'face' // Focus on face if present
    });
    fs.unlinkSync(filePath);
    return {
        public_id:result.public_id,
        url:result.secure_url
    }
} catch (error) {
    if(fs.existsSync(filePath)){
        fs.unlinkSync(filePath);
    }
    throw new Error(`Error uploading to Cloudinary:${error.message}`);
}
};



// delete from Cloudinary
export const deleteFromCloudinary=async(publicId)=>{
try {
    if(!publicId){
        return null;
    }
    const result =await cloudinary.uploader.destroy(publicId);
    return result;
} catch (error) {
    throw new Error(`Error deleting from Cloudinary:${error.message}`); 
}
};